import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vandana_app/components/reason_dialog.dart';
import 'package:vandana_app/components/remarks.dart';
import 'package:vandana_app/model/order_entity.dart';
import 'package:vandana_app/network/order_service.dart';
import 'package:vandana_app/utils/custom_fonts.dart';
import 'package:vandana_app/utils/utils.dart';

class DeliverOrderPage extends StatefulWidget {
  final Order order;
  const DeliverOrderPage({super.key, required this.order});

  @override
  State<DeliverOrderPage> createState() => _DeliverOrderPageState();
}

class _DeliverOrderPageState extends State<DeliverOrderPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? imageData;
  String? _retrieveDataError;

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
            Text("Delivery image:", style: MontserratFont.paragraphSemiBold1),
            Center(
              child: loadImage(),
            ),

            // if (_picker.supportsImageSource(ImageSource.camera))
            //   Padding(
            //     padding: EdgeInsets.all(8.h),
            //     child: Center(
            //       child: FloatingActionButton(
            //         onPressed: () async {
            //           try {
            //             final XFile? pickedFile = await _picker.pickImage(
            //               source: ImageSource.camera,
            //             );
            //             setState(() {
            //               imageData = pickedFile;
            //             });
            //           } catch (e) {
            //             print("error in capturing image");
            //           }
            //         },
            //         tooltip:
            //             imageData == null ? 'Take a Photo' : 'Retake the photo',
            //         child: const Icon(Icons.camera_alt),
            //       ),
            //     ),
            //   ),
            // if(imageData !=null)
            //   FloatingActionButton(onPressed: (){}, child: const Text("Save"))
          ],
        ),
      ),
      floatingActionButton: _picker.supportsImageSource(ImageSource.camera)
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: "fab1",
                  onPressed: () async {
                    try {
                      final XFile? pickedFile = await _picker.pickImage(
                        source: ImageSource.camera,
                      );
                      setState(() {
                        imageData = pickedFile;
                      });
                    } catch (e) {
                      print("error in capturing image");
                    }
                  },
                  tooltip:
                      imageData == null ? 'Take a Photo' : 'Retake the photo',
                  child: const Icon(Icons.camera_alt),
                ),
                if (imageData != null)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: FloatingActionButton(
                      backgroundColor: Colors.green,
                      heroTag: "fab2",
                      tooltip: "Deliver",
                      onPressed: imageData != null ? deliverOrder : null,
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
              // Navigator.pop(context);
              //updated state to delivered here.
              //append image now.
              var res = await OrderService().upsertImage(
                  widget.order.id, File(imageData!.path), imageData!.name);
              res.onSuccess((success) {
                print(success);
                Navigator.pop(context);
              });
              res.onFailure((failure) {
                print(failure);
                Navigator.pop(context);
              });
            },
          );
        }).then((val) => Navigator.pop(context));
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        imageData = response.file;
      });
    } else {
      _retrieveDataError = response.exception!.code;
    }
  }

  Widget? loadImage() {
    return FutureBuilder(
        future: retrieveLostData(),
        builder: (context, AsyncSnapshot<void> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Text(
                'You have not yet picked an image.',
                textAlign: TextAlign.center,
              );
            case ConnectionState.done:
              return imageData != null
                  ? previewImage()
                  : SizedBox(
                      height: 100.h,
                      child: Center(
                          child: Text(
                        "Upload delivery image",
                        style: MontserratFont.heading3
                            .copyWith(color: Colors.redAccent),
                      )));
            case ConnectionState.active:
              if (snapshot.hasError) {
                return Text(
                  'Pick image/video error: ${snapshot.error}}',
                  textAlign: TextAlign.center,
                );
              } else {
                return const Text(
                  'You have not yet picked an image.',
                  textAlign: TextAlign.center,
                );
              }
          }
        });
  }

  Widget previewImage() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    } else {
      return Image.file(
        File(imageData!.path),
        errorBuilder:
            (BuildContext context, Object error, StackTrace? stackTrace) {
          return const Center(child: Text('This image type is not supported'));
        },
      );
    }
  }

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }
}
