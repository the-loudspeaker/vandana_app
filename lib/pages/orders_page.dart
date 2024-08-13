import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:result_dart/result_dart.dart';
import 'package:vandana_app/model/order_entity.dart';
import 'package:vandana_app/network/order_service.dart';

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
      appBar: AppBar(
        title: const Text("Orders"),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: !isLoading
          ? Padding(
              padding: EdgeInsets.all(24.h),
              child: RefreshIndicator(
                  onRefresh: fetchOrders, child: OrderList(orders: orders)),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> fetchOrders() async {
    setState(() {
      isLoading = true;
    });
    var resp = OrderService().getOrdersList();
    resp.onSuccess((success) {
      if(mounted){
        setState(() {
          orders = success;
          isLoading = false;
        });
      }
    });
    resp.onFailure((failure) {
      if(mounted){
        setState(() {
          isLoading = false;
        });
      }
    });
  }
}

class OrderList extends StatelessWidget {
  final List<Order> orders;
  const OrderList({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    return orders.isNotEmpty
        ? ListView.separated(
            itemCount: orders.length,
            itemBuilder: (context, index) =>
                OrderListWidget(order: orders[index]),
            separatorBuilder: (BuildContext context, int index) {
              return const Divider();
            },
          )
        : const Text("No orders.");
  }
}

class OrderListWidget extends StatelessWidget {
  final Order order;
  const OrderListWidget({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(order.model),
      subtitle: Text(
        order.issueDescription,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [Text(order.status), Text(order.poc)],
      ),
      leading: Text(order.jobId.toString()),
      style: ListTileStyle.list,
      visualDensity: VisualDensity.comfortable,
    );
  }
}
