import 'package:flutter/material.dart';
import 'package:jobseeker_app/controllers/portofolio_controller.dart';
import 'package:jobseeker_app/controllers/skill_controller.dart';
import 'package:jobseeker_app/widgets/colors.dart';
import 'package:jobseeker_app/widgets/customtextfield.dart';

class AddSkillBottomSheet extends StatefulWidget {
  final PortfolioController portfolioController;
  final Function(List<String>) onSkillsUpdated;

  const AddSkillBottomSheet({
    super.key,
    required this.portfolioController,
    required this.onSkillsUpdated,
  });

  @override
  State<AddSkillBottomSheet> createState() => _AddSkillBottomSheetState();
}

class _AddSkillBottomSheetState extends State<AddSkillBottomSheet> {
  final TextEditingController skillController = TextEditingController();
  final SkillController _skillController = SkillController();

  List<String> suggestedSkills = [];
  List<String> selectedSkills = [];

  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  Future<void> _loadSkills() async {
    final skills = await _skillController.fetchSkills();
    setState(() {
      suggestedSkills = skills;
      selectedSkills = List.from(widget.portfolioController.selectedSkills);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Add Skill",
                  style: TextStyle(
                    fontFamily: "Lato",
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // INPUT
            CustomTextField(
              controller: skillController,
              label: "",
              hintText: "Search or type new skill",
              onChanged: (value) async {
                final results =
                    await _skillController.fetchSkills(search: value);
                setState(() {
                  suggestedSkills = results;
                });
              },
            ),
            const SizedBox(height: 20),

            // SKILL LIST
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: suggestedSkills.map((skill) {
                final isSelected = selectedSkills.contains(skill);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedSkills.remove(skill);
                      } else {
                        selectedSkills.add(skill);
                      }
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? ColorsApp.primarydark : ColorsApp.white1,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? ColorsApp.primarydark
                            : ColorsApp.Grey3,
                      ),
                    ),
                    child: Text(
                      skill,
                      style: TextStyle(
                        color: isSelected ? Colors.white : ColorsApp.Grey1,
                        fontSize: 11,
                        fontFamily: "Lato",
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // SAVE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final inputSkill = skillController.text.trim();
                  if (inputSkill.isNotEmpty &&
                      !selectedSkills.contains(inputSkill)) {
                    selectedSkills.add(inputSkill);
                  }

                  Navigator.pop(context);
                  await widget.portfolioController
                      .saveSkills(context, selectedSkills);
                  widget.onSkillsUpdated(selectedSkills);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsApp.primarydark,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Save Skills",
                  style: TextStyle(
                    color: ColorsApp.white,
                    fontFamily: "Lato",
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
