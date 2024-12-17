import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vandana_app/model/order_entity.dart';
import 'package:vandana_app/utils/custom_fonts.dart';
import 'package:vandana_app/utils/shop_name.dart';
import 'package:vandana_app/utils/terms_and_conditions.dart';
import 'package:vandana_app/utils/utils.dart';

import 'banner.dart';

class ReceiptWidget extends StatelessWidget {
  final Order order;
  const ReceiptWidget({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    num balanceAmount = order.estimatedCost;
    if (order.advanceAmount != null) {
      balanceAmount = balanceAmount - order.advanceAmount!;
    }
    return InheritedTheme.captureAll(
      context,
      Material(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            // crossAxisAlignment: CrossAxisAlignment.start,
            // shrinkWrap: true,
            // primary: false,
            // physics: const NeverScrollableScrollPhysics(),
            children: [
              const ShopNameWidget(),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                      flex: 1,
                      child: Text("Order No.",
                          style: MontserratFont.paragraphSemiBold1)),
                  Flexible(
                      flex: 4,
                      child: Text(order.jobId.toString(),
                          style: MontserratFont.heading4
                              .copyWith(color: Colors.redAccent)))
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                      flex: 1,
                      child: Text("Status",
                          style: MontserratFont.paragraphSemiBold1)),
                  Flexible(
                      flex: 4,
                      child: Text(order.status,
                          style: MontserratFont.heading4
                              .copyWith(color: getOrderColor(order.status))))
                ],
              ),
              const Divider(),
              infoRow("Customer name", order.customerName),
              infoRow("Mobile no.", order.customerContact.toString()),
              const Divider(),
              infoRow("Device model", order.model),
              infoRow("Problem", order.issueDescription),
              infoRow("Estimate", "Rs. ${order.estimatedCost}"),
              if (order.advanceAmount != null)
                infoRow("Advance", "Rs. ${order.advanceAmount}"),
              if (balanceAmount != 0)
                infoRow("Balance", "Rs. $balanceAmount",
                    valueStyle: MontserratFont.paragraphBold1
                        .copyWith(color: Colors.red)),
              if (order.status == OrderState.DELIVERED.name)
                infoRow("Paid", "Rs. ${order.estimatedCost}",
                    valueStyle: MontserratFont.paragraphBold1
                        .copyWith(color: Colors.green)),
              const Divider(),
              Row(
                children: [
                  Text("Items collected:",
                      style: MontserratFont.paragraphSemiBold1),
                ],
              ),
              Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  for (List<String> chunk in order.itemsList.chunk(2))
                    TableRow(children: [
                      for (String c in chunk)
                        TableCell(
                            child:
                                Text(c, style: MontserratFont.paragraphReg1)),
                      if (chunk.length == 1)
                        TableCell(
                            child:
                                Text("", style: MontserratFont.paragraphReg1))
                    ])
                ],
              ),
              const Divider(),
              SizedBox(height: 8.h),
              BannerWidget(state: OrderState.fromString(order.status)),
              const Divider(),
              const TermsAndConditionsWidget()
            ],
          ),
        ),
      ),
    );
  }
}
