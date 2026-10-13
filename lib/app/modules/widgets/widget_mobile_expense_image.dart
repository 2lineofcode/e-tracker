import 'package:flutter/material.dart';

import '../../core/app_api.dart';
import '../../core/app_color.dart';
import '../../helpers/expense_image_url_cache.dart';

class MobileExpenseImage extends StatefulWidget {
  const MobileExpenseImage({
    super.key,
    required this.cache,
    required this.path,
    required this.height,
    this.width,
    this.radius = 6,
    this.fit = BoxFit.contain,
  });

  final ExpenseImageUrlCache cache;
  final String path;
  final double height;
  final double? width;
  final double radius;
  final BoxFit fit;

  @override
  State<MobileExpenseImage> createState() => _MobileExpenseImageState();
}

class _MobileExpenseImageState extends State<MobileExpenseImage> {
  Future<String>? _url;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(MobileExpenseImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _load();
  }

  void _load() {
    _userId = currentUserId;
    _url = _userId == null || widget.path.isEmpty ? null : widget.cache.load(
      _userId!, widget.path,
      () => db.storage.from('expense-images').createSignedUrl(widget.path, 300),
    );
  }

  Widget _placeholder({bool failed = false}) => Container(
    width: widget.width,
    height: widget.height,
    color: AppColor.card,
    child: failed ? Icon(Icons.image_not_supported_outlined, size: 18, color: AppColor.neutral) : null,
  );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      child: FutureBuilder<String>(
        future: _url,
        builder: (context, snapshot) {
          if (_userId == null || _userId != currentUserId || snapshot.hasError) {
            return _placeholder(failed: true);
          }
          if (!snapshot.hasData || snapshot.connectionState != ConnectionState.done) {
            return _placeholder();
          }
          return Image.network(
            snapshot.data!,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            frameBuilder: (_, child, frame, synchronous) =>
                synchronous || frame != null ? child : _placeholder(),
            errorBuilder: (_, _, _) => _placeholder(failed: true),
          );
        },
      ),
    );
  }
}
