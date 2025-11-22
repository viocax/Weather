
class NetworkResponse<T> {
  final int statusCode;
  final T model;

  NetworkResponse({
    required this.statusCode,
    required this.model,
  });
}
