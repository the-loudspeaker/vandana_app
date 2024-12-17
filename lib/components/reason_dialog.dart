import 'package:flutter/material.dart';
import 'package:vandana_app/model/order_entity.dart';
import 'package:vandana_app/network/order_service.dart';
import 'package:vandana_app/utils/custom_fonts.dart';
import 'package:vandana_app/utils/utils.dart';

class ReasonDialog extends StatefulWidget {
  final String title;
  final OrderState state;
  final Order order;
  final String primaryButtonText;
  final VoidCallback? successCallback;
  const ReasonDialog(
      {super.key,
      required this.title,
      required this.state,
      required this.order,
      required this.primaryButtonText,
      this.successCallback});
  @override
  State<ReasonDialog> createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<ReasonDialog> {
  final TextEditingController reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String updatedRemarks = isNullOREmpty(widget.order.remarks)
        ? reasonController.text
        : "${widget.order.remarks!}\n${reasonController.text}";
    return AlertDialog(
      title: Text(widget.title),
      titleTextStyle:
          MontserratFont.paragraphMedium1.copyWith(color: Colors.redAccent),
      content: TextField(
        onChanged: (String value) {
          setState(() {
            reasonController.text = value;
          });
        },
        onSubmitted: null,
        controller: reasonController,
        autofocus: true,
        decoration: InputDecoration(
            hintText: widget.state == OrderState.DELIVERED
                ? "Enter remarks"
                : "Enter reason",
            hintStyle: MontserratFont.paragraphReg1),
      ),
      actions: [
        TextButton(
            onPressed: !isNullOREmpty(reasonController.text)
                ? () {
                    updateStatusAndAddRemark(updatedRemarks).then((val) {
                      if (val == "Success") {
                        widget.successCallback!();
                      }
                    });
                  }
                : null,
            child: Text(widget.primaryButtonText))
      ],
    );
  }

  Future<String> updateStatusAndAddRemark(String? remarks) async {
    Map<dynamic, dynamic> fieldsMap = {
      'status': widget.state.name,
      'remarks': remarks
    };

    var res = await OrderService().updateOrder(widget.order.id, fieldsMap);
    if (res.isSuccess()) {
      return Future.value("Success");
    } else {
      return Future.value("Failure");
    }
    res.onSuccess((success) {});
    res.onFailure((failure) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error: $failure"),
      ));
    });
  }
}
