import 'package:classroom_app/theme/themes.dart';
import 'package:flutter/material.dart';

class ElevatedButtonWidget extends StatelessWidget {
  final void Function()? onPressed;
  final String text;
  final double? radius;
  final double? fontSize;
  final double? height;
  final double? width;
  const ElevatedButtonWidget({required this.onPressed, required this.text, this.radius, this.fontSize, this.height, this.width, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: height ?? 65,
        width: width ?? 578,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(radius ?? 12)),
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Themes.primaryColor,
              Themes.secondaryColor,
            ],
          ),
        ),
        child: MaterialButton(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(radius ?? 12))),
          onPressed: onPressed,
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: fontSize ?? 16),
            textAlign: TextAlign.center,
          ),
        ));
  }
}
