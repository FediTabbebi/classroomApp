import 'package:cached_network_image/cached_network_image.dart';
import 'package:classroom_app/constant/app_colors.dart';
import 'package:classroom_app/model/remotes/role_model.dart';
import 'package:classroom_app/model/remotes/user_model.dart';
import 'package:classroom_app/provider/app_service.dart';
import 'package:classroom_app/provider/update_user_provider.dart';
import 'package:classroom_app/provider/user_provider.dart';
import 'package:classroom_app/src/widget/elevated_button_widget.dart';
import 'package:classroom_app/src/widget/loading_indicator_widget.dart';
import 'package:classroom_app/utils/helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class AddOrUpdateUserDialog extends StatefulWidget {
  final UserModel? user;
  const AddOrUpdateUserDialog({this.user, super.key});

  @override
  State<AddOrUpdateUserDialog> createState() => _AddOrUpdateUserDialogState();
}

class _AddOrUpdateUserDialogState extends State<AddOrUpdateUserDialog> {
  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      context.read<UpdateUserProvider>().initControllers(widget.user!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).cardTheme.color,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: SizedBox(
        width: 500,
        child: Form(
          key: context.read<UpdateUserProvider>().createUserFormKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.user != null ? "Update User" : " Create User",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                            context.read<UpdateUserProvider>().clearControllers();
                          },
                          child: Icon(
                            size: 20,
                            FontAwesomeIcons.xmark,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      userProfilePicture(),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("First Name", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 10),
                            textFieldWidget(
                                hintText: "Enter user first name",
                                textEditingController: context.read<UpdateUserProvider>().firstNameController,
                                validator: (value) => validatefirstName(value!, false),
                                context: context),
                            const SizedBox(height: 10),
                            const Text("Last Name", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 10),
                            textFieldWidget(
                                hintText: "Enter user last name",
                                textEditingController: context.read<UpdateUserProvider>().lastNameController,
                                validator: (value) => validatelastName(value!, false),
                                context: context),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Email Address",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  textFieldWidget(
                      readOnly: widget.user != null ? true : false,
                      suffixIcon: widget.user != null
                          ? const Icon(
                              FontAwesomeIcons.lock,
                              size: 10,
                            )
                          : null,
                      hintText: "Enter user email address",
                      textEditingController: context.read<UpdateUserProvider>().emailController,
                      validator: (value) => validateEmailAddress(value!, false),
                      context: context),
                  if (widget.user == null) const SizedBox(height: 10),
                  if (widget.user == null)
                    const Text(
                      "Password",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  if (widget.user == null) const SizedBox(height: 10),
                  if (widget.user == null)
                    textFieldWidget(
                        hintText: "••••••••",
                        textEditingController: context.read<UpdateUserProvider>().passwordController,
                        suffixIcon: InkWell(
                            onTap: () {
                              context.read<UpdateUserProvider>().setPasswordFieldVisibility();
                            },
                            child: Icon(
                              context.watch<UpdateUserProvider>().passwordFieldVisibility ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              size: 15.0,
                              color: AppColors.darkGrey,
                            )),
                        obscureText: !context.watch<UpdateUserProvider>().passwordFieldVisibility,
                        validator: (value) => validatePassword(value!, false),
                        context: context),
                  const SizedBox(height: 10),
                  const Text(
                    "User Role",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownSearch<RoleModel>(
                        dropdownDecoratorProps: DropDownDecoratorProps(
                            baseStyle: const TextStyle(fontSize: 14),
                            dropdownSearchDecoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 1), borderRadius: BorderRadius.circular(10)),
                                enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.darkGrey, width: 1), borderRadius: BorderRadius.circular(10)),
                                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1), borderRadius: BorderRadius.circular(10)),
                                focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1), borderRadius: BorderRadius.circular(10)),
                                fillColor: Theme.of(context).cardTheme.color,
                                errorStyle: const TextStyle(fontSize: 14),
                                hintStyle: const TextStyle(fontSize: 14),
                                hintText: widget.user?.role == null ? "User role" : widget.user?.role!.label)),
                        asyncItems: (text) => context.read<UserProvider>().getAllRoles(context),
                        // items: context.read<UpdateUserProvider>().RoleModel,

                        key: context.read<UpdateUserProvider>().roleModelMultiKey,
                        validator: (value) {
                          if (value == null) {
                            return "Please select user role";
                          }
                          return null;
                        },
                        onChanged: (value) {
                          context.read<UpdateUserProvider>().selectedroleModel = value;
                        },

                        itemAsString: (item) => item.label,
                        selectedItem: widget.user?.role,
                        popupProps: PopupProps.menu(
                          loadingBuilder: (context, searchEntry) => const Center(child: LoadingIndicatorWidget(size: 20)),
                          itemBuilder: (context, item, isSelected) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                item.label,
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          },
                          constraints: BoxConstraints.tight(const Size(double.infinity, 70)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButtonWidget(
                      width: widget.user != null ? 85 : 60,
                      height: 40,
                      radius: 5,
                      onPressed: () {
                        if (context.read<UpdateUserProvider>().createUserFormKey.currentState!.validate()) {
                          if (widget.user != null) {
                            context.read<UpdateUserProvider>().updateUser(context, widget.user!, context.read<UpdateUserProvider>().userCreationImg, widget.user!.role!.id);
                          } else {
                            DocumentReference roleReference = FirebaseFirestore.instance.collection('roles').doc(context.read<UpdateUserProvider>().selectedroleModel!.id);

                            context.read<UpdateUserProvider>().createNewUser(
                                UserModel(
                                    userId: '',
                                    firstName: context.read<UpdateUserProvider>().firstNameController.text,
                                    lastName: context.read<UpdateUserProvider>().lastNameController.text,
                                    email: context.read<UpdateUserProvider>().emailController.text,
                                    password: context.read<UpdateUserProvider>().passwordController.text,
                                    profilePicture: context.read<UpdateUserProvider>().imageURL,
                                    role: context.read<UpdateUserProvider>().selectedroleModel!,
                                    roleRef: roleReference,
                                    createdAt: DateTime.now(),
                                    updatedAt: DateTime.now(),
                                    isDeleted: false),
                                context,
                                context.read<UpdateUserProvider>().userCreationImg);
                          }
                        }
                      },
                      text: widget.user != null ? 'Update' : 'Add',
                      fontSize: 14,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  textFieldWidget(
      {required TextEditingController textEditingController,
      required String hintText,
      required String? Function(String?)? validator,
      required BuildContext context,
      Widget? suffixIcon,
      bool? obscureText,
      bool readOnly = false}) {
    return TextFormField(
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        controller: textEditingController,
        obscureText: obscureText ?? false,
        decoration: InputDecoration(
          alignLabelWithHint: true,
          fillColor: Theme.of(context).cardTheme.color,
          // isCollapsed: true,
          errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 1), borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.darkGrey, width: 1), borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1), borderRadius: BorderRadius.circular(10)),
          focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1), borderRadius: BorderRadius.circular(10)),
          hintText: hintText,

          errorStyle: const TextStyle(height: 1, fontSize: 14.0),

          hintStyle: const TextStyle(fontSize: 14.0, color: AppColors.darkGrey),

          //isDense: true,
          suffixIcon: suffixIcon,
        ),
        readOnly: readOnly,
        textAlign: TextAlign.start,
        style: const TextStyle(fontSize: 14.0),
        validator: (value) => validator!(value));
  }

  Widget iconButton(BuildContext context, IconData iconData, Function() onTap, bool removeIcon) {
    return Container(
      height: 20,
      width: 20,
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
            color: Theme.of(context).colorScheme.primary,
            iconData,
            size: 12.5,
          )),
        ),
      ),
    );
  }

  Widget userProfilePicture() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 20.0, 0),
      child: Column(
        children: [
          const Text(
            "Profile Picture",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: !emptyImagePickerChecker()
                ? null
                : () {
                    context.read<UpdateUserProvider>().pickImage(false);
                  },
            child: (widget.user != null)
                ? widget.user!.profilePicture.isNotEmpty && emptyImagePickerChecker()
                    ? Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl: widget.user!.profilePicture,
                            imageBuilder: (context, imageProvider) => Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                              ),
                            ),
                            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                          Positioned(
                              top: 0,
                              right: 0,
                              child: iconButton(context, Icons.edit, () {
                                context.read<UpdateUserProvider>().pickImage(false);
                              }, false)),
                        ],
                      )
                    : Container(
                        height: 130,
                        width: 130,
                        decoration: BoxDecoration(
                            image: !emptyImagePickerChecker()
                                ? DecorationImage(
                                    image: !platformImageCheckerIsMobile()
                                        ? MemoryImage(
                                            context.read<UpdateUserProvider>().imageData!,
                                          )
                                        : FileImage(
                                            context.read<UpdateUserProvider>().userCreationImg!,
                                          ),
                                    fit: BoxFit.cover)
                                : null,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: AppColors.darkGrey)),
                        child: Stack(
                          children: [
                            // if user is null
                            if (context.read<UpdateUserProvider>().userCreationImg != null)
                              Positioned(
                                  top: 0,
                                  right: 0,
                                  child: iconButton(context, Icons.edit, () {
                                    context.read<UpdateUserProvider>().pickImage(false);
                                  }, false)),
                            if (context.read<UpdateUserProvider>().userCreationImg == null)
                              const Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "Upload\nPicture",
                                  style: TextStyle(fontSize: 14, color: AppColors.darkGrey),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ],
                        ),
                      )
                : Container(
                    height: 130,
                    width: 130,
                    decoration: BoxDecoration(
                        image: !emptyImagePickerChecker()
                            ? DecorationImage(
                                image: !platformImageCheckerIsMobile()
                                    ? MemoryImage(
                                        context.read<UpdateUserProvider>().imageData!,
                                      )
                                    : FileImage(
                                        context.read<UpdateUserProvider>().userCreationImg!,
                                      ),
                                fit: BoxFit.cover)
                            : null,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.darkGrey)),
                    child: Stack(
                      children: [
                        if (!emptyImagePickerChecker())
                          Positioned(
                              top: 0,
                              right: 0,
                              child: iconButton(context, Icons.edit, () {
                                context.read<UpdateUserProvider>().pickImage(false);
                              }, false)),
                        if (emptyImagePickerChecker())
                          const Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Upload\nPicture",
                              style: TextStyle(fontSize: 14, color: AppColors.darkGrey),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(
            height: 5,
          ),
          if (!emptyImagePickerChecker())
            InkWell(
              onTap: () {
                context.read<UpdateUserProvider>().removeImg(false);
              },
              child: Text(
                "Remove picture",
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  bool emptyImagePickerChecker() {
    bool isImagePicked = false;
    if (context.read<AppService>().isMobileDevice) {
      isImagePicked = context.watch<UpdateUserProvider>().userCreationImg == null;
    } else {
      isImagePicked = context.watch<UpdateUserProvider>().imageData == null;
    }
    return isImagePicked;
  }

  bool platformImageCheckerIsMobile() {
    return context.read<AppService>().isMobileDevice;
  }
}
