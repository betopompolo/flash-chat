import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final Function onTap;
  final Color color;
  final bool loading;

  const PrimaryButton({
    this.text,
    this.onTap,
    this.loading = false,
    @required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: color,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: onTap,
          minWidth: 200.0,
          height: 42.0,
          child: loading
              ? _buildLoading()
              : Text(
                  text,
                  style: Theme.of(context).textTheme.button,
                ),
        ),
      ),
    );
  }

  Widget _buildLoading() => Center(
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      strokeWidth: 2.0,
    ),
  );
}
