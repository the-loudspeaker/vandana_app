import 'dart:io';

import 'package:result_dart/result_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  Future<Result<String, String>> upsertImage(
      String orderId, File image, String destFileName) async {
    try {
      final String fullPath =
          await supabase.storage.from(Constants.imageBucket).upload(
                '${Constants.orderImagesFolder}/$orderId/$destFileName',
                image,
                fileOptions: const FileOptions(upsert: true),
              );
      return Success(fullPath);
    } on Exception catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<List<FileObject>, String>> getImages(String orderId) async {
    try {
      final imageList = await supabase.storage
          .from(Constants.imageBucket)
          .list(path: "${Constants.orderImagesFolder}/$orderId");
      return Success(imageList);
    } on Exception catch (e) {
      return Failure(e.toString());
    }
  }

  String? getPublicUrl(String path) {
    try {
      return supabase.storage.from(Constants.imageBucket).getPublicUrl(path);
    } on Exception catch (_) {
      return null;
    }
  }

  Future<Result<Order, String>> updateOrder(
      String id, Map<dynamic, dynamic> fieldsMap) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      Map<String, String> modifiedByMap = {
        'modified_by': prefs.getString('name') ?? ""
      };
      fieldsMap.addAll(modifiedByMap);
      var data =
          await supabase.from("orders").update(fieldsMap).eq('id', id).select();
      if (data.isEmpty) throw Exception("No order found");
      return Success(Order.fromMap(data.first));
    } on Exception catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<Order, String>> createOrder(
      Map<dynamic, dynamic> fieldsMap) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      Map<String, String> createdByModifiedByMap = {
        'created_by': prefs.getString('name') ?? "",
        'modified_by': prefs.getString('name') ?? ""
      };
      fieldsMap.addAll(createdByModifiedByMap);
      var data = await supabase.from("orders").insert(fieldsMap).select();
      if (data.isEmpty) throw Exception("Unable to create Order");
      return Success(Order.fromMap(data.first));
    } on Exception catch (e) {
      print(e);
      if (e.toString().contains("estimated_cost")) {
        return const Failure("Check Estimated Cost");
      }
      return Failure(e.toString());
    }
  }
}
