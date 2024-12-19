import 'package:flutter/material.dart';
import 'package:result_dart/result_dart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vandana_app/network/authentication.dart';
import 'package:vandana_app/utils/utils.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback loginCallback;
  final bool authenticated;
  const LoginPage(
      {super.key, required this.loginCallback, required this.authenticated});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? email;
  String? password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("Login", context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Enter email & password",
            ),
            const SizedBox(height: 8),
            TextField(
              onSubmitted: null,
              onChanged: (input) {
                setState(() {
                  email = input;
                });
              },
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: "email"),
            ),
            TextField(
              obscureText: true,
              onSubmitted: (input) => signInUser(),
              onChanged: (input) {
                setState(() {
                  password = input;
                });
              },
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: "password"),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
                onPressed: signInUser,
                child: !widget.authenticated
                    ? const Text("Login")
                    : const Text("Logged in!"))
          ],
        ),
      ),
    );
  }

  signInUser() async {
    if (email != null &&
        password != null &&
        email!.isNotEmpty &&
        password!.isNotEmpty) {
      try {
        Result<AuthResponse> res =
            await Authentication().signInWithEmail(email!, password!);
        res.getOrThrow();
        widget.loginCallback();
      } on Exception catch (e) {
        if (mounted) {
          if (e.runtimeType == AuthApiException) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Check email & password"),
            ));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(e.toString()),
            ));
          }
        }
      }
    }
  }
}
