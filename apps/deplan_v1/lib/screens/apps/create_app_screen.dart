import 'package:deplan_v1/api/apps_api.dart';
import 'package:deplan_v1/models/app.dart';
import 'package:deplan_v1/theme/app_theme.dart';
import 'package:deplan_v1/utils/validation.dart';
import 'package:deplan_v1/widgets/form/input_form.dart';
import 'package:deplan_v1/widgets/list/keyboard_dismissable_list.dart';
import 'package:deplan_v1/widgets/view/app_padding.dart';
import 'package:deplan_v1/widgets/view/screen_scaffold.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateAppScreen extends StatefulWidget {
  const CreateAppScreen({super.key});

  @override
  State<CreateAppScreen> createState() => _CreateAppScreenState();
}

class _CreateAppScreenState extends State<CreateAppScreen> {
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  App app = App();

  selectLogo() async {
    final ImagePicker picker = ImagePicker();

    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final bytes = await pickedImage.readAsBytes();
      setState(() {
        app.logoToSet = bytes;
      });
    }
  }

  String? requiredLogoValidator(String? value) {
    if (app.logoToSet == null) {
      return 'Logo required';
    }
    return null;
  }

  buildForm() {
    return InputForm(
      formKey: formKey,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E2E8),
                  borderRadius: BorderRadius.circular(20),
                ),
                width: 70,
                height: 70,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: selectLogo,
                  borderRadius: BorderRadius.circular(20),
                  child: app.logoToSet == null
                      ? const Center(
                          child: Image(
                            image: AssetImage('assets/images/add_image.png'),
                          ),
                        )
                      : FittedBox(
                          clipBehavior: Clip.hardEdge,
                          fit: BoxFit.cover,
                          child: Image.memory(app.logoToSet!),
                        ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: AppTextFormField(
                  labelText: 'Solana Wallet Address of App',
                  textInputAction: TextInputAction.next,
                  validator: multiValidate([
                    requiredField('Wallet address'),
                    requiredLogoValidator,
                  ]),
                  onChanged: (value) {
                    setState(() {
                      app.wallet = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          AppTextFormField(
            labelText: 'Paste link here',
            textInputAction: TextInputAction.done,
            validator: multiValidate([
              requiredField('Link'),
            ]),
            onChanged: (value) {
              setState(() {
                app.link = value;
              });
            },
          ),
        ],
      ),
    );
  }

  navigateHome() {
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  handleAddPressed() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      await appsApi.createApp(app);
      navigateHome();
    } on DioException catch (e) {
      displayError(e.response?.data['message']);
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Add App',
      child: Column(
        children: [
          Expanded(
            child: KeyboardDismissableListView(
              children: [
                AppPadding(
                  child: buildForm(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 290,
              child: ElevatedButton(
                onPressed: isLoading ? null : handleAddPressed,
                child: isLoading
                    ? const CircularProgressIndicator.adaptive()
                    : const Text('Add App'),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
