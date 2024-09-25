import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vandana_app/utils/custom_fonts.dart';

AppBar customAppBar(String title, BuildContext context) {
  return AppBar(
    title: Text(title),
    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
  );
}

String formatDate(DateTime dateTime) {
  dateTime = dateTime.toLocal();
  return "${dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour == 0 ? "12" : dateTime.hour}:${dateTime.minute < 10 ? "0${dateTime.minute}" : dateTime.minute.toString()} ${dateTime.hour >= 12 ? "pm" : "am"} on ${dateTime.day}/${dateTime.month}/${dateTime.year}";
}

Row infoRow(String key, String value, {MainAxisAlignment? mainAxisAlignment}) {
  return Row(
    mainAxisAlignment: (mainAxisAlignment != null)
        ? mainAxisAlignment
        : MainAxisAlignment.spaceBetween,
    children: [
      Flexible(
          flex: 2, child: Text(key, style: MontserratFont.paragraphSemiBold1)),
      SizedBox(width: 4.w),
      Flexible(
          flex: 4,
          child: Text(value,
              style: MontserratFont.paragraphReg1,
              overflow: TextOverflow.ellipsis))
    ],
  );
}

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}

class NoScrollGlowBehaviour extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

bool isNullOREmpty(String? s) {
  return s == null || s.isEmpty || s == "null";
}

enum ItemType {
  HANDSET,
  BATTERY,
  BACKCOVER,
  HEADPHONE,
  CHARGER,
  MEMORY_CARD,
  SIM;

  factory ItemType.fromString(String value) {
    switch (value) {
      case 'HANDSET':
        return ItemType.HANDSET;
      case 'BATTERY':
        return ItemType.BATTERY;
      case 'BACKCOVER':
        return ItemType.BATTERY;
      case 'HEADPHONE':
        return ItemType.HEADPHONE;
      case 'CHARGER':
        return ItemType.CHARGER;
      case 'MEMORY_CARD':
        return ItemType.MEMORY_CARD;
      case 'SIM':
        return ItemType.SIM;
      default:
        throw Exception('Invalid enum value: $value');
    }
  }
}

enum OrderState {
  RECEIVED,
  NEED_SPARE,
  WAITING_CUSTOMER,
  INPROGRESS,
  COMPLETED,
  DELIVERED,
  CANCELLED,
  DELETED,
  REJECTED;

  factory OrderState.fromString(String value) {
    switch (value) {
      case "RECEIVED":
        return OrderState.RECEIVED;
      case "NEED_SPARE":
        return OrderState.NEED_SPARE;
      case "WAITING_CUSTOMER":
        return OrderState.WAITING_CUSTOMER;
      case "INPROGRESS":
        return OrderState.INPROGRESS;
      case "COMPLETED":
        return OrderState.COMPLETED;
      case "DELIVERED":
        return OrderState.DELIVERED;
      case "CANCELLED":
        return OrderState.CANCELLED;
      case "DELETED":
        return OrderState.DELETED;
      case "REJECTED":
        return OrderState.REJECTED;
      default:
        throw Exception('Invalid enum value: $value');
    }
  }
}

enum ScreenLockType {
  NONE,
  PASSWORD,
  PATTERN,
  PIN;

  factory ScreenLockType.fromString(String? value) {
    switch (value) {
      case 'NONE':
      case null:
        return ScreenLockType.NONE;
      case 'PASSWORD':
        return ScreenLockType.PASSWORD;
      case 'PATTERN':
        return ScreenLockType.PATTERN;
      case 'PIN':
        return ScreenLockType.PIN;
      default:
        throw Exception('Invalid enum value: $value');
    }
  }
}

Color getOrderColor(String state) {
  if (state == OrderState.RECEIVED.name) {
    return Colors.orange;
  } else if (state == OrderState.NEED_SPARE.name) {
    return Colors.red;
  } else if (state == OrderState.WAITING_CUSTOMER.name) {
    return Colors.cyan;
  } else if (state == OrderState.INPROGRESS.name) {
    return Colors.blue;
  } else if (state == OrderState.COMPLETED.name ||
      state == OrderState.DELIVERED.name) {
    return Colors.green;
  } else {
    return Colors.grey;
  }
}

extension ChunkExtension<T> on List<T> {
  List<List<T>> chunk(int size) {
    return List.generate(
      (length + size - 1) ~/ size,
      (index) => sublist(index * size, min(length, (index + 1) * size)),
    );
  }
}
