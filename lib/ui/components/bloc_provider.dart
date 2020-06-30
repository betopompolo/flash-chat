// Bloc provider based on Ray Wenderlich's tutorial
// https://www.raywenderlich.com/4074597-getting-started-with-the-bloc-pattern

import 'package:flash_chat/domain/bloc.dart';
import 'package:flutter/widgets.dart';

class BlocProvider<T extends Bloc> extends StatefulWidget {
  final Widget child;
  final T bloc;

  BlocProvider({
    this.bloc, 
    this.child,
  });

  static T of<T extends Bloc>(BuildContext context) {
    final BlocProvider<T> provider = context.findAncestorWidgetOfExactType<BlocProvider<T>>();
    return provider?.bloc;
  }

  @override
  State<StatefulWidget> createState() => BlocProviderState();
}

class BlocProviderState extends State<BlocProvider> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    super.dispose();
    widget.bloc.dispose();
  }

}