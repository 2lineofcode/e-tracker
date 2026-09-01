import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image/image.dart' as img;

Future<Uint8List> compressImage(
  Uint8List bytes, {
  int maxDimension = 1024,
  int quality = 80,
}) async {
  Uint8List compress() {
    var image = img.decodeImage(bytes);
    if (image == null) throw FormatException('Format gambar tidak didukung');

    image = img.bakeOrientation(image);
    if (image.width > maxDimension || image.height > maxDimension) {
      image = image.width >= image.height
          ? img.copyResize(image, width: maxDimension)
          : img.copyResize(image, height: maxDimension);
    }
    return img.encodeJpg(image, quality: quality);
  }

  return kIsWeb ? compress() : Isolate.run(compress);
}
