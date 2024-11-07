import 'package:classroom_app/locator.dart';
import 'package:classroom_app/service/auth_service.dart';
import 'package:flutter/material.dart';

class FourthPage extends StatelessWidget {
  FourthPage({super.key});
  final AuthenticationServices authService = locator<AuthenticationServices>();
  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Text("user fourth page")],
    );
  }
}
