import 'package:flutter/material.dart';
import 'package:jobseeker_app/widgets/colors.dart';
import 'package:jobseeker_app/widgets/customtextfield.dart';
import 'package:jobseeker_app/widgets/society_bottom_nav.dart';
import 'package:jobseeker_app/widgets/society_listview_dasboard.dart';
import 'package:jobseeker_app/controllers/vacancy_controller.dart';
import 'package:jobseeker_app/models/vacancy_model.dart';

class SocietySearch extends StatefulWidget {
  const SocietySearch({super.key});

  @override
  State<SocietySearch> createState() => _SocietySearchState();
}

class _SocietySearchState extends State<SocietySearch> {
  int selectedStatus = 0;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final VacancyController _controller = VacancyController();

  List<VacancyModel> _searchResults = [];
  bool _isSearching = false;
  bool _notFound = false;
  bool _isTyping = false; // 🔹 untuk mengganti icon search <-> clear

  List<String> dateposted = [
    "Anytime",
    ">Last 24 Hours",
    ">Last Week",
    ">Last Month",
  ];
  // Filter states
  String _selectedDatePosted = "";
  String _selectedLocation = "";

  @override
  void initState() {
    super.initState();
    _fetchInitialData();

    _searchController.addListener(() {
      final typing = _searchController.text.isNotEmpty;
      if (typing != _isTyping) {
        setState(() {
          _isTyping = typing;
        });
      }
    });

    // Ambil argumen setelah widget ter-build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      bool fromDashboard = args?['fromdashboard'] == true;

      // Jika dari dashboard -> langsung fokus ke search field
      if (fromDashboard) {
        FocusScope.of(context).requestFocus(_focusNode);
      }
    });
  }

  Future<void> _fetchInitialData() async {
    await _controller.fetchAllVacancies();
    setState(() {
      _searchResults = [];
    });
  }

  DateTime? _getDateThreshold() {
    final now = DateTime.now();
    switch (_selectedDatePosted) {
      case "Last 24 Hours":
        return now.subtract(const Duration(days: 1));
      case "Last Week":
        return now.subtract(const Duration(days: 7));
      case "Last Month":
        return DateTime(now.year, now.month - 1, now.day);
      default:
        return null;
    }
  }

  void _applyFiltersAndSearch() {
    final keyword = _searchController.text.toLowerCase().trim();
    final threshold = _getDateThreshold();

    setState(() {
      _isSearching = true;
    });

    final results = _controller.vacancies.where((vacancy) {
      final position = vacancy.positionName?.toLowerCase() ?? "";
      final company = vacancy.companyName?.toLowerCase() ?? "";
      final address = vacancy.companyAddress?.toLowerCase() ?? "";
      final datePosted = vacancy.submissionStartDate;

      final matchesKeyword = keyword.isEmpty ||
          position.contains(keyword) ||
          company.contains(keyword) ||
          address.contains(keyword);

      final matchesDate = threshold == null
          ? true
          : datePosted.isAfter(threshold) ||
              datePosted.isAtSameMomentAs(threshold);

      final matchesLocation = _selectedLocation.isEmpty
          ? true
          : address.contains(_selectedLocation.toLowerCase());

      return matchesKeyword && matchesDate && matchesLocation;
    }).toList();

    setState(() {
      _searchResults = results;
      _isSearching = false;
      _notFound = results.isEmpty;
    });
  }

  void _openFilterSheet() {
    String tempDate = _selectedDatePosted;
    String tempLocation = _selectedLocation;
    int tempSelectedStatus = selectedStatus;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorsApp.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.85,
              maxChildSize: 0.95,
              builder: (_, scrollController) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Filter",
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w600,
                              color: ColorsApp.black,
                              fontFamily: "Lato",
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 🗓 Date Posted Filter
                      const Text(
                        "Date Posted",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: List.generate(
                          dateposted.length,
                          (index) => _statusButton(
                            dateposted[index],
                            tempSelectedStatus == index,
                            () {
                              modalSetState(() {
                                tempSelectedStatus = index;
                                tempDate = dateposted[index];
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 📍 Location Filter
                      const Text(
                        "Location",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: "Lato",
                        ),
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        hintText: "Find your location",
                        prefixIcon: const Icon(
                          Icons.location_on_outlined,
                          color: ColorsApp.primarydark,
                          size: 15,
                        ),
                        controller: TextEditingController(text: tempLocation),
                        onChanged: (val) => tempLocation = val,
                      ),

                      const SizedBox(height: 30),

                      // 🔘 Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: ColorsApp.primarydark,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedDatePosted = "Anytime";
                                  _selectedLocation = "";
                                  selectedStatus = 0;
                                });
                                Navigator.pop(context);
                                _applyFiltersAndSearch();
                              },
                              child: const Text(
                                "Reset",
                                style: TextStyle(
                                  color: ColorsApp.primarydark,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Lato",
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorsApp.primarydark,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedDatePosted = tempDate;
                                  _selectedLocation = tempLocation;
                                  selectedStatus = tempSelectedStatus;
                                });
                                Navigator.pop(context);
                                _applyFiltersAndSearch();
                              },
                              child: const Text(
                                "Apply Now",
                                style: TextStyle(
                                  color: ColorsApp.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Lato",
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _statusButton(String text, bool isSelected, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? ColorsApp.primarydark : ColorsApp.white,
        foregroundColor: isSelected ? ColorsApp.white : ColorsApp.primarydark,
        side: BorderSide(
          color: isSelected ? ColorsApp.primarydark : ColorsApp.Grey2,
          width: 1.3,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: "Lato",
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildNotFound() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/image/sad_face.png",
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 16),
            const Text(
              "Not Found",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Sorry, no job available",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsApp.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔍 Search bar + Filter
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        hintText: "Search",
                        textInputAction: TextInputAction.search,
                        onFieldSubmitted: (_) => _applyFiltersAndSearch(),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            if (_isTyping) {
                              _searchController.clear();
                              FocusScope.of(context).requestFocus(_focusNode);
                            } else {
                              _applyFiltersAndSearch();
                            }
                          },
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, anim) =>
                                FadeTransition(opacity: anim, child: child),
                            child: _isTyping
                                ? const Icon(Icons.close_rounded,
                                    key: ValueKey("clear"),
                                    color: ColorsApp.primarydark)
                                : const Image(
                                    image: AssetImage(
                                      "assets/navbar/Search_on.png",
                                    ),
                                    width: 20,
                                    height: 20,
                                    key: ValueKey("search"),
                                    color: ColorsApp.primarydark),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _openFilterSheet,
                      icon: const Icon(Icons.filter_list, size: 18),
                      label: const Text(
                        "Filter",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: "Lato",
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: ColorsApp.white,
                        foregroundColor: ColorsApp.primarydark,
                        elevation: 0,
                        side: const BorderSide(color: ColorsApp.primarydark),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 🔹 Hasil pencarian
                if (_isSearching)
                  const Center(child: CircularProgressIndicator())
                else if (_notFound)
                  _buildNotFound()
                else if (_searchResults.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${_searchResults.length} Jobs Available",
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Lato"),
                      ),
                      const SizedBox(height: 12),
                      SocietyListViewDashboard(
                        limitItems: false,
                        vacancies: _searchResults,
                      ),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Recomendation",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Lato"),
                      ),
                      const SizedBox(height: 12),
                      SocietyListViewDashboard(limitItems: false),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SocietyBottomNav(1),
    );
  }
}
