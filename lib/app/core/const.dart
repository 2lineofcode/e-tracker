import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final db = Supabase.instance.client;
final pref = GetStorage();

/// ------------------------------------------------------------------------
/// dateformat from db
const yM = 'yyyy-MM';
const yMd = 'yyyy-MM-dd';

/// ------------------------------------------------------------------------
/// storage key
const kFlagEco = 'kFlagEco';
const kFlagAverage = 'kFlagAverage';
const kFlagSpender = 'kFlagSpender';
const kIsDarkMode = 'isDarkMode';
const kCurrentLanguage = 'kCurrentLanguage';
