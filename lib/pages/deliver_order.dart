
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vandana_app/components/reason_dialog.dart';
import 'package:vandana_app/components/remarks.dart';
import 'package:vandana_app/model/order_entity.dart';
import 'package:vandana_app/network/order_service.dart';
import 'package:vandana_app/utils/custom_fonts.dart';
import 'package:vandana_app/utils/local_images_preview.dart';
import 'package:vandana_app/utils/utils.dart';

import 'image_picker_page.dart';

class DeliverOrderPage extends StatefulWidget {
  final Order order;
  const DeliverOrderPage({super.key, required this.order});

  @override
  State<DeliverOrderPage> createState() => _DeliverOrderPageState();
}

class _DeliverOrderPageState extends State<DeliverOrderPage> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> imageList = List.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    num balanceAmount = widget.order.estimatedCost;
    if (widget.order.advanceAmount != null) {
      balanceAmount = balanceAmount - widget.order.advanceAmount!;
    }
    return Scaffold(
      appBar: customAppBar("Delivering to customer", context),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                    flex: 1,
                    child: Text("Status",
                        style: MontserratFont.paragraphSemiBold1)),
                Flexible(
                    flex: 4,
                    child: Text(widget.order.status,
                        style: MontserratFont.heading4.copyWith(
                            color: getOrderColor(widget.order.status))))
              ],
            ),
            const Divider(),
            infoRow("POC:", widget.order.modifiedBy ?? "",
                mainAxisAlignment: MainAxisAlignment.start),
            const Divider(),
            infoRow("Customer name", widget.order.customerName),
            // infoRow("Address", order?.customerAddress??""),
            infoRow(
                "Mobile no.", widget.order.customerContact.toString() ?? ""),
            const Divider(),
            infoRow("Device model", widget.order.model),
            infoRow("Problem", widget.order.issueDescription),
            !isNullOREmpty(widget.order.remarks)
                ? RemarksWidget(remark: widget.order.remarks ?? "")
                : const SizedBox(),
            infoRow("Estimate", "Rs. ${widget.order.estimatedCost}"),
            widget.order.advanceAmount != null
                ? infoRow("Advance", "Rs. ${widget.order.advanceAmount}")
                : const SizedBox(),
            infoRow("Balance", "Rs. $balanceAmount",
                valueStyle:
                    MontserratFont.paragraphBold1.copyWith(color: Colors.red)),
            !isNullOREmpty(widget.order.customerAddress)
                ? infoRow("Address", widget.order.customerAddress.toString())
                : const SizedBox(),
            const Divider(),
            Text("Items collected:", style: MontserratFont.paragraphSemiBold1),
            Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                for (List<String> chunk in widget.order.itemsList.chunk(2))
                  TableRow(children: [
                    for (String c in chunk)
                      TableCell(
                          child: Text(c, style: MontserratFont.paragraphReg1)),
                    if (chunk.length == 1)
                      TableCell(
                          child: Text("", style: MontserratFont.paragraphReg1))
                  ])
              ],
            ),
            const Divider(),
            Text("Delivery images:", style: MontserratFont.paragraphSemiBold1),
            Center(child: LocalImagesPreview(mediaFileList: imageList))
          ],
        ),
      ),
      floatingActionButton: _picker.supportsImageSource(ImageSource.camera)
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: "fab1",
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ImagePickerPage(
                            onPick: (List<XFile> images) {
                              if (mounted &&
                                  images.isNotEmpty) {
                                setState(() {
                                  imageList = images;
                                });
                              }
                            },
                          ))),
                  tooltip:
                      imageList.isEmpty ? 'Add photos' : 'Re-upload photos',
                  child: const Icon(Icons.camera_alt),
                ),
                if (imageList.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: FloatingActionButton(
                      backgroundColor: Colors.green,
                      heroTag: "fab2",
                      tooltip: "Deliver",
                      onPressed: imageList.isNotEmpty ? deliverOrder : null,
                      child: const Icon(Icons.done),
                    ),
                  )
                // : const SizedBox()
              ],
            )
          : null,
    );
  }

  Future<void> deliverOrder() async {
    num balanceAmount = widget.order.estimatedCost;
    if (widget.order.advanceAmount != null) {
      balanceAmount = balanceAmount - widget.order.advanceAmount!;
    }
    showDialog(
        context: context,
        builder: (context) {
          return ReasonDialog(
            title: "Confirm payment of Rs. $balanceAmount",
            state: OrderState.DELIVERED,
            order: widget.order,
            primaryButtonText: "Mark as Delivered",
            successCallback: () async {
              //updated state to delivered here using ReasonDialog.
              //upload all images at once.

              List<Future<void>> futures = imageList.map((s) => OrderService().upsertImage(widget.order.id, File(s.path), s.name)).toList();
              await Future.wait(futures);
              Navigator.pop(context);
            },
          );
        }).then((val) => Navigator.pop(context));
  }
}
