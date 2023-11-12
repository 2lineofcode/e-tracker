import 'package:ex/ex.dart';
import 'package:flutter/material.dart';
import 'package:uuid/v4.dart';

import '../helpers/helper_misc.dart';
import '../models/category_entity.dart';

mixin DBGenerator {

  static CategoryEntity category(String name, IconData icon) {
    return CategoryEntity(
      id: UuidV4().generate(),
      createdAt: DateTime.now().toStringEx(),
      name: '$name',
      color: Vx.randomPrimaryColor.toHex(),
      icon: icon.setIconData(),
    );
  }
}
