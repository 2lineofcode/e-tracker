import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExpenseImagePreview extends StatefulWidget {
  const ExpenseImagePreview({super.key, this.bytes, this.loadImage})
      : assert(bytes != null || loadImage != null);

  final Uint8List? bytes;
  final Future<Uint8List> Function()? loadImage;

  static Future<void> show(BuildContext context, {
    Uint8List? bytes,
    Future<Uint8List> Function()? loadImage,
  }) => showDialog<void>(
    context: context,
    useSafeArea: false,
    barrierDismissible: false,
    builder: (_) => ExpenseImagePreview(bytes: bytes, loadImage: loadImage),
  );

  @override
  State<ExpenseImagePreview> createState() => _ExpenseImagePreviewState();
}

class _ExpenseImagePreviewState extends State<ExpenseImagePreview>
    with SingleTickerProviderStateMixin {
  final _transform = TransformationController();
  late final AnimationController _animation;
  Animation<Matrix4>? _zoomAnimation;
  late Future<Uint8List> _image;
  Offset _doubleTapPosition = Offset.zero;
  Size _viewport = Size.zero;
  int _turns = 0;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _image = _loadImage();
    _animation = AnimationController(vsync: this, duration: const Duration(milliseconds: 180))
      ..addListener(() {
        if (_zoomAnimation != null) _transform.value = _zoomAnimation!.value;
      });
  }

  Future<Uint8List> _loadImage() async => widget.bytes ?? await widget.loadImage!();

  @override
  void dispose() {
    _animation.dispose();
    _transform.dispose();
    super.dispose();
  }

  void _zoom(double scale, {Offset? focalPoint}) {
    if (!_ready) return;
    final target = scale.clamp(1.0, 8.0);
    final focal = focalPoint ?? Offset(_viewport.width / 2, _viewport.height / 2);
    final current = _transform.value;
    final ratio = target / current.getMaxScaleOnAxis();
    final translation = current.getTranslation();
    final matrix = target == 1
        ? Matrix4.identity()
        : (Matrix4.diagonal3Values(target, target, 1)
          ..setTranslationRaw(
            focal.dx - (focal.dx - translation.x) * ratio,
            focal.dy - (focal.dy - translation.y) * ratio,
            0,
          ));
    _animation.stop();
    _zoomAnimation = Matrix4Tween(begin: current.clone(), end: matrix)
        .animate(CurvedAnimation(parent: _animation, curve: Curves.easeOutCubic));
    _animation.forward(from: 0);
  }

  void _retry() {
    _animation.stop();
    _transform.value = Matrix4.identity();
    setState(() {
      _ready = false;
      _image = _loadImage();
    });
  }

  Widget _button(String label, IconData icon, VoidCallback? onPressed) => IconButton(
    tooltip: label,
    onPressed: onPressed,
    color: Colors.white,
    disabledColor: Colors.white30,
    icon: Icon(icon, size: 22),
    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
  );

  Widget _error() => Center(child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.broken_image_outlined, color: Colors.white54, size: 36),
      const SizedBox(height: 12),
      const Text('Gambar tidak bisa dibuka', style: TextStyle(color: Colors.white70)),
      if (widget.loadImage != null) ...[
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: _retry,
          icon: const Icon(Icons.refresh),
          label: const Text('Coba lagi'),
          style: TextButton.styleFrom(foregroundColor: Colors.white),
        ),
      ],
    ],
  ));

  @override
  Widget build(BuildContext context) => Dialog.fullscreen(
    backgroundColor: const Color(0xFF101114),
    child: CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () => Navigator.of(context).pop(),
        const SingleActivator(LogicalKeyboardKey.equal): () => _zoom(_transform.value.getMaxScaleOnAxis() * 1.5),
        const SingleActivator(LogicalKeyboardKey.equal, shift: true): () => _zoom(_transform.value.getMaxScaleOnAxis() * 1.5),
        const SingleActivator(LogicalKeyboardKey.minus): () => _zoom(_transform.value.getMaxScaleOnAxis() / 1.5),
        const SingleActivator(LogicalKeyboardKey.digit0): () => _zoom(1),
      },
      child: Focus(
        autofocus: true,
        child: SafeArea(child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 8, top: 4),
            child: Row(children: [
              const Expanded(child: Text('Gambar transaksi',
                style: TextStyle(color: Colors.white70, fontSize: 13))),
              _button('Tutup (Esc)', Icons.close, () => Navigator.of(context).pop()),
            ]),
          ),
          Expanded(child: LayoutBuilder(builder: (context, constraints) {
            final size = constraints.biggest;
            if (_viewport != size) {
              _viewport = size;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                _animation.stop();
                _transform.value = Matrix4.identity();
              });
            }
            return FutureBuilder<Uint8List>(
              future: _image,
              builder: (context, snapshot) {
                if (snapshot.hasError) return _error();
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white70, strokeWidth: 2));
                }
                return GestureDetector(
                  onDoubleTapDown: (details) => _doubleTapPosition = details.localPosition,
                  onDoubleTap: () => _zoom(
                    _transform.value.getMaxScaleOnAxis() > 1.05 ? 1 : 3,
                    focalPoint: _doubleTapPosition,
                  ),
                  child: InteractiveViewer(
                    transformationController: _transform,
                    minScale: 1,
                    maxScale: 8,
                    trackpadScrollCausesScale: true,
                    onInteractionStart: (_) => _animation.stop(),
                    child: SizedBox.fromSize(size: size, child: RotatedBox(
                      quarterTurns: _turns,
                      child: Image.memory(
                        snapshot.data!,
                        fit: BoxFit.contain,
                        semanticLabel: 'Gambar transaksi',
                        gaplessPlayback: true,
                        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                          if (frame != null || wasSynchronouslyLoaded) {
                            if (!_ready) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) setState(() => _ready = true);
                              });
                            }
                            return child;
                          }
                          return const Center(child: CircularProgressIndicator(color: Colors.white70, strokeWidth: 2));
                        },
                        errorBuilder: (_, _, _) => _error(),
                      ),
                    )),
                  ),
                );
              },
            );
          })),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ValueListenableBuilder<Matrix4>(
              valueListenable: _transform,
              builder: (context, matrix, _) => Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _button('Zoom out (-)', Icons.remove, _ready ? () => _zoom(matrix.getMaxScaleOnAxis() / 1.5) : null),
                  SizedBox(width: 56, child: Text('${(matrix.getMaxScaleOnAxis() * 100).round()}%',
                    textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 12))),
                  _button('Zoom in (+)', Icons.add, _ready ? () => _zoom(matrix.getMaxScaleOnAxis() * 1.5) : null),
                  _button('Sesuaikan layar (0)', Icons.fit_screen, _ready ? () => _zoom(1) : null),
                  _button('Putar', Icons.rotate_right, _ready ? () {
                    _animation.stop();
                    _transform.value = Matrix4.identity();
                    setState(() => _turns = (_turns + 1) % 4);
                  } : null),
                ],
              ),
            ),
          ),
        ])),
      ),
    ),
  );
}
