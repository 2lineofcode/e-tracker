import 'dart:convert';
import 'dart:io';

import 'package:expense_tracker/app/core/app_setting.dart';
import 'package:expense_tracker/app/helpers/helper_expense_image.dart';
import 'package:expense_tracker/app/models/supa_expense_entity.dart';
import 'package:expense_tracker/app/modules/home/section_dialog_expense.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:image/image.dart' as img;
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  var storageCalls = 0;
  late Directory preferenceDirectory;
  setUpAll(() async {
    preferenceDirectory = await Directory.systemTemp.createTemp('expense_image_test_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (_) async => preferenceDirectory.path,
    );
    await pref.initStorage;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/shared_preferences'),
      (call) async => call.method == 'getAll' ? <String, Object>{} : true,
    );
    await Supabase.initialize(
      url: 'https://test.supabase.co', publishableKey: 'test-key',
      httpClient: MockClient((_) async {
        storageCalls++;
        return http.Response('{}', 200);
      }),
      authOptions: FlutterAuthClientOptions(localStorage: EmptyLocalStorage(),
        autoRefreshToken: false, detectSessionInUri: false),
      debug: false,
    );
  });
  tearDownAll(() async {
    await Supabase.instance.dispose();
    await pref.queue.add(() async {});
    await pumpEventQueue();
    await preferenceDirectory.delete(recursive: true);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'), null,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/shared_preferences'), null,
    );
  });

  testWidgets('replacing an image then cancelling never touches storage', (tester) async {
    final original = img.encodePng(img.Image(width: 2, height: 2));
    final platform = FilePickerPlatform.instance;
    FilePickerPlatform.instance = _ImagePicker(original);
    addTearDown(() => FilePickerPlatform.instance = platform);
    final path = 'owner/original.jpg'.obs;
    final preview = Rx<Uint8List?>(original);
    final oldImages = <String>[].obs;
    storageCalls = 0;
    await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: SizedBox(
      width: 300,
      child: DialogExpense.expenseImagePicker(imageUrl: path,
        previewBytes: preview, imageUrlsToDelete: oldImages),
    ))));
    await tester.runAsync(() async {
      await tester.tap(find.text('Ganti gambar'));
      for (var attempt = 0; attempt < 1000 && identical(preview.value, original); attempt++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    });
    expect(preview.value, isNotNull);
    expect(identical(preview.value, original), isFalse);
    expect(oldImages, ['owner/original.jpg']);
    await tester.pumpWidget(const SizedBox());
    expect(storageCalls, 0);
    Get.reset();
  });

  for (final scenario in ['success', 'write rejected', 'commit response lost', 'lookup unavailable']) {
    test('image lifecycle: $scenario', () async {
      final events = <String>[];
      final removed = <String>[];
      String? uploadedPath;
      String? savedPath = 'owner/original.jpg';
      final client = SupabaseClient('https://test.supabase.co', 'test-key',
        httpClient: MockClient((request) async {
          if (request.method == 'POST' && request.url.path.contains('/storage/')) {
            events.add('upload');
            uploadedPath = request.url.path.split('/expense-images/').last;
            return http.Response(jsonEncode({'Key': 'expense-images/$uploadedPath'}), 200,
              request: request, headers: {'content-type': 'application/json'});
          }
          if (request.method == 'DELETE') {
            events.add('delete');
            removed.addAll((jsonDecode(request.body)['prefixes'] as List).cast<String>());
            return http.Response('[]', 200, request: request, headers: {'content-type': 'application/json'});
          }
          events.add('lookup');
          return scenario == 'lookup unavailable'
              ? http.Response('{"message":"offline"}', 503, request: request, headers: {'content-type': 'application/json'})
              : http.Response(jsonEncode([{'image_path': savedPath}]), 200,
                  request: request, headers: {'content-type': 'application/json'});
        }));
      final expense = SupaExpense(id: 'expense-id', userId: 'owner',
        imagePath: 'owner/original.jpg');
      final saving = persistExpenseWithImage(client, expense,
        imageBytes: Uint8List.fromList([1, 2, 3]),
        oldImagePaths: ['owner/original.jpg'],
        writeExpense: (row) async {
          events.add('save');
          if (scenario == 'success' || scenario == 'commit response lost') savedPath = row.imagePath;
          if (scenario != 'success') throw StateError('Save response failed');
        });
      if (scenario == 'success') {
        expect(await saving, isNull);
        expect(events, ['upload', 'save', 'delete']);
        expect(removed, ['owner/original.jpg']);
      } else {
        await expectLater(saving, throwsStateError);
        expect(events.take(3), ['upload', 'save', 'lookup']);
        expect(removed, scenario == 'write rejected' ? [uploadedPath] : isEmpty);
      }
      expect(uploadedPath, startsWith('owner/expense-id-'));
      expect(uploadedPath, isNot('owner/original.jpg'));
      await client.dispose();
    });
  }
}

class _ImagePicker extends FilePickerPlatform {
  _ImagePicker(this.bytes);
  final Uint8List bytes;

  @override
  Future<PlatformFile?> pickFile({String? dialogTitle, String? initialDirectory,
    FileType type = FileType.any, List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading, int compressionQuality = 0,
    AndroidOptions androidOptions = const AndroidOptions(),
    DarwinOptions darwinOptions = const DarwinOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
  }) async => _MemoryImage(bytes);
}

final class _MemoryImage extends PlatformFile {
  _MemoryImage(this.bytes);
  final Uint8List bytes;
  @override
  String get name => 'image.png';
  @override
  Uri get uri => Uri.parse('memory:image.png');
  @override
  Never get xFile => throw UnimplementedError();
  @override
  int lengthSync() => bytes.length;
  @override
  Future<int> length() async => bytes.length;
  @override
  Future<Uint8List> readAsBytes() async => bytes;
  @override
  Stream<Uint8List> readAsByteStream() => Stream.value(bytes);
}
