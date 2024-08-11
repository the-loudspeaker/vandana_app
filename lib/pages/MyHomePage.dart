import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vandana_app/network/Authentication.dart';
import 'package:vandana_app/pages/LoginPage.dart';

import 'OrdersPage.dart';

final supabase = Supabase.instance.client;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool authenticated = false;
  String? email;

  @override
  void initState() {
    var currSession = Authentication().getSessionDetails();
    if (currSession != null) {
      authenticated = true;
      email = currSession.user.email;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return !authenticated
        ? LoginPage(
            loginCallback: () {
              setState(() {
                authenticated = true;
              });
            },
            authenticated: authenticated,
          )
        : OrdersPage(
            logoutCallback: () {
              Authentication().logout();
              setState(() {
                authenticated = false;
              });
            },
          );
  }
}
