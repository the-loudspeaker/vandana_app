import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:result_dart/result_dart.dart';
import 'package:vandana_app/model/order_entity.dart';
import 'package:vandana_app/network/order_service.dart';
import 'package:vandana_app/pages/edit_order.dart';
import 'package:vandana_app/utils/custom_fonts.dart';
import 'package:vandana_app/utils/utils.dart';

import 'screen_lock_widget.dart';

class OrderDetailsPage extends StatefulWidget {
  final String orderId;
  final int jobId;
  const OrderDetailsPage(
      {super.key, required this.orderId, required this.jobId});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  bool isLoading = true;
  Order? order;
  bool isError = false;
  String errorMessage = "";

  @override
  void initState() {
    fetchOrder();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("Order No. ${widget.jobId}", context),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        child: RefreshIndicator(
          onRefresh: fetchOrder,
          child: !isLoading
              ? !isError
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ListView(
                          shrinkWrap: true,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                    flex: 1,
                                    child: Text("Status",
                                        style:
                                            MontserratFont.paragraphSemiBold1)),
                                Flexible(
                                    flex: 4,
                                    child: Text(order!.status,
                                        style: MontserratFont.heading4.copyWith(
                                            color:
                                                getOrderColor(order!.status))))
                              ],
                            ),
                            const Divider(),
                            infoRow("Created at:", formatDate(order!.createdAt),
                                mainAxisAlignment: MainAxisAlignment.start),
                            infoRow(
                                "Updated at:", formatDate(order!.modifiedAt),
                                mainAxisAlignment: MainAxisAlignment.start),
                            infoRow("POC:", order?.modifiedBy ?? "",
                                mainAxisAlignment: MainAxisAlignment.start),
                            const Divider(),
                            infoRow("Customer name", order!.customerName),
                            infoRow("Address", order?.customerAddress??""),
                            infoRow("Mobile no.",
                                order?.customerContact.toString() ?? ""),
                            infoRow("Problem", order!.issueDescription),
                            !isNullOREmpty(order!.remarks)
                                ? RemarksWidget(order!.remarks)
                                : const SizedBox(),
                            infoRow("Estimate", "Rs. ${order!.estimatedCost}"),
                            order!.advanceAmount != null
                                ? infoRow(
                                    "Advance", "Rs. ${order!.advanceAmount}")
                                : const SizedBox(),
                            !isNullOREmpty(order!.customerAddress)
                                ? infoRow("Address",
                                    order!.customerAddress.toString())
                                : const SizedBox(),
                            const Divider(),
                            Text("Items collected:",
                                style: MontserratFont.paragraphSemiBold1),
                            Table(
                              defaultVerticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              children: [
                                for (List<String> chunk
                                    in order!.itemsList.chunk(2))
                                  TableRow(children: [
                                    for (String c in chunk)
                                      TableCell(
                                          child: Text(c,
                                              style: MontserratFont
                                                  .paragraphReg1)),
                                    if (chunk.length == 1)
                                      TableCell(
                                          child: Text("",
                                              style:
                                                  MontserratFont.paragraphReg1))
                                  ])
                              ],
                            ),
                            const Divider(),
                            ScreenLockWidget(
                                screenLockType: order!.screenlockType,
                                screenLock: order!.screenlock),
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    child: ElevatedButton(
                                        onPressed: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditOrderScreen(
                                                            givenOrder: order)))
                                            .then((val) => fetchOrder()),
                                        child: const Text("Edit Order"))),
                                Expanded(
                                    child: ElevatedButton(
                                        onPressed: () {},
                                        child: const Text("Mark as Completed")))
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    child: ElevatedButton(
                                        onPressed: () {},
                                        child: const Text("Mark as Delivered")))
                              ],
                            ),
                          ],
                        )
                      ],
                    )
                  : Center(child: Text(errorMessage))
              : const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Future<void> fetchOrder() async {
    setState(() {
      isError = false;
      isLoading = true;
    });

    Result<Order, String> res =
        await OrderService().getOrderById(widget.orderId);
    res.onSuccess((success) {
      setState(() {
        isLoading = false;
        order = success;
      });
    });
    res.onFailure((failure) {
      setState(() {
        isLoading = false;
        isError = true;
        errorMessage = failure;
      });
    });
  }
}

Widget RemarksWidget(String remark) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      infoRow("Remarks", ""),
      Text(remark,
          textAlign: TextAlign.justify, style: MontserratFont.paragraphReg1)
    ],
  );
}
