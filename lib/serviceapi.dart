import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:speakapp/config.dart';

Future callapi_getname(publickey) async {
  return await http
      .get(
        Uri.parse(AppConfig.urlapi + "get_key_accounts/${publickey}"),
      )
      .timeout(Duration(seconds: AppConfig.timeout));
}

Future callapi_getbalance(name) {
  return http
      .get(
        Uri.parse(AppConfig.urlapi + "get_account_tokens/${name}"),
      )
      .timeout(Duration(seconds: AppConfig.timeout));
}

Future callapi_getlistfriend() {
  var databody = jsonEncode({
    "code": "speakapp",
    "scope": "speakapp",
    "table": "messages",
    "limit": 100,
    "reverse": true,
    "show_payer": false,
    "json": true
  });

  return http
      .post(
        Uri.parse(AppConfig.urlapi_v2 + "get_table_rows"),
        body: databody,
      )
      .timeout(Duration(seconds: AppConfig.timeout));
}

Future callapi_getaccount(accountname) {
  return http
      .get(
        Uri.parse(AppConfig.urlapi + "get_account/${accountname}"),
      )
      .timeout(Duration(seconds: AppConfig.timeout));
}
