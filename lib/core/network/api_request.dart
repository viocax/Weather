import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:weather/core/network/network_response.dart';

enum ParameterEncoding {
  url,      // 參數放在 URL query string
  json,     // 參數放在 body，以 JSON 格式
  formData, // 參數放在 body，以 form-data 格式
}

mixin ApiRequestMixin<T> {
  String get baseUrl;
  String get path;
  String get method; // GET, POST, PUT, DELETE, PATCH
  Map<String, String>? get headers => null;
  Map<String, dynamic>? get parameters => null;
  ParameterEncoding get parameterEncoding => ParameterEncoding.url;

  http.Request createRequest() {
    Uri uri = Uri.parse('$baseUrl/$path');
  
    // 設定 body
      switch (parameterEncoding) {
        case ParameterEncoding.json:
          final request = http.Request(method, uri);
          request.headers['Content-Type'] = 'application/json';
          if (parameters != null) {
            request.body = json.encode(parameters);
          }
          return request;
        case ParameterEncoding.formData:
          final request = http.Request(method, uri);
          request.headers['Content-Type'] = 'application/x-www-form-urlencoded';
          if (parameters != null) {
            request.bodyFields = parameters!.map(
              (key, value) => MapEntry(key, value.toString()),
            );
          }
          return request;
        case ParameterEncoding.url:
          if (parameters != null) {
            uri = uri.replace(
              queryParameters: parameters!.map(
                (key, value) => MapEntry(key, value.toString()),
              ),
            );
          }
          return http.Request(method, uri);
      }
  }

  T convert(Map<String, dynamic> dictionary);

  Future<NetworkResponse<T>> request() async  {
    try {
      final httpRequest = createRequest();
      final response = await http.Response.fromStream(
        await httpRequest.send()
      );
      Map<String, dynamic> dictionary = json.decode(response.body);
      debugPrint('API Response: $dictionary');
      T decodeModel = convert(dictionary);
      return NetworkResponse(
          statusCode: response.statusCode,
          model: decodeModel
        );

    } catch (error) {
      rethrow;
    }
  }
}