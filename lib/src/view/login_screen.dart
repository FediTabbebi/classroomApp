import 'package:classroom_app/constant/app_images.dart';
import 'package:classroom_app/provider/login_provider.dart';
import 'package:classroom_app/provider/theme_provider.dart';
import 'package:classroom_app/src/widget/elevated_button_widget.dart';
import 'package:classroom_app/src/widget/loading_indicator_widget.dart';
import 'package:classroom_app/theme/themes.dart';
import 'package:classroom_app/utils/helper.dart';
import 'package:classroom_app/utils/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Scaffold(
              floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
              floatingActionButton: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 8.0, 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (ResponsiveWidget.isLargeScreen(context))
                      const SizedBox(
                        width: 100,
                      ),
                    // FloatingActionButton(
                    //   onPressed: () {
                    //     //context.go("/polyscrum");
                    //   },
                    //   splashColor: Colors.transparent,
                    //   highlightElevation: 0,
                    //   hoverColor: Colors.transparent,
                    //   hoverElevation: 0,
                    //   backgroundColor: Colors.transparent,
                    //   elevation: 0,
                    //   child: Icon(
                    //     Icons.arrow_back,
                    //     color: Theme.of(context).textTheme.bodyMedium!.color,
                    //     size: 30,
                    //   ),
                    // ),
                    InkWell(
                        onTap: () => context.read<ThemeProvider>().toggleTheme(),
                        child: Icon(
                          context.watch<ThemeProvider>().isDarkMode ? Icons.dark_mode : Icons.light_mode,
                          size: 28,
                        )),
                  ],
                ),
              ),
              body: Row(
                children: [
                  if (ResponsiveWidget.isLargeScreen(context))
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            AppImages.authImg,
                            fit: BoxFit.cover,
                            width: 1031,
                            height: 1051,
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: Align(
                      alignment: const AlignmentDirectional(0.00, -1.00),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 50,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: SizedBox(
                                width: 578.0,
                                child: Column(
                                  children: [
                                    Image.asset(
                                      AppImages.appLogo,
                                      width: 438.55,
                                      height: 180,
                                    ),
                                    Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 70.0, 0.0, 0.0),
                                      child: Form(
                                        key: context.read<LoginProvider>().loginFormKey,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                              const Text(
                                                "Email address",
                                              ),
                                              const SizedBox(height: 10.0),
                                              textFieldWidget(
                                                  hintText: "Enter your email address",
                                                  textEditingController: context.read<LoginProvider>().emailController,
                                                  validator: (value) => validateEmailAddress(value!, true)),
                                              const SizedBox(height: 23.0),
                                              const Text(
                                                "Password",
                                              ),
                                              const SizedBox(height: 10.0),
                                              textFieldWidget(
                                                  hintText: "••••••••",
                                                  textEditingController: context.read<LoginProvider>().passwordController,
                                                  suffixIcon: Padding(
                                                    padding: const EdgeInsets.only(right: 25),
                                                    child: InkWell(
                                                        onTap: () {
                                                          context.read<LoginProvider>().setPasswordFieldVisibility();
                                                        },
                                                        child: Icon(
                                                          context.watch<LoginProvider>().passwordFieldVisibility ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                                          size: 25.0,
                                                        )),
                                                  ),
                                                  obscureText: !context.watch<LoginProvider>().passwordFieldVisibility,
                                                  validator: (value) => validatePassword(value!, true)),
                                            ]),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 30.0, 0.0, 0.0),
                                      child: context.watch<LoginProvider>().isLoading
                                          ? const LoadingIndicatorWidget(
                                              size: 40,
                                            )
                                          : ElevatedButtonWidget(
                                              onPressed: () async {
                                                FocusScope.of(context).unfocus();
                                                context.read<LoginProvider>().loginUser(
                                                      context.read<LoginProvider>().emailController.text,
                                                      context.read<LoginProvider>().passwordController.text,
                                                      context,
                                                    );
                                              },
                                              text: "Login",
                                            ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 30.0, 0.0, 0.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const SelectionArea(
                                              child: Text(
                                            "Don't have an account? ",
                                          )),
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              context.go('/register');
                                            },
                                            child: const Text('Register', style: TextStyle(fontWeight: FontWeight.bold, color: Themes.primaryColor)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )),
        ));
  }

  textFieldWidget({required TextEditingController textEditingController, required String hintText, required String? Function(String?)? validator, Widget? suffixIcon, bool? obscureText}) {
    return TextFormField(
        controller: textEditingController,
        obscureText: obscureText ?? false,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            height: 1.5,
            fontSize: 16.0,
          ),
          suffixIcon: suffixIcon,
        ),
        style: const TextStyle(
          height: 1.5,
        ),
        validator: (value) => validator!(value));
  }
}
