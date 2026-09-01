import 'package:expense_tracker/app/helpers/helper_image.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('compresses images to JPEG within the requested size', () async {
    final source = img.Image(width: 2000, height: 1000);
    final result = img.decodeJpg(
      await compressImage(img.encodePng(source)),
    );

    expect(result, isNotNull);
    expect(result!.width, 1024);
    expect(result.height, 512);
  });
}
