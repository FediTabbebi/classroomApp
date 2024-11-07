import 'package:cached_network_image/cached_network_image.dart';
import 'package:classroom_app/model/user_model.dart';
import 'package:classroom_app/provider/update_user_provider.dart';
import 'package:classroom_app/src/widget/elevated_button_widget.dart';
import 'package:classroom_app/utils/helper.dart';
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Dialog(
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
                              const Text(
                                "First Name",
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 5.0),
                              textFieldWidget(
                                  hintText: "Enter user first name",
                                  textEditingController: context.read<UpdateUserProvider>().firstNameController,
                                  validator: (value) => validatefirstName(value!, false),
                                  context: context),
                              const SizedBox(height: 7.5),
                              const Text(
                                "Last Name",
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 5.0),
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
                    const SizedBox(height: 7.5),
                    const Text(
                      "Email Address",
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 5.0),
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
                    if (widget.user == null) const SizedBox(height: 7.5),
                    if (widget.user == null)
                      const Text(
                        "Password",
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    if (widget.user == null) const SizedBox(height: 5.0),
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
                              )),
                          obscureText: !context.watch<UpdateUserProvider>().passwordFieldVisibility,
                          validator: (value) => validatePassword(value!, false),
                          context: context),
                    const SizedBox(
                      height: 7.5,
                    ),
                    const SizedBox(height: 7.5),
                    const Text(
                      "User Role",
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Container(
                      constraints: const BoxConstraints(minHeight: 40, maxHeight: 60),
                      child: DropdownSearch<String>(
                        dropdownDecoratorProps: DropDownDecoratorProps(
                            baseStyle: const TextStyle(fontSize: 12),
                            dropdownSearchDecoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                isDense: true,
                                errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 1), borderRadius: BorderRadius.circular(5.0)),
                                enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xffD3D7DB), width: 1), borderRadius: BorderRadius.circular(5.0)),
                                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xff6C4796), width: 1), borderRadius: BorderRadius.circular(5.0)),
                                focusedErrorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xff6C4796), width: 1), borderRadius: BorderRadius.circular(5.0)),
                                fillColor: Theme.of(context).cardTheme.color,
                                errorStyle: const TextStyle(
                                  height: 1,
                                  fontSize: 12,
                                ),
                                hintStyle: const TextStyle(
                                  height: 1,
                                  fontSize: 12,
                                ),
                                hintText: "User role")),
                        key: context.read<UpdateUserProvider>().userRoleMultiKey,
                        items: context.read<UpdateUserProvider>().userRole,
                        onChanged: (value) {
                          context.read<UpdateUserProvider>().selectedUserRole = value;
                        },
                        selectedItem: widget.user?.role,
                        validator: (value) => validateEmptyFieldWithResponse(value, "Please select user role"),
                        popupProps: PopupProps.menu(
                          itemBuilder: (context, item, isSelected) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                item,
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          },
                          constraints: BoxConstraints.tight(const Size(double.infinity, 70)),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButtonWidget(
                        width: widget.user != null ? 75 : 60,
                        height: 40,
                        radius: 5,
                        onPressed: () {
                          widget.user != null
                              ? context.read<UpdateUserProvider>().updateUser(context, widget.user!, context.read<UpdateUserProvider>().userCreationImg)
                              : context.read<UpdateUserProvider>().createNewUser(
                                  UserModel(
                                      userId: '',
                                      firstName: context.read<UpdateUserProvider>().firstNameController.text,
                                      lastName: context.read<UpdateUserProvider>().lastNameController.text,
                                      email: context.read<UpdateUserProvider>().emailController.text,
                                      password: context.read<UpdateUserProvider>().passwordController.text,
                                      profilePicture: context.read<UpdateUserProvider>().imageURL,
                                      role: context.read<UpdateUserProvider>().selectedUserRole!,
                                      createdAt: DateTime.now(),
                                      updatedAt: DateTime.now(),
                                      isDeleted: false),
                                  context,
                                  context.read<UpdateUserProvider>().createUserFormKey,
                                  context.read<UpdateUserProvider>().userCreationImg);
                        },
                        text: widget.user != null ? 'Update' : 'Add',
                        fontSize: 12,
                      ),
                    )
                  ],
                ),
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
    return Container(
      constraints: const BoxConstraints(minHeight: 40, maxHeight: 60),
      child: TextFormField(
          controller: textEditingController,
          obscureText: obscureText ?? false,
          decoration: InputDecoration(
            alignLabelWithHint: true,
            fillColor: Theme.of(context).cardTheme.color,
            // isCollapsed: true,
            errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 1), borderRadius: BorderRadius.circular(5.0)),
            enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xffD3D7DB), width: 1), borderRadius: BorderRadius.circular(5.0)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1), borderRadius: BorderRadius.circular(5.0)),
            focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1), borderRadius: BorderRadius.circular(5.0)),
            hintText: hintText,

            errorStyle: const TextStyle(
              height: 1,
              fontSize: 12.0,
            ),

            hintStyle: const TextStyle(
              height: 1,
              fontSize: 12.0,
            ),

            //isDense: true,
            suffixIcon: suffixIcon,
          ),
          readOnly: readOnly,
          textAlign: TextAlign.start,
          style: const TextStyle(fontSize: 12.0, height: 1),
          validator: (value) => validator!(value)),
    );
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
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(
            height: 7.5,
          ),
          InkWell(
            onTap: context.read<UpdateUserProvider>().userCreationImg != null
                ? null
                : () {
                    context.read<UpdateUserProvider>().pickImage(false);
                  },
            child: (widget.user != null)
                ? widget.user!.profilePicture.isNotEmpty && context.watch<UpdateUserProvider>().userCreationImg == null
                    ? Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl: widget.user!.profilePicture,
                            imageBuilder: (context, imageProvider) => Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
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
                            image: context.watch<UpdateUserProvider>().userCreationImg != null
                                ? DecorationImage(
                                    image: FileImage(
                                      context.read<UpdateUserProvider>().userCreationImg!,
                                    ),
                                    fit: BoxFit.cover)
                                : null,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: const Color(0xffD3D7DB))),
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
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "Upload\nPicture",
                                  style: TextStyle(fontSize: 10, color: Theme.of(context).hintColor),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ],
                        ),
                      )
                : Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                        image: context.watch<UpdateUserProvider>().userCreationImg != null
                            ? DecorationImage(
                                image: FileImage(
                                  context.read<UpdateUserProvider>().userCreationImg!,
                                ),
                                fit: BoxFit.cover)
                            : null,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: const Color(0xffD3D7DB))),
                    child: Stack(
                      children: [
                        if (context.read<UpdateUserProvider>().userCreationImg != null)
                          Positioned(
                              top: 0,
                              right: 0,
                              child: iconButton(context, Icons.edit, () {
                                context.read<UpdateUserProvider>().pickImage(false);
                              }, false)),
                        if (context.read<UpdateUserProvider>().userCreationImg == null)
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Upload\nPicture",
                              style: TextStyle(fontSize: 10, color: Theme.of(context).hintColor),
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
          if (context.read<UpdateUserProvider>().userCreationImg != null)
            InkWell(
              onTap: () {
                context.read<UpdateUserProvider>().removeImg(false);
              },
              child: Text(
                "Remove picture",
                style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
