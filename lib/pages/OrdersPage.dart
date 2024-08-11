import 'package:flutter/material.dart';

class OrdersPage extends StatelessWidget {
  final VoidCallback logoutCallback;
  const OrdersPage({super.key, required this.logoutCallback});

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
                  ElevatedButton(onPressed: () {  },
                  child: const Text("View orders")),
                  const ElevatedButton(onPressed: null,
                  child: Text("Create order")),
                  const ElevatedButton(
                    onPressed: null,
                    child: Text("Settings"),
                  ),
                ],
              ),
              ElevatedButton(onPressed: ()=> logoutCallback(), child: const Text("Logout"))
            ],
          ),
        ),
      ),
    );
  }
}
