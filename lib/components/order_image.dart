import 'package:flutter/material.dart';
import 'package:vandana_app/network/order_service.dart';
import 'package:vandana_app/utils/constants.dart';
import 'package:vandana_app/utils/utils.dart';

class OrderImage extends StatefulWidget {
  final String orderId;
  const OrderImage({super.key, required this.orderId});

  @override
  State<OrderImage> createState() => _OrderImageState();
}

class _OrderImageState extends State<OrderImage> {
  String? imagePath;

  @override
  void initState() {
    fetchImages(widget.orderId);
    super.initState();
  }

  Future<void> fetchImages(String orderId) async {
    var res = await OrderService().getImages(orderId);
    res.onSuccess((success) {
      if (success.isNotEmpty) {
        setState(() {
          imagePath = OrderService().getPublicUrl(
              "${Constants.orderImagesFolder}/$orderId/${success.first.name}");
        });
      }
    });
    res.onFailure((failure) {});
  }

  @override
  Widget build(BuildContext context) {
    return !isNullOREmpty(imagePath)
        ? Image.network(imagePath!)
        : const SizedBox();
  }
}
