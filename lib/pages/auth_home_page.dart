import 'package:flutter/material.dart';
import 'package:result_dart/result_dart.dart';
import 'package:vandana_app/network/order_service.dart';
import 'package:vandana_app/pages/orders_page.dart';

class AuthHomePage extends StatelessWidget {
  final VoidCallback logoutCallback;
  const AuthHomePage({super.key, required this.logoutCallback});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  ElevatedButton(
                      onPressed: () => Navigator.push(context,
                            MaterialPageRoute(builder: (context) => const ViewOrdersPage())),
                      child: const Text("View orders")),
                  const ElevatedButton(
                      onPressed: null, child: Text("Create new order")),
                  const ElevatedButton(
                    onPressed: null,
                    child: Text("Settings"),
                  ),
                ],
              ),
              ElevatedButton(
                  onPressed: () => logoutCallback(),
                  child: const Text("Logout"))
            ],
          ),
        ),
      ),
    );
  }
}
