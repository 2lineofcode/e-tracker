import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('desktop client does not embed Supabase service role', () {
    final hasDartReference = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .any((file) => file.readAsStringSync().contains('supabaseServiceRole'));
    final envFile = File('.env');
    final hasEnvValue = envFile.existsSync() &&
        envFile
            .readAsLinesSync()
            .any((line) => line.trimLeft().startsWith('SUPABASE_SERVICE_ROLE='));
    final localSetup = File('supabase_local.md').readAsStringSync();

    expect(hasDartReference, isFalse);
    expect(hasEnvValue, isFalse);
    expect(localSetup.contains('postgres://'), isFalse);
    expect(localSetup.contains('service_role key:'), isFalse);
  });

  test('Agent credentials stay in the Edge Function', () {
    final clientSource = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where(
          (file) =>
              file.path.endsWith('.dart') && !file.path.endsWith('env.g.dart'),
        )
        .map((file) => file.readAsStringSync())
        .join('\n');
    final proxy = File(
      'supabase/functions/agent-proxy/index.ts',
    ).readAsStringSync();
    final summary = File(
      'lib/app/modules/summary/summary_controller.dart',
    ).readAsStringSync();
    final config = File('supabase/config.toml').readAsStringSync();

    expect(clientSource.contains('Env.agentApiKey'), isFalse);
    expect(clientSource.contains('Env.agentBaseUrl'), isFalse);
    expect(summary.contains("import 'dart:io';"), isFalse);
    expect(proxy.contains("Deno.env.get('AGENT_API_KEY')"), isTrue);
    expect(
      config.contains('[functions.agent-proxy]\nverify_jwt = true'),
      isTrue,
    );
  });

  test('Supabase migration scopes personal data to each user', () {
    final migration = File(
      'supabase/migrations/20260730010000_remove_client_service_role.sql',
    ).readAsStringSync();

    expect(migration.contains('user_id_value uuid'), isTrue);
    expect(migration.toLowerCase().contains('using (true)'), isFalse);
    expect(
      migration.contains(
        'revoke all on table public.expense from anon, authenticated',
      ),
      isTrue,
    );
    for (final policy in [
      'Users can manage own assets',
      'Users can manage own budgets',
      'Users can manage own expenses',
      'Users can manage own goals',
      'Users can manage own notes',
      'Users can manage own profile',
    ]) {
      expect(migration.contains(policy), isTrue);
    }
    expect(
      migration.contains(
        'coalesce(owner_id, owner::text) = (select auth.uid())::text',
      ),
      isTrue,
    );
  });

  test('Agent memory is private per user', () {
    final migration = File(
      'supabase/migrations/20260730040000_add_agent_memory.sql',
    ).readAsStringSync();

    expect(
      migration.contains('alter table public.agent_memory enable row level security'),
      isTrue,
    );
    expect(
      migration.contains('using ((select auth.uid()) = user_id)'),
      isTrue,
    );
    expect(
      migration.contains('with check ((select auth.uid()) = user_id)'),
      isTrue,
    );
    expect(
      migration.contains(
        'revoke all on table public.agent_memory from anon, authenticated',
      ),
      isTrue,
    );

    final renameMigration = File(
      'supabase/migrations/20260730050000_migrate_legacy_memory_to_agent.sql',
    ).readAsStringSync();
    expect(
      renameMigration.contains(
        'alter table public.agnes_memory rename to agent_memory',
      ),
      isTrue,
    );

    final foreignKeyMigration = File(
      'supabase/migrations/20260730060000_rename_agent_memory_foreign_key.sql',
    ).readAsStringSync();
    expect(
      foreignKeyMigration.contains(
        'rename constraint agnes_memory_user_id_fkey',
      ),
      isTrue,
    );
  });
}
