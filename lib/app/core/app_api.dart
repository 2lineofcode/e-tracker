import 'package:ex_kit/ex.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../env.g.dart';
import 'app_setting.dart';
import 'const.dart';

/// * handy call api -> supabase
final db = Supabase.instance.client;

/// * handy call api -> bibit
final _bibitUrl = Env.bibitApiUrl;
final apiBibit = Get.find<ExHttp>(tag: 'bibit')
  ..httpClient.timeout = 15.seconds
  ..httpClient.addAuthenticator<void>((request) async {
    await pref.erase();
    await ExHttp().post(
      '$_bibitUrl/auth/token',
      body: {
        'refresh_id': Env.bibitRefreshId,
        'refresh_token': Env.bibitRefreshToken,
      },
    ).then((response) async {
      final token = response.body['data']['token']['access_token'];
      final rToken = response.body['data']['token']['refresh_token'];
      await pref.write(kBibitToken, token);
      await pref.write(kBibitRefreshToken, rToken);

      request.headers['authorization'] = 'Bearer $token';
      logI('TOKEN REFRESHED!');
    });

    return request;
  })
  ..httpClient.addResponseModifier<void>((request, response) async {
    if (response.statusCode == 200) {
      logS('${request.method.toUpperCase()}: ${request.url} (${response.statusCode})', name: 'API');
    } else {
      logW('${request.method.toUpperCase()}: ${request.url} (${response.statusCode})', name: 'API');
    }
    return response;
  })
  ..httpClient.addRequestModifier<void>(
    (request) async {
      final baseHeader = {'Origin': '$_bibitUrl', 'Referer': '$_bibitUrl/'};
      request.headers['authorization'] = 'Bearer ${await pref.read(kBibitToken)}';
      request.headers.addAll(baseHeader);
      return request;
    },
  );

/// * handy call api -> mdvk
final apiMdvk = Get.find<ExHttp>(tag: 'mdvk')
  ..httpClient.timeout = 15.seconds
  ..httpClient.addResponseModifier((request, response) {
    if (response.statusCode == 200) {
      logS('${request.method.toUpperCase()}: ${request.url} (${response.statusCode})', name: 'API');
    } else {
      logW('${request.method.toUpperCase()}: ${request.url} (${response.statusCode})', name: 'API');
    }
    return response;
  });
