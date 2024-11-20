import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vandana_app/model/order_entity.dart';
import 'package:vandana_app/network/order_service.dart';
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
  OrderState? orderState = OrderState.RECEIVED;
  String? customerName;
  num? customerContact;
  String? model;
  String? issueDescription;
  String? remarks;
  num? estimatedCost;
  ScreenLockType? screenLockType = ScreenLockType.NONE;
  String? screenLock;
  List<ItemType> itemsList = List.empty(growable: true);
  final TextEditingController _estimatedCostController =
      TextEditingController();
  final TextEditingController _customerContactController =
      TextEditingController();

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
          context,
          actions: [
            IconButton(
                onPressed: showButton()
                    ? isExistingOrder
                        ? updateOrder
                        : createOrder
                    : null,
                icon: const Icon(Icons.save))
          ]),
      body: SingleChildScrollView(
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
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e.name,
                                style: MontserratFont.heading4
                                    .copyWith(color: getOrderColor(e.name))),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      orderState = value ?? OrderState.RECEIVED;
                    });
                  }),
              const Divider(),
              FormBuilderTextField(
                  initialValue: customerName,
                  name: 'Customer Name',
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
                    decoration: InputDecoration(
                        labelText: customerContact == null
                            ? "Enter Customer Contact No."
                            : "Customer Contact No.:"),
                    autocorrect: false,
                    onChanged: (val) =>
                        field.didChange(num.tryParse(val) ?? customerContact),
                  );
                },
              ),
              FormBuilderTextField(
                  name: 'Device Model',
                  initialValue: model,
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
                  name: 'Issue description',
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
                  maxLines: 3,
                  name: 'Remarks',
                  initialValue: remarks,
                  onChanged: (val) {
                    setState(() {
                      remarks = val;
                    });
                  },
                  decoration: InputDecoration(
                      labelText:
                          isNullOREmpty(remarks) ? "Add Remarks" : "Remarks:"),
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
                    controller: _estimatedCostController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: estimatedCost == null
                            ? "Enter Estimated Cost (in Rs.):"
                            : "Estimated Cost (in Rs.):"),
                    autocorrect: false,
                    onChanged: (val) =>
                        field.didChange(num.tryParse(val) ?? estimatedCost),
                  );
                },
              ),
              FormBuilderDropdown<ScreenLockType>(
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
                      keyboardType: screenLockType == ScreenLockType.PASSWORD
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
              )
            ],
          ),
        ),
      ),
    );
  }

  bool showButton() {
    return !isNullOREmpty(customerName) &&
        !isNullOREmpty(customerContact.toString()) &&
        !isNullOREmpty(model) &&
        !isNullOREmpty(issueDescription) &&
        !isNullOREmpty(estimatedCost.toString()) &&
        itemsList.isNotEmpty;
  }

  void updateOrder() async {
    //create a map from fields.
    Map<dynamic, dynamic> fieldsMap = {
      'status': orderState!.name,
      'customer_name': customerName,
      'customer_contact': customerContact.toString(),
      'model': model,
      'issue_description': issueDescription,
      'remarks': remarks,
      'estimated_cost': estimatedCost,
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
    });
  }

  void createOrder() async {
    //create a map from fields.
    Map<dynamic, dynamic> fieldsMap = {
      'status': orderState!.name,
      'customer_name': customerName,
      'customer_contact': customerContact.toString(),
      'model': model,
      'issue_description': issueDescription,
      'remarks': remarks,
      'estimated_cost': estimatedCost,
      'screenlock_type': screenLockType?.name,
      'screenlock': screenLock ?? "",
      'items_list': "{${itemsList.map((e) => e.name).join(",")}}"
    };

    var res = await OrderService().createOrder(fieldsMap);
    res.onSuccess((success) {
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
    });
  }
}
