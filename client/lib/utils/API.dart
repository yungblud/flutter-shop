import 'dart:convert';
import 'package:client/models/CustomerHasItemResponse.dart';
import 'package:client/models/ProfileResponse.dart';
import 'package:http/http.dart' as http;
import 'package:client/utils/Global.dart';
import 'package:client/models/LoginResponse.dart';
import 'package:client/models/ItemResponse.dart';
import 'package:shared_preferences/shared_preferences.dart';

class API {
  static Future<void> register(
      String email, String name, String address, String password) async {
    return await post('/api/customers', {
      'values': json.encode({
        'email': email,
        'name': name,
        'address': address,
        'password': password,
      })
    });
  }

  static Future<LoginResponse> signIn(String email, String password) async {
    final res = await post('/api/login',
        {'type': 'CUSTOMER', 'loginId': email, 'password': password});

    return LoginResponse.fromJson(json.decode(res.body)['items'][0]);
  }

  static Future<List<ItemResponse>> fetchItems(
      Map<String, dynamic> query) async {
    final res = await get('/api/items', {'options': json.encode(query)}, null);
    return json
        .decode(res.body)['items']
        .map<ItemResponse>((item) => ItemResponse.fromJson(item))
        .toList();
  }

  static Future<List<CustomerHasItemResponse>> fetchCustomerItem(
      Map<String, dynamic> query) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final res = await get('/api/custom-has-items',
        {'options': json.encode(query)}, {'authorization': token});

    return json
        .decode(res.body)['items']
        .map<CustomerHasItemResponse>(
            (item) => CustomerHasItemResponse.fromJson(item))
        .toList();
  }

  static Future<ProfileResponse> fetchProfile(
      Map<String, dynamic> query) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final res = await get('/api/customers/', {'options': json.encode(query)},
        {'authorization': token});
    return ProfileResponse.fromJson(json.decode(res.body)['items'][0]);
  }

  static Future<http.Response> get(String path, Map<String, String> query,
      Map<String, String> headers) async {
    final uri = Uri(queryParameters: query);
    final res = await http.get(
        Global.localServerAddress + path + '?' + uri.query,
        headers: headers != null ? headers : null);
    return requestTail(res);
  }

  static Future<http.Response> post(
      String path, Map<String, String> body) async {
    final res = await http.post(Global.localServerAddress + path, body: body);

    return requestTail(res);
  }

  static http.Response requestTail(http.Response res) {
    if (res.statusCode ~/ 100 == 2) {
      return res;
    }
    throw ServerApiException(res);
  }
}

class ServerApiException implements Exception {
  http.Response response;
  ServerApiException(this.response);
}