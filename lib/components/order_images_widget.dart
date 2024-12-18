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
  @override
  void initState() {
    fetchImages(widget.orderId);
    super.initState();
  }

  Future<List<String>> fetchImages(String orderId) async {
    var res = await OrderService().getImages(orderId);
    if (res.isSuccess()) {
      var success = res.getOrElse((_) {
        return List.empty();
      });
      if (success.isNotEmpty && mounted) {
        return success
            .map((r) => OrderService().getPublicUrl(
                "${Constants.orderImagesFolder}/$orderId/${r.name}"))
            .where((link) => link != null)
            .map((link) => link!)
            .toList();
      }
    }
    return List.empty();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchImages(widget.orderId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
              return const Center(child: CircularProgressIndicator());
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Text(
                  'Error loading images',
                  textAlign: TextAlign.center,
                );
              } else {
                List<String> images = snapshot.data ?? List.empty();
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
        });
  }
}
