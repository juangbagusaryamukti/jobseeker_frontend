import 'package:flutter/material.dart';
import 'package:jobseeker_app/widgets/hrd_bottom_nav.dart';

class HrdSearch extends StatefulWidget {
  const HrdSearch({super.key});

  @override
  State<HrdSearch> createState() => _HrdSearchState();
}

class _HrdSearchState extends State<HrdSearch> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("HRD Search"),
      ),
      bottomNavigationBar: HrdBottomNav(1),
    );
  }
}
