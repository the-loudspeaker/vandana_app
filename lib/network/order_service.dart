import 'dart:io';

import 'package:result_dart/result_dart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vandana_app/model/order_entity.dart';
import 'package:vandana_app/utils/constants.dart';

class OrderService {
  final supabase = Supabase.instance.client;

  Future<Result<List<Order>, String>> getOrdersList() async {
    try {
      final data = await supabase
          .from("orders")
          .select('*')
          .order("created_at", ascending: false);
      return Success(Order.fromList(data));
    } on Exception catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<Order, String>> getOrderById(String id) async {
    try {
      final data = await supabase.from("orders").select("*").eq("id", id);
      if (data.isEmpty) throw Exception("No order found");
      return Success(Order.fromMap(data.first));
    } on Exception catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<String, String>> uploadOrUpdateImage(
      File image, String destFileName) async {
    try {
      final String fullPath =
          await supabase.storage.from(Constants.imageBucket).upload(
                '${Constants.orderImagesFolder}/$destFileName',
                image,
                fileOptions: const FileOptions(upsert: true),
              );
      return Success(fullPath);
    } on Exception catch (e) {
      return Failure(e.toString());
    }
  }
}
