import 'dart:typed_data';

import 'package:deplan_core/deplan_core.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:phorevr_v1/api/auth_api.dart';
import 'package:phorevr_v1/models/user.dart';
import 'package:phorevr_v1/screens/home_screen.dart';
import 'package:phorevr_v1/theme/app_theme.dart';
import 'package:phorevr_v1/widgets/form/input_form.dart';
import 'package:phorevr_v1/widgets/view/app_padding.dart';
import 'package:phorevr_v1/widgets/view/screen_scaffold.dart';

class CreateProfileScreen extends StatefulWidget {
  final DePlanSignInData dePlanSignInData;

  const CreateProfileScreen({Key? key, required this.dePlanSignInData})
      : super(key: key);

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  User user = User();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Uint8List? _imageBuffer;

  selectUserImage() async {
    var pickedImage = await FilePicker.platform
        .pickFiles(type: FileType.image, allowMultiple: false);

    if (pickedImage != null) {
      user.avatarToSet = pickedImage.files.first.bytes!;

      setState(() {
        _imageBuffer = pickedImage.files.first.bytes!;
      });
    }
  }

  createUser() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      user.wallet = widget.dePlanSignInData.wallet;
      await authApi.signupDeplan(user, widget.dePlanSignInData);
      navigateForward();
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        displayError(e.response?.data['message']);
      }
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  displayError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: COLOR_RED,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  navigateForward() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Create account',
      child: AppPadding(
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                InkWell(
                  onTap: selectUserImage,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E2E8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    width: 70,
                    height: 70,
                    clipBehavior: Clip.antiAlias,
                    child: _imageBuffer == null
                        ? const Center(
                            child: Image(
                              image: AssetImage('assets/images/add_image.png'),
                            ),
                          )
                        : FittedBox(
                            clipBehavior: Clip.hardEdge,
                            fit: BoxFit.cover,
                            child: Image.memory(
                              _imageBuffer!,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: InputForm(
                    formKey: formKey,
                    child: Column(
                      children: [
                        AppTextFormField(
                          labelText: '@username',
                          helperText:
                              'Your username is your ID. It can’t be changed. Make sure to create appropriate username to use it forever.',
                          onChanged: (value) {
                            setState(() {
                              user.username = value;
                            });
                          },
                          validator: requiredField('Username'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 290,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : createUser,
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator.adaptive(),
                            )
                          : const Text('Next'),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
