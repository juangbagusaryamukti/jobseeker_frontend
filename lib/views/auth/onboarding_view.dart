import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jobseeker_app/widgets/colors.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _controller = PageController();
  int currentpage = 0;

  final List<Map<String, String>> onboardingdata = [
    {
      "image": "assets/image/onboarding_1.png",
      "title": "Welcome to WorkScout",
      "description":
          "Discover your dream job with WorkScout. Whether You're seasoned professional or just starting your career, we connect you with the best opportunities tailored just for you"
    },
    {
      "image": "assets/image/onboarding_2.png",
      "title": "Personalized Job Matches",
      "description":
          "We understand your unique skills and preferences. Our advanced algorithm ensures you receive job recommendations that match your profile perfectly."
    },
    {
      "image": "assets/image/onboarding_3.png",
      "title": "Stay Connected and Informed",
      "description":
          "Never miss an opportunity with real-time notifications and updates. Stay ahead in your career with the latest job openings and industry insights."
    }
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Bagian atas (primarylight) dengan lekukan
          ClipPath(
            clipper: BottomCurveClipper(),
            child: Container(
              height: 500,
              color: ColorsApp.primarylight,
              alignment: Alignment.center,
              child: PageView.builder(
                controller: _controller,
                itemCount: onboardingdata.length,
                onPageChanged: (index) {
                  setState(() => currentpage = index);
                },
                itemBuilder: (context, index) {
                  return Image.asset(
                    onboardingdata[index]["image"]!,
                    height: 300,
                    fit: BoxFit.contain,
                  );
                },
              ),
            ),
          ),

          // Bagian bawah (putih)
          Expanded(
            child: Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 25, bottom: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    onboardingdata[currentpage]["title"]!,
                    style: const TextStyle(
                      fontFamily: "Lato",
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      onboardingdata[currentpage]["description"]!,
                      style: const TextStyle(
                        fontFamily: "Lato",
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 15),
                  SmoothPageIndicator(
                    controller: _controller,
                    count: onboardingdata.length,
                    effect: ColorTransitionEffect(
                      dotColor: ColorsApp.primarylight,
                      activeDotColor: ColorsApp.primarydark,
                      dotWidth: 8,
                      dotHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      if (currentpage < onboardingdata.length - 1) {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.ease,
                        );
                      } else {
                        Navigator.pushReplacementNamed(context, "/login");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorsApp.primarydark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          currentpage == onboardingdata.length - 1
                              ? "Get Started"
                              : "Next",
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: "Lato",
                            color: ColorsApp.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          color: ColorsApp.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Membuat lekukan di bagian bawah warna primarylight
class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60); // turun ke bawah
    path.quadraticBezierTo(
      size.width / 2, size.height, // titik tengah lekukan
      size.width, size.height - 60, // naik lagi ke kanan
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
