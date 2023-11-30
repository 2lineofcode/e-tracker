import 'package:flutter/cupertino.dart';

class BibitRepository {
  List<Map<String, Object>> menuList() {
    return [
      {'icon': CupertinoIcons.home, 'name': 'Home'},
      {'icon': CupertinoIcons.app_badge_fill, 'name': 'Portfolio'},
      {'icon': CupertinoIcons.flame_fill, 'name': 'Explore'},
    ];
  }
}
