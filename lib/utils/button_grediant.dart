import 'package:flutter/material.dart';

class RaisedGradientButton extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final double width;
  final double height;
  final Function onPressed;
  final borderRadius = BorderRadius.circular(128.0);

  RaisedGradientButton({
    Key key,
    @required this.child,
    Gradient gradient,
    this.width = 60.0,
    this.height = 60.0,
    this.onPressed,
  })  : this.gradient = gradient ??
      LinearGradient(
        colors: [
          Color(0xff56EBF1),
          Color(0xff4D82FF),
        ],
        begin: FractionalOffset.topCenter,
        end: FractionalOffset.bottomCenter,
      ),
        super(key: key);

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned.fill(
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              gradient: gradient,
            ),
          ),
        ),
      ),
      Container(
        width: width,
        height: height,
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
          ),
          padding: EdgeInsets.zero,
          child: Center(child: child),
          onPressed: onPressed,
          color: Colors.transparent,
        ),
      ),
    ],
  );
}