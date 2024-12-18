import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vandana_app/model/order_entity.dart';
import 'package:vandana_app/network/order_service.dart';
import 'package:vandana_app/pages/image_picker_page.dart';
import 'package:vandana_app/pages/order_details.dart';
import 'package:vandana_app/utils/custom_fonts.dart';
import 'package:vandana_app/utils/utils.dart';

class EditOrderScreen extends StatefulWidget {
  final Order? givenOrder;
  const EditOrderScreen({super.key, required this.givenOrder});

  @override
  State<EditOrderScreen> createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends State<EditOrderScreen> {
  bool isExistingOrder = false;
  bool loading = false;
  OrderState? orderState = OrderState.RECEIVED;
  String? customerName;
  num? customerContact;
  String? model;
  String? issueDescription;
  String? remarks;
  num? estimatedCost;
  num advancedPaid = 0;
  ScreenLockType? screenLockType = ScreenLockType.NONE;
  String? screenLock;
  List<ItemType> itemsList = List.empty(growable: true);
  final TextEditingController _estimatedCostController =
      TextEditingController();
  final TextEditingController _advancePaidController = TextEditingController();
  final TextEditingController _customerContactController =
      TextEditingController();
  XFile? image;

  @override
  void initState() {
    isExistingOrder = widget.givenOrder != null;
    if (isExistingOrder) {
      orderState = OrderState.fromString(widget.givenOrder!.status);
      customerName = widget.givenOrder?.customerName;
      customerContact = widget.givenOrder?.customerContact;
      model = widget.givenOrder?.model;
      issueDescription = widget.givenOrder?.issueDescription;
      remarks = widget.givenOrder?.remarks;
      estimatedCost = widget.givenOrder?.estimatedCost;
      advancedPaid = widget.givenOrder?.advanceAmount ?? 0;
      try {
        screenLockType =
            ScreenLockType.fromString(widget.givenOrder!.screenlockType);
      } on Exception {
        screenLockType = ScreenLockType.NONE;
      }
      screenLock = widget.givenOrder?.screenlock;
      itemsList = widget.givenOrder?.itemsList
              .map((e) => ItemType.fromString(e))
              .toList() ??
          [];
      _customerContactController.text = customerContact.toString();
      _estimatedCostController.text = estimatedCost.toString();
      _advancePaidController.text = advancedPaid.toString();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
          isExistingOrder
              ? "Edit Order no. ${widget.givenOrder?.jobId}"
              : "Create order",
          context),
      body: !loading
          ? SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FormBuilderDropdown<OrderState>(
                        name: "Order Status",
                        initialValue: orderState,
                        decoration: InputDecoration(
                            labelText: orderState == null
                                ? "Select Order Status"
                                : "Order Status:"),
                        items: OrderState.values
                            .where((e) => isExistingOrder
                                ? e != OrderState.DELIVERED
                                : e == OrderState.RECEIVED)
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.name,
                                      style: MontserratFont.heading4.copyWith(
                                          color: getOrderColor(e.name))),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            orderState = value ?? OrderState.RECEIVED;
                          });
                        }),
                    FormBuilderTextField(
                        initialValue: customerName,
                        name: 'Customer Name',
                        canRequestFocus: false,
                        onChanged: (val) {
                          setState(() {
                            customerName = val;
                          });
                        },
                        decoration: InputDecoration(
                            labelText: isNullOREmpty(customerName)
                                ? "Enter Customer Name"
                                : "Customer Name:"),
                        keyboardType: TextInputType.text,
                        autovalidateMode: AutovalidateMode.onUnfocus,
                        autocorrect: false,
                        autofocus: false),
                    FormBuilderField<num>(
                      initialValue: customerContact,
                      name: "Customer Contact no.",
                      onChanged: (val) {
                        setState(() {
                          customerContact = val;
                        });
                      },
                      builder: (FormFieldState<num> field) {
                        return TextField(
                          controller: _customerContactController,
                          keyboardType: TextInputType.phone,
                          canRequestFocus: false,
                          decoration: InputDecoration(
                              labelText: customerContact == null
                                  ? "Enter Customer Contact No."
                                  : "Customer Contact No.:"),
                          autocorrect: false,
                          onChanged: (val) => field
                              .didChange(num.tryParse(val) ?? customerContact),
                        );
                      },
                    ),
                    FormBuilderTextField(
                        autofocus: false,
                        name: 'Device Model',
                        initialValue: model,
                        canRequestFocus: false,
                        onChanged: (val) {
                          setState(() {
                            model = val;
                          });
                        },
                        decoration: InputDecoration(
                            labelText: isNullOREmpty(model)
                                ? "Enter Device Model"
                                : "Device Model:"),
                        keyboardType: TextInputType.text,
                        autovalidateMode: AutovalidateMode.onUnfocus,
                        autocorrect: false),
                    FormBuilderTextField(
                        autofocus: false,
                        name: 'Issue description',
                        canRequestFocus: false,
                        initialValue: issueDescription,
                        onChanged: (val) {
                          setState(() {
                            setState(() {
                              issueDescription = val;
                            });
                          });
                        },
                        decoration: InputDecoration(
                            labelText: isNullOREmpty(issueDescription)
                                ? "Enter Problem"
                                : "Problem:"),
                        keyboardType: TextInputType.text,
                        autovalidateMode: AutovalidateMode.onUnfocus,
                        autocorrect: false),
                    FormBuilderTextField(
                        autofocus: false,
                        canRequestFocus: false,
                        maxLines: 3,
                        name: 'Remarks',
                        initialValue: remarks,
                        onChanged: (val) {
                          setState(() {
                            remarks = val;
                          });
                        },
                        decoration: InputDecoration(
                            labelText: isNullOREmpty(remarks)
                                ? "Add Remarks"
                                : "Remarks:"),
                        keyboardType: TextInputType.multiline,
                        autovalidateMode: AutovalidateMode.onUnfocus,
                        autocorrect: false),
                    FormBuilderField<num>(
                      name: "Estimated Cost.",
                      initialValue: estimatedCost,
                      onChanged: (val) {
                        setState(() {
                          estimatedCost = val;
                        });
                      },
                      builder: (FormFieldState<num> field) {
                        return TextField(
                          autofocus: false,
                          controller: _estimatedCostController,
                          keyboardType: TextInputType.number,
                          canRequestFocus: false,
                          decoration: InputDecoration(
                              labelText: estimatedCost == null
                                  ? "Enter Estimated Cost (in Rs.):"
                                  : "Estimated Cost (in Rs.):"),
                          autocorrect: false,
                          onChanged: (val) =>
                              field.didChange(num.tryParse(val) ?? 0),
                        );
                      },
                    ),
                    FormBuilderField<num>(
                      name: "Advance paid.",
                      initialValue: advancedPaid,
                      onChanged: (val) {
                        setState(() {
                          advancedPaid = val ?? 0;
                        });
                      },
                      builder: (FormFieldState<num> field) {
                        return TextField(
                          autofocus: false,
                          canRequestFocus: false,
                          controller: _advancePaidController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              labelText: advancedPaid == 0
                                  ? "Enter advance paid (in Rs.):"
                                  : "Advance Paid (in Rs.):"),
                          autocorrect: false,
                          onChanged: (val) =>
                              field.didChange(num.tryParse(val) ?? 0),
                        );
                      },
                    ),
                    FormBuilderDropdown<ScreenLockType>(
                        autofocus: false,
                        name: "ScreenLock Type",
                        initialValue: screenLockType,
                        decoration: InputDecoration(
                            labelText: screenLockType == null
                                ? "Select Screen Lock Type"
                                : "Screen Lock Type:"),
                        items: ScreenLockType.values
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.name),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            screenLockType = value ?? ScreenLockType.NONE;
                          });
                        }),
                    screenLockType == ScreenLockType.PASSWORD ||
                            screenLockType == ScreenLockType.PIN
                        ? FormBuilderTextField(
                            name: 'Screen Lock',
                            canRequestFocus: false,
                            initialValue: screenLock,
                            onChanged: (val) {
                              setState(() {
                                screenLock = val;
                              });
                            },
                            decoration: InputDecoration(
                                labelText: isNullOREmpty(screenLock)
                                    ? screenLockType == ScreenLockType.PASSWORD
                                        ? "Enter Password"
                                        : screenLockType == ScreenLockType.PIN
                                            ? "Enter Pin"
                                            : ""
                                    : screenLockType == ScreenLockType.PASSWORD
                                        ? "Password"
                                        : screenLockType == ScreenLockType.PIN
                                            ? "PIN"
                                            : "Screen Lock"),
                            keyboardType:
                                screenLockType == ScreenLockType.PASSWORD
                                    ? TextInputType.text
                                    : screenLockType == ScreenLockType.PIN
                                        ? TextInputType.number
                                        : TextInputType.text,
                            autovalidateMode: AutovalidateMode.onUnfocus,
                            autocorrect: false,
                            autofocus: false)
                        : const SizedBox(),
                    FormBuilderCheckboxGroup(
                      name: "Items Collected",
                      options: ItemType.values
                          .map((e) => FormBuilderFieldOption<ItemType>(
                                value: e,
                                child: Text(e.name),
                              ))
                          .toList(),
                      initialValue: itemsList,
                      onChanged: (values) {
                        setState(() {
                          itemsList = values ?? [];
                        });
                      },
                      decoration: InputDecoration(
                          labelText: itemsList.isEmpty
                              ? "Select Items collected"
                              : "Items Collected"),
                    ),
                    if (!isExistingOrder)
                      SizedBox(
                        height: 48.h,
                        child: Center(
                          child: ElevatedButton(
                              autofocus: false,
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ImagePickerPage(
                                            singleImage: true,
                                            onPick: (List<XFile> images) {
                                              if (mounted &&
                                                  images.isNotEmpty) {
                                                setState(() {
                                                  image = images.first;
                                                });
                                              }
                                            },
                                          ))),
                              child: Text(
                                  image == null
                                      ? "Add image"
                                      : "Re-upload image",
                                  style: MontserratFont.paragraphReg1)),
                        ),
                      ),
                    if (image != null) Image.file(File(image!.path))
                  ],
                ),
              ),
            )
          : Center(child: CircularProgressIndicator()),
      floatingActionButton: showButton()
          ? FloatingActionButton(
              onPressed: showButton()
                  ? isExistingOrder
                      ? updateOrder
                      : createOrder
                  : null,
              child: const Icon(Icons.save))
          : null,
    );
  }

  bool showButton() {
    bool imageCheck = isExistingOrder || image != null;
    return !isNullOREmpty(customerName) &&
        !isNullOREmpty(customerContact.toString()) &&
        customerContact != 0 &&
        customerContact.toString().length == 10 &&
        !isNullOREmpty(model) &&
        !isNullOREmpty(issueDescription) &&
        !isNullOREmpty(estimatedCost.toString()) &&
        estimatedCost != 0 &&
        itemsList.isNotEmpty &&
        imageCheck &&
        !loading;
  }

  void updateOrder() async {
    if (mounted) {
      setState(() {
        loading = true;
      });
    }
    //create a map from fields.
    Map<dynamic, dynamic> fieldsMap = {
      'status': orderState!.name,
      'customer_name': customerName,
      'customer_contact': customerContact.toString(),
      'model': model,
      'issue_description': issueDescription,
      'remarks': remarks,
      'estimated_cost': estimatedCost,
      'advance_amount': advancedPaid,
      'screenlock_type': screenLockType?.name,
      'screenlock': screenLock ?? "",
      'items_list': "{${itemsList.map((e) => e.name).join(",")}}"
    };

    var res =
        await OrderService().updateOrder(widget.givenOrder!.id, fieldsMap);
    res.onSuccess((success) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Order updated!"),
      ));
      Navigator.pop(context);
    });
    res.onFailure((failure) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error: $failure"),
      ));
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    });
  }

  void createOrder() async {
    if (mounted) {
      setState(() {
        loading = true;
      });
    }
    //create a map from fields.
    Map<dynamic, dynamic> fieldsMap = {
      'status': orderState!.name,
      'customer_name': customerName,
      'customer_contact': customerContact.toString(),
      'model': model,
      'issue_description': issueDescription,
      'remarks': remarks,
      'estimated_cost': estimatedCost,
      'advance_amount': advancedPaid,
      'screenlock_type': screenLockType?.name,
      'screenlock': screenLock ?? "",
      'items_list': "{${itemsList.map((e) => e.name).join(",")}}"
    };

    var res = await OrderService().createOrder(fieldsMap);
    res.onSuccess((success) async {
      await OrderService()
          .upsertImage(success.id, File(image!.path), image!.name);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Order created! Order No.: ${success.jobId}"),
      ));
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return OrderDetailsPage(orderId: success.id, jobId: success.jobId!);
      })).then((val) {
        Navigator.pop(context);
      });
    });
    res.onFailure((failure) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error: $failure"),
      ));
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    });
  }
}
