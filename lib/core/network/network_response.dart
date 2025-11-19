import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:weather/core/network/api_request.dart';

class NetworkResponse<T> {
  final int statusCode;
  final T model;

  NetworkResponse({
    required this.statusCode,
    required this.model,
  });
}
