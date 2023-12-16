import 'dart:io';

import 'package:ex/ex.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'const.dart';

/// handy call supabase
final db = Supabase.instance.client;

/// handy call sharedpref
final pref = GetStorage();

/// handy call api
final _bibitUrl = dotenv.get('BIBIT_API_URL');
final api = Get.find<ExHttp>(tag: 'bibit')
  ..httpClient.addAuthenticator<void>((request) async {
    logW('== REFRESH TOKEN ==');
    await pref.erase();
    final response = await ExHttp().post(
      '$_bibitUrl/auth/token',
      body: {
        'refresh_id': dotenv.get('BIBIT_DEFAULT_REFRESH_ID'),
        'refresh_token': dotenv.get('BIBIT_DEFAULT_REFRESH_TOKEN'),
      },
    );
    final token = response.body['data']['token']['access_token'];
    final rToken = response.body['data']['token']['refresh_token'];
    await pref.write(kBibitToken, token);
    await pref.write(kBibitRefreshToken, rToken);

    request.headers['authorization'] = 'Bearer $token';
    logI('TOKEN REFRESHED!');

    return request;
  })
  ..httpClient.addRequestModifier<void>((request) async {
    final baseHeader = {'Origin': '$_bibitUrl', 'Referer': '$_bibitUrl/'};
    request.headers[HttpHeaders.authorizationHeader] = 'Bearer ${await pref.read(kBibitToken)}';
    request.headers.addAll(baseHeader);
    return request;
  });
