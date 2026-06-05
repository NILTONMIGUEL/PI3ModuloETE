import 'package:dio/dio.dart';

abstract interface class IHttpClient {
  Future get({required url, Map<String, dynamic>? headers});
  Future post({
    required url,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? data,
  });

  Future put({
    required url,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? data,
  });

  Future patch({
    required url,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? data,
  });

  Future delete({
    required url,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? data,
  });
}


class DioClient implements IHttpClient {
  final Dio client;

  DioClient(this.client);

  @override
  Future get({required url, Map<String, dynamic>? headers}) async {
    return await client.get(url, options: Options(headers: headers));
  }

  @override
  Future post({
    required url,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? data,
  }) async {
    return await client.post(
      url,
      data: data,
      options: Options(headers: headers),
    );
  }

  @override
  Future delete({
    required url,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? data,
  }) async {
    return await client.delete(
      url,
      data: data,
      options: Options(headers: headers),
    );
  }

  @override
  Future patch({
    required url,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? data,
  }) async {
    return await client.patch(
      url,
      data: data,
      options: Options(headers: headers),
    );
  }

  @override
  Future put({
    required url,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? data,
  }) async {
    return await client.patch(
      url,
      data: data,
      options: Options(headers: headers),
    );
  }
}