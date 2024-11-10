import 'package:classroom_app/constant/app_images.dart';
import 'package:classroom_app/model/user_model.dart';
import 'package:classroom_app/provider/register_provider.dart';
import 'package:classroom_app/provider/theme_provider.dart';
import 'package:classroom_app/src/widget/elevated_button_widget.dart';
import 'package:classroom_app/src/widget/loading_indicator_widget.dart';
import 'package:classroom_app/theme/themes.dart';
import 'package:classroom_app/utils/helper.dart';
import 'package:classroom_app/utils/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Scaffold(
              resizeToAvoidBottomInset: true,
              floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
              floatingActionButton: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 8.0, 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (ResponsiveWidget.isLargeScreen(context))
                      const SizedBox(
                        width: 100,
                      ),
                    FloatingActionButton(
                      onPressed: () {
                        context.go("/login");
                      },
                      splashColor: Colors.transparent,
                      highlightElevation: 0,
                      hoverColor: Colors.transparent,
                      hoverElevation: 0,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      child: Icon(
                        Icons.arrow_back,
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                        size: 30,
                      ),
                    ),
                    InkWell(
                        onTap: () => context.read<ThemeProvider>().toggleTheme(),
                        child: Icon(
                          context.watch<ThemeProvider>().isDarkMode ? Icons.dark_mode : Icons.light_mode,
                          size: 28,
                        )),
                  ],
                ),
              ),
              body: SafeArea(
                  top: true,
                  child: Row(
                    children: [
                      if (ResponsiveWidget.isLargeScreen(context))
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: ColoredBox(
                                color: context.read<ThemeProvider>().isDarkMode ? const Color(0xff1D1D22) : Themes.secondaryColor.withOpacity(0.1),
                                child: Image.asset(
                                  AppImages.authImg,
                                  fit: BoxFit.cover,
                                  width: 1031,
                                  height: 1051,
                                ),
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
                                  padding: const EdgeInsets.all(20.0),
                                  child: SizedBox(
                                    width: 578.0,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Get Started Now",
                                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        const Text("Enter your credential to access your account"),
                                        Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 43.0, 0.0, 0.0),
                                          child: Form(
                                            key: context.read<RegisterProvider>().registerFormKey,
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
                                                      textEditingController: context.read<RegisterProvider>().emailController,
                                                      validator: (value) => validateEmailAddress(value!, true)),
                                                  const SizedBox(height: 23.0),
                                                  const Text(
                                                    "First Name",
                                                  ),
                                                  const SizedBox(height: 10.0),
                                                  textFieldWidget(
                                                      hintText: "Enter your first name",
                                                      textEditingController: context.read<RegisterProvider>().firstNameController,
                                                      validator: (value) => validatefirstName(value!, true)),
                                                  const SizedBox(height: 23.0),
                                                  const Text(
                                                    "Last Name",
                                                  ),
                                                  const SizedBox(height: 10.0),
                                                  textFieldWidget(
                                                      hintText: "Enter your last name",
                                                      textEditingController: context.read<RegisterProvider>().lastNameController,
                                                      validator: (value) => validatefirstName(value!, true)),
                                                  const SizedBox(height: 23.0),
                                                  const Text(
                                                    "Password",
                                                  ),
                                                  const SizedBox(height: 10.0),
                                                  textFieldWidget(
                                                      hintText: "••••••••",
                                                      textEditingController: context.read<RegisterProvider>().passwordController,
                                                      suffixIcon: Padding(
                                                        padding: const EdgeInsets.only(right: 25),
                                                        child: InkWell(
                                                            onTap: () {
                                                              context.read<RegisterProvider>().setPasswordFieldVisibility();
                                                            },
                                                            child: Icon(
                                                              context.watch<RegisterProvider>().passwordFieldVisibility ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                                              size: 25.0,
                                                            )),
                                                      ),
                                                      obscureText: !context.watch<RegisterProvider>().passwordFieldVisibility,
                                                      validator: (value) => validatePassword(value!, true)),
                                                  const SizedBox(height: 23.0),
                                                  const Text(
                                                    "Confirm password",
                                                  ),
                                                  const SizedBox(height: 10.0),
                                                  textFieldWidget(
                                                      hintText: "••••••••",
                                                      textEditingController: context.read<RegisterProvider>().confirmPasswordController,
                                                      suffixIcon: Padding(
                                                        padding: const EdgeInsets.only(right: 25),
                                                        child: InkWell(
                                                            onTap: () {
                                                              context.read<RegisterProvider>().setPasswordFieldVisibility();
                                                            },
                                                            child: Icon(
                                                              context.watch<RegisterProvider>().passwordFieldVisibility ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                                              size: 25.0,
                                                            )),
                                                      ),
                                                      obscureText: !context.watch<RegisterProvider>().passwordFieldVisibility,
                                                      validator: (value) => validateConfirmPassword(value!, context.read<RegisterProvider>().passwordController.text)),
                                                ]),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 30.0, 0.0, 0.0),
                                          child: context.watch<RegisterProvider>().isLoading
                                              ? const Center(
                                                  child: LoadingIndicatorWidget(
                                                  size: 40,
                                                ))
                                              : ElevatedButtonWidget(
                                                  onPressed: () async {
                                                    FocusScope.of(context).unfocus();
                                                    context.read<RegisterProvider>().registerUser(
                                                        UserModel(
                                                            userId: '',
                                                            firstName: context.read<RegisterProvider>().firstNameController.text,
                                                            lastName: context.read<RegisterProvider>().lastNameController.text,
                                                            email: context.read<RegisterProvider>().emailController.text,
                                                            password: context.read<RegisterProvider>().passwordController.text,
                                                            profilePicture: '',
                                                            role: 'user',
                                                            createdAt: DateTime.now(),
                                                            updatedAt: DateTime.now(),
                                                            isDeleted: false),
                                                        context,
                                                        context.read<RegisterProvider>().registerFormKey);
                                                  },
                                                  text: "Register",
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
                                                'Already member? ',
                                              )),
                                              InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor: Colors.transparent,
                                                onTap: () async {
                                                  context.go('/login');
                                                },
                                                child: const Text('Login', style: TextStyle(fontWeight: FontWeight.bold, color: Themes.primaryColor)),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        )
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
                  ))),
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

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
