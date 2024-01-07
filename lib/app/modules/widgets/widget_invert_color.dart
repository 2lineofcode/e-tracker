import 'package:flutter/widgets.dart';

class MyInvertColors extends StatelessWidget {
  final Widget child;
  final bool invertColors;

  const MyInvertColors({
    super.key,
    required this.child,
    required this.invertColors,
  });

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(invertColors: invertColors),
      child: child,
    );
  }
}
