import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class NetworkResponse<T> {
  final int statusCode;
  final T model;

  NetworkResponse({
    required this.statusCode,
    required this.model,
  });

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}
