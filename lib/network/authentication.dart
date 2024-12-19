import 'package:flutter/cupertino.dart';
import 'package:result_dart/result_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vandana_app/model/user_entity.dart';

class Authentication {
  final supabase = Supabase.instance.client;
  Future<Result<AuthResponse>> signInWithEmail(
      String email, String password) async {
    try {
      AuthResponse res = await supabase.auth
          .signInWithPassword(email: email, password: password);
      final UserEntity user = await getUser(email);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      //store user to sharedStorage.
      prefs.setString("name", user.name);
      prefs.setString("email", user.email);
      prefs.setBool("admin", user.admin);
      return Success(res);
    } on Exception catch (_) {
      rethrow;
    }
  }

  Future<Result<Session>> getSessionDetails() async {
    var currSession = supabase.auth.currentSession;
    if (currSession != null) {
      if (currSession.isExpired) {
        try {
          var res =
              await supabase.auth.refreshSession(currSession.refreshToken);
          currSession = res.session!;
        } on Exception catch (e) {
          debugPrint(e.toString());
          rethrow;
        }
      }
      final UserEntity user = await getUser(currSession.user.email!);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      //store user to sharedStorage.
      prefs.setString("name", user.name);
      prefs.setString("email", user.email);
      prefs.setBool("admin", user.admin);
      return Success(currSession);
    } else {
      print("No session");
      throw Exception("No session");
    }
  }

  Future<UserEntity> getUser(String email) async {
    try {
      final List<Map<String, dynamic>> data =
          await supabase.from("users").select("*").eq("email", email);
      return UserEntity.fromList(data).first;
    } on Exception catch (e) {
      throw AuthException(e.toString());
    }
  }

  void logout() {
    supabase.auth.signOut(scope: SignOutScope.local);
  }
}
