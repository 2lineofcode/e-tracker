import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/v4.dart';

import '../models/supa_expense_entity.dart';

Future<Object?> persistExpenseWithImage(
  SupabaseClient client,
  SupaExpense expense, {
  Uint8List? imageBytes,
  List<String> oldImagePaths = const [],
  required Future<void> Function(SupaExpense) writeExpense,
}) async {
  final bucket = client.storage.from('expense-images');
  String? uploadedImage;
  try {
    if (imageBytes != null) {
      if (expense.userId == null || expense.userId!.isEmpty) {
        throw StateError('Not signed in');
      }
      uploadedImage = '${expense.userId}/${expense.id}-${UuidV4().generate()}.jpg';
      await bucket.uploadBinary(uploadedImage, imageBytes,
        fileOptions: FileOptions(contentType: 'image/jpeg'));
      expense.imagePath = uploadedImage;
    }
    await writeExpense(expense);
  } catch (_) {
    if (uploadedImage != null) {
      try {
        final saved = await client.from('expense').select('image_path')
            .eq('id', expense.id!).maybeSingle();
        if (saved?['image_path'] != uploadedImage) {
          await bucket.remove([uploadedImage]);
        }
      } catch (_) {
        // Keep the upload when the database commit cannot be confirmed.
      }
    }
    rethrow;
  }
  final oldPaths = oldImagePaths.where((path) => path != expense.imagePath).toSet().toList();
  if (oldPaths.isNotEmpty) {
    try {
      await bucket.remove(oldPaths);
    } catch (e) {
      return e;
    }
  }
  return null;
}
