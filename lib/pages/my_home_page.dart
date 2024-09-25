import 'package:flutter/material.dart';
import 'package:result_dart/result_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vandana_app/network/authentication.dart';
import 'package:vandana_app/pages/login_page.dart';

import 'auth_home_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool authenticated = false;
  bool isLoading = false;

  @override
  void initState() {
    asyncInit();
    super.initState();
  }

  void asyncInit() async {
    setState(() {
      isLoading = true;
    });
    Result<Session, String> currSessionFuture =
        await Authentication().getSessionDetails();
    currSessionFuture.onSuccess((success) {
      showWelcomeSnackBar();
      setState(() {
        isLoading = false;
        authenticated = true;
      });
    });
    currSessionFuture.onFailure((failure) {
      setState(() {
        isLoading = false;
      });
    });
  }

  void showWelcomeSnackBar() async {
    var prefs = await SharedPreferences.getInstance();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Welcome ${prefs.getString("name")}!"),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return !isLoading
        ? !authenticated
            ? LoginPage(
                loginCallback: () {
                  showWelcomeSnackBar();
                  setState(() {
                    authenticated = true;
                  });
                },
                authenticated: authenticated,
              )
            : AuthHomePage(
                logoutCallback: () {
                  Authentication().logout();
                  setState(() {
                    authenticated = false;
                  });
                },
              )
        : const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
