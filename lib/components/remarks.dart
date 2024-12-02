import 'package:flutter/material.dart';
import 'package:vandana_app/utils/custom_fonts.dart';
import 'package:vandana_app/utils/utils.dart';

class RemarksWidget extends StatelessWidget {
  final String remark;
  const RemarksWidget({super.key, required this.remark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        infoRow("Remarks", ""),
        Text(remark,
            textAlign: TextAlign.justify, style: MontserratFont.paragraphReg1)
      ],
    );
  }
}
