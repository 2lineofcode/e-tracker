import 'package:ex/ex.dart';
import 'package:get/get.dart';

import 'app_base.dart';
import 'const.dart';

class AppSettingService extends GetxService {
  @override
  Future<void> onReady() async {
    await checkAndApplyDefaultAppConfig();
    super.onReady();
  }

  // ------------------------------------------------------------------------
  // if new user: setup default app config
  // ------------------------------------------------------------------------
  Future<void> checkAndApplyDefaultAppConfig() async {
    if (!pref.hasData(kFlagEco) || //
        !pref.hasData(kFlagAverage) ||
        !pref.hasData(kFlagSpender) ||
        !pref.hasData(kCurrencySymbol) ||
        !pref.hasData(kIsDarkMode)) {
      await pref.write(kFlagEco, 50000);
      await pref.write(kFlagAverage, 100000);
      await pref.write(kFlagSpender, 100000);
      await pref.write(kCurrencySymbol, 'Rp. ');
      await pref.write(kIsDarkMode, true);
      logI('-- CONFIG CREATED --');
    }
  }
}
