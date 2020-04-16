import 'package:flutter/widgets.dart';

class AppLogo extends StatelessWidget {
  static final String tag = 'AppLogo';

  final double height;

  const AppLogo({Key key, @required this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.asset('images/logo.png'),
      height: height,
    );
  }
}
