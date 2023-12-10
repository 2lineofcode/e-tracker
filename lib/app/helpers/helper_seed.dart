import 'package:ex/ex.dart';
import 'package:uuid/v4.dart';

import '../core/app_base.dart';
import '../models/category_entity.dart';

mixin SeedHelper {
  static void genCategory() async {
    /// check if category table is empty
    final check = await db.from('category').select().withConverter<List<CategoryEntity>>((data) {
      return (data as List).map((e) => CategoryEntity.fromJson(e)).toList();
    });

    /// if category table is empty just return~
    if (check.isNotEmpty) return;

    /// category table is empty, seed data
    final _catFood = CategoryEntity(
      id: UuidV4().generate(),
      name: 'Food',
      icon: 'code=58566&family=FontAwesomeSolid&pack=font_awesome_flutter',
      color: '#ffb7bdb9',
      maxBudget: 1000000,
      createdAt: DateTime.now().toStringEx(),
    ).toJson();
    final _catNotes = CategoryEntity(
      id: UuidV4().generate(),
      name: 'Notes',
      icon: 'code=63033&family=CupertinoIcons&pack=cupertino_icons',
      color: '#ffffffff',
      maxBudget: 1000000,
      createdAt: DateTime.now().toStringEx(),
    ).toJson();
    final _catOthers = CategoryEntity(
      id: UuidV4().generate(),
      name: 'Others',
      color: Vx.purpleHex200,
      createdAt: DateTime.now().toStringEx(),
    ).toJson();

    await db.from('category').insert([_catFood, _catNotes, _catOthers]);
  }
}
