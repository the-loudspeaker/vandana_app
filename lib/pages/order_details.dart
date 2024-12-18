import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:result_dart/result_dart.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:share_whatsapp/share_whatsapp.dart';
import 'package:vandana_app/components/banner.dart';
import 'package:vandana_app/components/order_images_widget.dart';
import 'package:vandana_app/components/reason_dialog.dart';
import 'package:vandana_app/components/receipt.dart';
import 'package:vandana_app/components/remarks.dart';
import 'package:vandana_app/components/screen_lock.dart';
import 'package:vandana_app/model/order_entity.dart';
import 'package:vandana_app/network/order_service.dart';
import 'package:vandana_app/pages/edit_order.dart';
import 'package:vandana_app/utils/custom_fonts.dart';
import 'package:vandana_app/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/widgets.dart' as pw;

import 'deliver_order.dart';

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
  ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    fetchOrder();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    num balanceAmount = order?.estimatedCost ?? 0;
    if (order?.advanceAmount != null) {
      balanceAmount = balanceAmount - order!.advanceAmount!;
    }
    return Scaffold(
      appBar: customAppBar("Order No. ${widget.jobId}", context, actions: [
        order?.status == OrderState.INPROGRESS.name
            ? IconButton(
                tooltip: "Cancel Order",
                onPressed: () => showDialog(
                      context: context,
                      builder: (context) => ReasonDialog(
                          title: "Cancel Order",
                          state: OrderState.CANCELLED,
                          order: order!,
                          primaryButtonText: "Confirm Cancel Order",
                          successCallback: () => Navigator.pop(context)),
                    ).then((val) => fetchOrder()),
                icon: const Icon(Icons.cancel))
            : const SizedBox(),
        order?.status == OrderState.INPROGRESS.name
            ? IconButton(
                tooltip: "Delete Order",
                onPressed: () => showDialog(
                      context: context,
                      builder: (context) => ReasonDialog(
                          title: "Delete Order",
                          state: OrderState.DELETED,
                          order: order!,
                          successCallback: () => Navigator.pop(context),
                          primaryButtonText: "Confirm Delete Order"),
                    ).then((val) => fetchOrder()),
                icon: const Icon(Icons.delete))
            : const SizedBox(),
        order?.status == OrderState.DELIVERED.name ||
                order?.status == OrderState.DELETED.name ||
                order?.status == OrderState.REJECTED.name ||
                order?.status == OrderState.CANCELLED.name
            ? const SizedBox()
            : IconButton(
                tooltip: "Edit Order",
                onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                EditOrderScreen(givenOrder: order)))
                    .then((val) => fetchOrder()),
                icon: const Icon(Icons.edit))
      ]),
      body: RefreshIndicator(
        onRefresh: fetchOrder,
        child: !isLoading
            ? !isError
                ? ListView(
                    padding:
                        EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                    shrinkWrap: true,
                    primary: true,
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
                              child: Text(order!.status,
                                  style: MontserratFont.heading4.copyWith(
                                      color: getOrderColor(order!.status))))
                        ],
                      ),
                      const Divider(),
                      infoRow("Created at:", formatDate(order!.createdAt),
                          mainAxisAlignment: MainAxisAlignment.start),
                      infoRow("Updated at:", formatDate(order!.modifiedAt),
                          mainAxisAlignment: MainAxisAlignment.start),
                      infoRow("POC:", order?.modifiedBy ?? "",
                          mainAxisAlignment: MainAxisAlignment.start),
                      const Divider(),
                      infoRow("Customer name", order!.customerName),
                      // infoRow("Address", order?.customerAddress??""),
                      infoRow("Mobile no.",
                          order?.customerContact.toString() ?? ""),
                      const Divider(),
                      infoRow("Device model", order!.model),
                      infoRow("Problem", order!.issueDescription),
                      if (!isNullOREmpty(order!.remarks))
                        RemarksWidget(remark: order?.remarks ?? ""),
                      infoRow("Estimate", "Rs. ${order!.estimatedCost}"),
                      if (order!.advanceAmount != null)
                        infoRow("Advance", "Rs. ${order!.advanceAmount}"),
                      if (balanceAmount != 0)
                        infoRow("Balance", "Rs. $balanceAmount",
                            valueStyle: MontserratFont.paragraphBold1
                                .copyWith(color: Colors.red)),
                      if (order!.status == OrderState.DELIVERED.name)
                        infoRow("Paid", "Rs. ${order!.estimatedCost}",
                            valueStyle: MontserratFont.paragraphBold1
                                .copyWith(color: Colors.green)),
                      if (!isNullOREmpty(order!.customerAddress))
                        infoRow("Address", order!.customerAddress.toString()),
                      const Divider(),
                      Text("Items collected:",
                          style: MontserratFont.paragraphSemiBold1),
                      Table(
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        children: [
                          for (List<String> chunk in order!.itemsList.chunk(2))
                            TableRow(children: [
                              for (String c in chunk)
                                TableCell(
                                    child: Text(c,
                                        style: MontserratFont.paragraphReg1)),
                              if (chunk.length == 1)
                                TableCell(
                                    child: Text("",
                                        style: MontserratFont.paragraphReg1))
                            ])
                        ],
                      ),
                      const Divider(),
                      ScreenLockWidget(
                          screenLockType: order!.screenlockType,
                          screenLock: order!.screenlock),
                      const Divider(),
                      SizedBox(height: 8.h),
                      Center(
                          child: BannerWidget(
                              state: OrderState.fromString(order!.status))),
                      SizedBox(height: 16.h),
                      OrderImagesWidget(orderId: order!.id),
                    ],
                  )
                : Center(child: Text(errorMessage))
            : const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: !isError && !isLoading
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton(
                    heroTag: "share order",
                    tooltip: "Share",
                    onPressed: shareHiddenWidget,
                    child: const Icon(Icons.share)),
                Padding(
                  padding: EdgeInsets.only(top: 16.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FloatingActionButton(
                        heroTag: "print order",
                        tooltip: "Print receipt",
                        onPressed: printHiddenWidget,
                        child: const Icon(Icons.print),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 16.h),
                        child: FloatingActionButton(
                          heroTag: "share on whatsapp",
                          tooltip: "Share receipt on whatsapp.",
                          onPressed: sendWhatsapp,
                          child: const FaIcon(FontAwesomeIcons.whatsapp),
                        ),
                      )
                    ],
                  ),
                ),
                if (order!.status == OrderState.WAITING_CUSTOMER.name)
                  Padding(
                    padding: EdgeInsets.only(top: 16.h),
                    child: FloatingActionButton(
                      heroTag: "call customer",
                      tooltip: "Call Customer",
                      backgroundColor: Colors.green,
                      onPressed: callCustomer,
                      child: const Icon(Icons.call),
                    ),
                  )
              ],
            )
          : const SizedBox(),
      bottomNavigationBar:
          (!isError && !isLoading && order?.status != OrderState.DELIVERED.name)
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
                  child: getOrderButtons(OrderState.fromString(order!.status)),
                )
              : null,
    );
  }

  Future<void> fetchOrder() async {
    if (mounted) {
      setState(() {
        isError = false;
        isLoading = true;
      });
    }

    Result<Order> res =
        await OrderService().getOrderById(widget.orderId);
    res.onSuccess((success) {
      if (mounted) {
        setState(() {
          isLoading = false;
          order = success;
        });
      }
    });
    res.onFailure((failure) {
      if (mounted) {
        setState(() {
          isLoading = false;
          isError = true;
          errorMessage = failure.toString();
        });
      }
    });
  }

  Widget getOrderButtons(OrderState orderState) {
    switch (orderState) {
      case OrderState.COMPLETED:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          WidgetStatePropertyAll(Colors.green.shade400),
                      foregroundColor:
                          const WidgetStatePropertyAll(Colors.white)),
                  onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return DeliverOrderPage(order: order!);
                      })).then((val) => fetchOrder()),
                  child: const Text("Mark as Delivered")),
            ),
          ],
        );
      case OrderState.RECEIVED:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ElevatedButton(
                  onPressed: () => showDialog(
                        context: context,
                        builder: (context) => ReasonDialog(
                            title: "Reject Order",
                            state: OrderState.REJECTED,
                            order: order!,
                            successCallback: () => Navigator.pop(context),
                            primaryButtonText: "Confirm Reject Order"),
                      ).then((val) => fetchOrder()),
                  child: const Text("Reject Order",
                      style: TextStyle(color: Colors.redAccent))),
            ),
            Expanded(
              child: ElevatedButton(
                  onPressed: () => updateStatus(OrderState.INPROGRESS)
                      .then((val) => fetchOrder()),
                  child: const Text("Start working")),
            )
          ],
        );
      case OrderState.INPROGRESS:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: ElevatedButton(
                        onPressed: () => updateStatus(OrderState.NEED_SPARE)
                            .then((val) => fetchOrder()),
                        child: const Text("Need Spares"))),
                Expanded(
                    child: ElevatedButton(
                        onPressed: () =>
                            updateStatus(OrderState.WAITING_CUSTOMER)
                                .then((val) => fetchOrder()),
                        child: const Text("Wait for customer")))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: ElevatedButton(
                        onPressed: () => updateStatus(OrderState.COMPLETED)
                            .then((val) => fetchOrder()),
                        child: const Text("Mark as Completed"))),
              ],
            ),
          ],
        );
      case OrderState.NEED_SPARE:
      case OrderState.WAITING_CUSTOMER:
        return Row(
          children: [
            Expanded(
                child: ElevatedButton(
                    onPressed: () => updateStatus(OrderState.INPROGRESS)
                        .then((val) => fetchOrder()),
                    child: const Text("Resume working")))
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Future<void> updateStatus(OrderState orderState) async {
    Map<dynamic, dynamic> fieldsMap = {'status': orderState.name};

    var res = await OrderService().updateOrder(widget.orderId, fieldsMap);
    res.onSuccess((success) {
      return;
    });
    res.onFailure((failure) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error: $failure"),
      ));
    });
  }

  Future<void> shareHiddenWidget() async {
    var res1 = await screenshotController.captureFromWidget(
        ReceiptWidget(order: order!),
        delay: const Duration(seconds: 0),
        context: context);

    final directory = await getApplicationDocumentsDirectory();
    final imageFile =
        await File('${directory.path}/${widget.orderId}.png').create();
    await imageFile.writeAsBytes(res1);

    await Share.shareXFiles([XFile(imageFile.path)]);
    return Future.value();
  }

  Future<void> printHiddenWidget() async {
    var res1 = await screenshotController.captureFromWidget(
        ReceiptWidget(order: order!),
        delay: const Duration(seconds: 0),
        context: context);

    // var res2 = await screenshotController
    //     .captureFromWidget(const Material(child: TermsAndConditionsWidget()));

    final doc = pw.Document(
        pageMode: PdfPageMode.fullscreen,
        title: order!.jobId.toString(),
        subject: order!.jobId.toString(),
        author: order!.createdBy.toString());
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a6,
      build: (pw.Context context) =>
          pw.Center(child: pw.Image(pw.MemoryImage(res1))),
    ));
    // doc.addPage(pw.Page(
    //   pageFormat: PdfPageFormat.a6,
    //   build: (pw.Context context) =>
    //       pw.Center(child: pw.Image(pw.MemoryImage(res2))),
    // ));

    try {
      await Printing.layoutPdf(onLayout: (layout) => doc.save());
    } on Exception catch (_) {}

    return Future.value();
  }

  Future<bool> callCustomer() async =>
      await launchUrl(Uri.parse("tel:${order!.customerContact}"));

  Future<void> sendWhatsapp() async {
    var res1 = await screenshotController.captureFromWidget(
        ReceiptWidget(order: order!),
        delay: const Duration(seconds: 0),
        context: context);

    final directory = await getTemporaryDirectory();
    final imageFile =
        await File('${directory.path}/${widget.orderId}.png').create();
    await imageFile.writeAsBytes(res1);
    final imageXFile = XFile(imageFile.path);

    try {
      // await launchUrl(
      //   Uri.parse(
      //       "whatsapp://send?phone=918087103131&file=${imageFile.path}&text=Hello"),
      // );
      // const SocialPlatform platform = SocialPlatform.whatsapp;
      // await SocialSharingPlus.shareToSocialMedia(
      //   platform,
      //   "test content",
      //   media: imageFile.path,
      //   isOpenBrowser: true,
      // );
      // await WhatsappShare.shareFile(
      //     filePath: [imageFile.path], phone: "91${order!.customerContact}");
      await shareWhatsapp.share(
          phone: "91${order!.customerContact}",
          text: "Order No. ${order!.jobId}",
          file: imageXFile);
    } on Exception catch (_) {}

    return Future.value();
  }
}
