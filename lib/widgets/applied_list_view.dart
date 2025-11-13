import 'package:flutter/material.dart';
import 'package:jobseeker_app/widgets/colors.dart';

class AppliedListView extends StatelessWidget {
  const AppliedListView({super.key});

  @override
  Widget build(BuildContext context) {
    final applied = [
      {
        "image": "",
        "name": "John Doe",
        "address": "Malang City, Indonesia",
        "CV": "bla bla bla",
      },
      {
        "image": "",
        "name": "John Doe",
        "address": "Malang City, Indonesia",
        "CV": "bla bla bla",
      },
      {
        "image": "",
        "name": "John Doe",
        "address": "Malang City, Indonesia",
        "CV": "bla bla bla",
      },
    ];
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: applied.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          decoration: BoxDecoration(
            color: ColorsApp.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                spreadRadius: 2,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: ColorsApp.primarydark,
                    radius: 20,
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        applied[index]["name"]!,
                        style: TextStyle(
                          fontFamily: "Lato",
                          color: ColorsApp.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        applied[index]["address"]!,
                        style: TextStyle(
                          fontFamily: "Lato",
                          fontSize: 12,
                          color: ColorsApp.Grey2,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              _buildButton(),
            ],
          ),
        );
      },
    );
  }

  _buildButton() {
    return Container(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: ColorsApp.white,
                foregroundColor: ColorsApp.primarydark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                side: BorderSide(
                  width: 1,
                  color: ColorsApp.primarydark,
                ),
              ),
              onPressed: () {},
              child: Text(
                "See Resume",
                style: TextStyle(
                  fontFamily: "Lato",
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: ColorsApp.white,
                backgroundColor: ColorsApp.primarydark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {},
              child: Text(
                "See Details",
                style: TextStyle(
                  fontFamily: "Lato",
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
