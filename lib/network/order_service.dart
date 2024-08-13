import 'package:flutter/cupertino.dart';
import 'package:result_dart/result_dart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vandana_app/model/order_entity.dart';

class OrderService{
  final supabase = Supabase.instance.client;

  Future<Result<List<Order>, Error>> getOrdersList() async {
    try {
      final data = await supabase.from("orders").select('*').order("created_at", ascending: false);
      return Success(Order.fromList(data));
    } on Exception catch (e) {
      debugPrint(e.toString());
      return Failure(Error());
    }
  }

}