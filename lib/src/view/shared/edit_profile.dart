import 'package:cached_network_image/cached_network_image.dart';
import 'package:classroom_app/constant/app_images.dart';
import 'package:classroom_app/provider/update_user_provider.dart';
import 'package:classroom_app/provider/user_provider.dart';
import 'package:classroom_app/src/widget/app_bar_widget.dart';
import 'package:classroom_app/src/widget/elevated_button_widget.dart';
import 'package:classroom_app/src/widget/loading_indicator_widget.dart';
import 'package:classroom_app/theme/themes.dart';
import 'package:classroom_app/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UpdateUserProvider>().settingControllers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(
        title: 'Customize Your Profile Information',
        subtitle: 'Customize your profile information here',
        leadingIconData: FontAwesomeIcons.userLarge,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: FloatingActionButton(
          onPressed: () {
            context.pop();
            context.read<UpdateUserProvider>().clearControllers();
          },
          splashColor: Colors.transparent,
          highlightElevation: 0,
          hoverColor: Colors.transparent,
          hoverElevation: 0,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Icon(Icons.arrow_back_sharp, color: Theme.of(context).textTheme.bodyLarge!.color),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Align(
            alignment: const AlignmentDirectional(0, -1),
            child: Container(
              margin: const EdgeInsets.all(20),
              alignment: Alignment.topCenter,
              width: double.infinity,
              constraints: const BoxConstraints(
                maxWidth: 500,
              ),
              child: Form(
                key: context.read<UpdateUserProvider>().formKey,
                child: SingleChildScrollView(
                  child: Column(children: [
                    profilePictureWidget(context),
                    const SizedBox(height: 32.0),
                    textfieldWidget(
                      context: context,
                      controller: context.read<UpdateUserProvider>().firstNameController,
                      labelText: 'First name',
                    ),
                    const SizedBox(height: 32.0),
                    textfieldWidget(
                      context: context,
                      controller: context.read<UpdateUserProvider>().lastNameController,
                      labelText: 'Last name',
                    ),
                    const SizedBox(height: 32.0),
                    textfieldWidget(context: context, controller: context.read<UpdateUserProvider>().emailController, labelText: 'Email Address', suffixIcon: const Icon(Icons.lock), readonly: true),
                    const SizedBox(height: 32.0),
                    context.watch<UpdateUserProvider>().isLoading
                        ? const UnconstrainedBox(
                            child: SizedBox(
                              height: 40,
                              width: 40,
                              child: LoadingIndicatorWidget(size: 40),
                            ),
                          )
                        : ElevatedButtonWidget(
                            width: 120,
                            height: 50,
                            onPressed: () async {
                              context.read<UpdateUserProvider>().updateProfile(context, context.read<UpdateUserProvider>().imageDataMobile);
                            },
                            text: 'Update',
                          )
                  ]),
                ),
              ),
            )),
      ),
    );
  }

  Widget profilePictureWidget(BuildContext context) => Center(
        child: Column(
          children: [
            context.watch<UpdateUserProvider>().imageDataMobile == null
                ? SizedBox(
                    height: 150,
                    width: 150,
                    child: Stack(
                      children: [
                        context.read<UserProvider>().currentUser!.profilePicture.isEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: 150,
                                  height: 150,
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                        image: AssetImage(
                                          AppImages.userProfile,
                                        ),
                                        fit: BoxFit.cover),
                                  ),
                                ),
                              )
                            : CachedNetworkImage(
                                imageUrl: context.read<UserProvider>().currentUser!.profilePicture,
                                imageBuilder: (context, imageProvider) => ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                    ),
                                  ),
                                ),
                                placeholder: (context, url) => const Center(
                                    child: LoadingIndicatorWidget(
                                  size: 40,
                                )),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                              ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: iconButton(context, Icons.edit, () {
                            context.read<UpdateUserProvider>().pickImage(true);
                          }, false),
                        ),
                      ],
                    ),
                  )
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: FileImage(
                                  context.read<UpdateUserProvider>().imageDataMobile!,
                                ),
                                fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      Positioned(
                          bottom: 0,
                          right: 0,
                          child: iconButton(context, Icons.edit, () {
                            context.read<UpdateUserProvider>().pickImage(true);
                          }, false)),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: iconButton(context, FontAwesomeIcons.x, () {
                          context.read<UpdateUserProvider>().removeImg(true);
                        }, true),
                      )
                    ],
                  ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      );

  Widget textfieldWidget(
      {required BuildContext context, required TextEditingController controller, required String labelText, bool? validateField, int? maxLines, Widget? suffixIcon, bool? readonly}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(),
        filled: true,
      ),
      validator: (value) => validateField == null ? validateEmptyField(value) : null,
      readOnly: readonly ?? false,
      maxLines: maxLines ?? 1,
    );
  }

  Widget iconButton(BuildContext context, IconData iconData, Function() onTap, bool removeIcon) {
    return Container(
      height: 30,
      width: 30,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.all(
          Radius.circular(
            50,
          ),
        ),
      ),
      child: InkWell(
        onTap: () {
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Center(
              child: Icon(
            color: Themes.primaryColor,
            iconData,
            size: 20,
          )),
        ),
      ),
    );
  }
}
