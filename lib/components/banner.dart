import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vandana_app/utils/custom_fonts.dart';
import 'package:vandana_app/utils/utils.dart';

class BannerWidget extends StatelessWidget {
  final OrderState state;
  const BannerWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case OrderState.RECEIVED:
      case OrderState.NEED_SPARE:
      case OrderState.WAITING_CUSTOMER:
      case OrderState.INPROGRESS:
        return const SizedBox();
      case OrderState.COMPLETED:
        return Transform.rotate(
          angle: 270,
          child: Text("Payment & delivery remaining",
              style: MontserratFont.paragraphSemiBold1
                  .copyWith(color: Colors.orange)),
        );
      case OrderState.DELIVERED:
        return Transform.scale(
          scale: 2,
          child: Transform.rotate(
            angle: 270,
            child: Stack(
              children: [
                Text("Paid",
                    style: MontserratFont.paragraphSemiBold1
                        .copyWith(color: Colors.greenAccent)),
                Icon(Icons.done, size: 24.h, color: Colors.greenAccent),
              ],
            ),
          ),
        );
      case OrderState.DELETED:
        return Transform.rotate(
          angle: 270,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(state.name,
                  style: MontserratFont.paragraphSemiBold1
                      .copyWith(color: Colors.redAccent)),
              Icon(Icons.delete_outline, size: 24.h, color: Colors.redAccent),
            ],
          ),
        );
      case OrderState.CANCELLED:
      case OrderState.REJECTED:
        return Transform.rotate(
          angle: 270,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(state.name,
                  style: MontserratFont.paragraphSemiBold1
                      .copyWith(color: Colors.redAccent)),
              Icon(Icons.cancel_outlined, size: 24.h, color: Colors.redAccent),
            ],
          ),
        );
    }
  }
}
