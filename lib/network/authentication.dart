import 'package:flutter/cupertino.dart';
import 'package:result_dart/result_dart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Authentication {
  final supabase = Supabase.instance.client;
  Future<Result<AuthResponse, Error>> signInWithEmail(String email, String password) async {
    try {
      AuthResponse res = await supabase.auth.signInWithPassword(
          email: email,
          password: password
      );
      return Success(res);
    } on AuthException catch (e) {
      print(e.message);
      return Failure(Error());
    }
  }

  Session? getSessionDetails(){
    var currSession = supabase.auth.currentSession;
    if(currSession!=null){
      if(currSession.isExpired){
        try {
          supabase.auth.refreshSession(currSession.refreshToken);
        } on Exception catch (e) {
          debugPrint(e.toString());
          return null;
        }
      }
      return currSession;
    }
    return null;
  }
  void logout(){
    supabase.auth.signOut(scope: SignOutScope.local);
  }
}