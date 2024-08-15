import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vandana_app/model/order_entity.dart';
import 'package:vandana_app/network/order_service.dart';
import 'package:vandana_app/utils/custom_fonts.dart';
import 'package:vandana_app/utils/utils.dart';

import 'order_details.dart';

class ViewOrdersPage extends StatefulWidget {
  const ViewOrdersPage({super.key});

  @override
  State<ViewOrdersPage> createState() => _ViewOrdersPageState();
}

class _ViewOrdersPageState extends State<ViewOrdersPage> {
  List<Order> orders = List.empty();
  bool isLoading = true;

  @override
  void initState() {
    fetchOrders();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("Orders", context),
      body: !isLoading
          ? RefreshIndicator(
              onRefresh: fetchOrdersBg,
              child: OrderList(orders: orders, callback: () => fetchOrdersBg()))
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> fetchOrders() async {
    setState(() {
      isLoading = true;
    });
    var resp = await OrderService().getOrdersList();
    resp.onSuccess((success) {
      if (mounted) {
        setState(() {
          orders = success;
          isLoading = false;
        });
      }
    });
    resp.onFailure((failure) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  Future<void> fetchOrdersBg() async {
    var resp = await OrderService().getOrdersList();
    resp.onSuccess((success) {
      if (mounted) {
        setState(() {
          orders = success;
        });
      }
    });
  }
}

class OrderList extends StatelessWidget {
  final VoidCallback? callback;
  final List<Order> orders;
  const OrderList({super.key, required this.orders, this.callback});

  @override
  Widget build(BuildContext context) {
    return orders.isNotEmpty
        ? ListView.separated(
            primary: true,
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
            itemCount: orders.length,
            itemBuilder: (context, index) => OrderListWidget(
                order: orders[index], callback: callback!=null? () => callback!(): null),
            separatorBuilder: (BuildContext context, int index) {
              return const Divider();
            },
          )
        : const Text("No orders.");
  }
}

class OrderListWidget extends StatelessWidget {
  final VoidCallback? callback;
  final Order order;
  const OrderListWidget({super.key, required this.order, this.callback});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      OrderDetailsPage(orderId: order.id, jobId: order.jobId)))
          .then((value) => callback!=null? callback!(): null),
      title: Text(order.model),
      subtitle: Text(
        order.issueDescription,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            order.status,
            style: MontserratFont.heading4
                .copyWith(color: getOrderColor(order.status)),
          ),
          Text(order.poc)
        ],
      ),
      leading: Text(order.jobId.toString()),
      style: ListTileStyle.list,
      visualDensity: VisualDensity.comfortable,
    );
  }
}
