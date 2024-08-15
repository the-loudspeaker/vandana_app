import 'package:flutter/material.dart';
import 'package:vandana_app/utils/custom_fonts.dart';
import 'package:vandana_app/utils/utils.dart';

class ScreenLockWidget extends StatefulWidget {
  final String screenLockType;
  final String screenLock;
  const ScreenLockWidget(
      {super.key, required this.screenLockType, required this.screenLock});

  @override
  State<ScreenLockWidget> createState() => _ScreenLockWidgetState();
}

class _ScreenLockWidgetState extends State<ScreenLockWidget> {
  bool masked = true;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Screen Lock Type:", style: MontserratFont.paragraphSemiBold1),
            Text(widget.screenLockType,
                style: MontserratFont.paragraphSemiBold1),
            if (widget.screenLockType != ScreenLockType.NONE.name)
              Text(masked ? "*****" : widget.screenLock,
                  style: MontserratFont.paragraphReg1)
          ],
        ),
        if (widget.screenLockType != ScreenLockType.NONE.name)
          GestureDetector(
            onLongPressStart: (value) {
              setState(() {
                masked = false;
              });
            },
            onLongPressEnd: (value) {
              setState(() {
                masked = true;
              });
            },
            child: Icon(masked ? Icons.visibility : Icons.visibility_off),
          )
      ],
    );
  }
}
