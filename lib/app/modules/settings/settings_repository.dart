import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uicons_pro/uicons_pro.dart';

import '../../core/app_api.dart';
import '../../models/supa_category_entity.dart';
import '../../models/supa_recurring_expense_entity.dart';
import '../../models/supa_user_profile_entity.dart';

mixin SectionMenu {
  static const APP_CONFIG = 'Umum';
  static const REPEAT_SETTING = 'Transaksi Rutin';
  static const IMPORT_EXPORT = 'Data & Backup';
}

class SettingsRepository {
  Future<List<Map<String, dynamic>>> getMenuList() async {
    return [
      {
        'label': SectionMenu.APP_CONFIG,
        'icon': UIconsPro.solidRounded.settings,
      },
      {
        'label': SectionMenu.REPEAT_SETTING,
        'icon': UIconsPro.solidRounded.calendar_clock,
      },
      {
        'label': SectionMenu.IMPORT_EXPORT,
        'icon': UIconsPro.solidRounded.file_export,
      },
    ];
  }

  /// ------------------------------------------------------------------------
  /// ! count data
  /// ------------------------------------------------------------------------
  Future<int> countExpense() async {
    if (currentUserId == null) return 0;
    final response = await db
        .from('expense')
        .count()
        .eq('user_id', currentUserId!);
    return response;
  }

  Future<int> countCategory() async {
    return expenseCategoryList.length;
  }

  /// ------------------------------------------------------------------------
  /// ! storage
  /// ------------------------------------------------------------------------
  Future<List<FileObject>> getBackupList() async {
    if (currentUserId == null) return [];

    const pageSize = 100;
    final files = <FileObject>[];
    while (true) {
      final page = await db.storage.from('backup').list(
        searchOptions: SearchOptions(
          limit: pageSize,
          offset: files.length,
          sortBy: SortBy(column: 'created_at', order: 'desc'),
        ),
      );
      files.addAll(page);
      if (page.length < pageSize) return files;
    }
  }

  /// ------------------------------------------------------------------------
  /// ! profile
  /// ------------------------------------------------------------------------
  ///
  Future<List<SupaUserProfile>> getUserProfile() async {
    if (currentUserId == null) return [];
    final response =
        await db //
            .from('profiles')
            .select()
            .eq('id', currentUserId!)
            .withConverter<List<SupaUserProfile>>((data) {
              return (data).map((e) => SupaUserProfile.fromJson(e)).toList();
            });
    return response;
  }

  // editProfile
  Future<void> editProfile(SupaUserProfile entity) async {
    if (currentUserId == null) return;
    final response =
        await db //
            .from('profiles')
            .update(entity.toJson())
            .eq('id', currentUserId!);
    return response;
  }

  /// ------------------------------------------------------------------------
  /// ! admin
  /// ------------------------------------------------------------------------
  Future<List<SupaRecurringExpense>> getRecurringExpenses() async {
    if (currentUserId == null) return [];
    return await db
        .from('recurring_expenses')
        .select()
        .eq('user_id', currentUserId!)
        .isFilter('archived_at', null)
        .order('created_at')
        .withConverter<List<SupaRecurringExpense>>(
          (data) => data.map((e) => SupaRecurringExpense.fromJson(e)).toList(),
        );
  }

  Future<void> addRecurringExpense(SupaRecurringExpense entity) async {
    if (currentUserId == null) return;
    await db.from('recurring_expenses').insert(entity.toJson());
  }

  Future<void> archiveRecurringExpense(String id) async {
    if (currentUserId == null) return;
    await db
        .from('recurring_expenses')
        .update({
          'active': false,
          'archived_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .eq('user_id', currentUserId!);
  }

  Future<num> sumAllExpense() async {
    if (currentUserId == null) return 0;
    return await db.rpc('sum_own_expenses') as num? ?? 0;
  }
}
