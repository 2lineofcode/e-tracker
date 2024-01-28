import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/app_api.dart';
import 'app_pages.dart';

class AppMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final isLoginned = db.auth.currentSession?.user.id != null;
    return isLoginned ? null : RouteSettings(name: Routes.LOGIN);
  }
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('404'),
        ],
      ),
    );
  }
}
