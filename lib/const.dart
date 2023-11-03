import 'package:supabase_flutter/supabase_flutter.dart';

// It's handy to then extract the Supabase client in a variable for later uses
final db = Supabase.instance.client;

/// const
const SUPABASE_URL = 'https://nytddmoffawejkpzggzr.supabase.co';
const SUPABASE_ANON_KEY =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im55dGRkbW9mZmF3ZWprcHpnZ3pyIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTkwMTE4MDEsImV4cCI6MjAxNDU4NzgwMX0._zHqtZPcyV61Az7imovcx3fqF_OqFVI9_X81hN_OsB4';
