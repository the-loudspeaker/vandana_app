import 'package:flutter/material.dart';
import 'package:vandana_app/network/order_service.dart';
import 'package:vandana_app/utils/constants.dart';

class OrderImagesWidget extends StatefulWidget {
  final String orderId;
  const OrderImagesWidget({super.key, required this.orderId});

  @override
  State<OrderImagesWidget> createState() => _OrderImagesWidgetState();
}

class _OrderImagesWidgetState extends State<OrderImagesWidget> {
  List<String> images = List.empty(growable: true);

  @override
  void initState() {
    fetchImages(widget.orderId);
    super.initState();
  }

  Future<void> fetchImages(String orderId) async {
    var res = await OrderService().getImages(orderId);
    res.onSuccess((success) {
      if (success.isNotEmpty) {
        if (mounted) {
          setState(() {
            images = success
                .map((r) => OrderService().getPublicUrl(
                    "${Constants.orderImagesFolder}/$orderId/${r.name}"))
                .where((link) => link != null)
                .map((link) => link!)
                .toList();
          });
        }
      }
    });
    res.onFailure((failure) {
      if (mounted) {
        images = List.empty(growable: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return images.isNotEmpty
        ? ListView.separated(
            primary: false,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Image.network(images[index]);
            },
            separatorBuilder: (context, index) => const Divider(),
            itemCount: images.length)
        : const SizedBox();
  }
}
