import 'package:flutter/material.dart';
import 'package:vandana_app/utils/custom_fonts.dart';

class ShopNameWidget extends StatelessWidget {
  const ShopNameWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("वंदना मोबाईल शॉपी",
            style: MontserratFont.heading1.copyWith(color: Colors.red)),
        Text("हाउसिंग सोसायटी, अंबाजोगाई",
            style: MontserratFont.heading3.copyWith(color: Colors.red)),
        Text("मो. 9595455151",
            style: MontserratFont.heading3.copyWith(color: Colors.red))
      ],
    );
  }
}
