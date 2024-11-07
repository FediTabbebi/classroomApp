import 'package:flutter/material.dart';

class OutlinedButtonWidget extends StatelessWidget {
  final void Function()? onPressed;
  final String text;
  final double? radius;
  final double? fontSize;
  final double? height;
  final double? width;
  const OutlinedButtonWidget({required this.onPressed, required this.text, this.radius, this.fontSize, this.height, this.width, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 42,
      width: width ?? 130,
      child: OutlinedButton(
          style: ButtonStyle(
            side: const WidgetStatePropertyAll(
              BorderSide(
                width: 1,
                color: Color(0xff8D97A1),
              ),
            ),
            backgroundColor: WidgetStatePropertyAll(Theme.of(context).dialogTheme.backgroundColor),
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(radius ?? 10)))),
            overlayColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.pressed)) {
                return const Color(0xff8D97A1).withOpacity(.1);
              }
              return Colors.transparent;
            }),
          ),
          onPressed: onPressed,
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize ?? 14,
                color: const Color(0xff8D97A1),
              ),
            ),
          )),
    );
  }
}
