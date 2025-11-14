import 'package:flutter/material.dart';
import 'package:jobseeker_app/widgets/colors.dart';

class SocietyBottomNav extends StatefulWidget {
  SocietyBottomNav(this.page, {super.key});
  int page;

  @override
  State<SocietyBottomNav> createState() => _SocietyBottomNavState();
}

class _SocietyBottomNavState extends State<SocietyBottomNav> {
  getPage(index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/society_dashboard');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/society_search',
          arguments: {"fromdashboard": false});
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/society_vacancy');
    } else if (index == 3) {
      Navigator.pushReplacementNamed(context, '/society_profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: ColorsApp.white,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      currentIndex: widget.page,
      type: BottomNavigationBarType.fixed,
      onTap: getPage,
      items: [
        BottomNavigationBarItem(
          activeIcon: Image.asset('assets/navbar/Home_on.png'),
          icon: Image.asset('assets/navbar/Home.png'),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          activeIcon: Image.asset('assets/navbar/Work_on.png'),
          icon: Image.asset('assets/navbar/Work.png'),
          label: 'Company',
        ),
        BottomNavigationBarItem(
          activeIcon: Image.asset('assets/navbar/Document_on.png'),
          icon: Image.asset('assets/navbar/Document.png'),
          label: 'Vacancy',
        ),
        BottomNavigationBarItem(
          activeIcon: Image.asset('assets/navbar/Profile_on.png'),
          icon: Image.asset('assets/navbar/Profile.png'),
          label: 'Profile',
        ),
      ],
    );
  }
}
