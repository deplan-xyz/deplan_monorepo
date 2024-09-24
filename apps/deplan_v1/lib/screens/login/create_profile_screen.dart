import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:deplan_v1/api/auth_api.dart';
import 'package:deplan_v1/models/user.dart';
import 'package:deplan_v1/screens/login/login_code_screen.dart';
import 'package:deplan_v1/theme/app_theme.dart';
import 'package:deplan_v1/utils/crypto.dart';
import 'package:deplan_v1/widgets/view/screen_scaffold.dart';
import 'package:image_picker/image_picker.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({Key? key}) : super(key: key);

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  User user = User();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  // bool _isLoading = false;
  // Uint8List? _imageBuffer;

  @override
  initState() {
    super.initState();
    createUser();
  }

  selectUserImage() async {
    final ImagePicker picker = ImagePicker();

    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final bytes = await pickedImage.readAsBytes();
      user.avatarToSet = bytes;

      // setState(() {
      //   _imageBuffer = bytes;
      // });
    }
  }

  createUser() async {
    // setState(() {
    //   _isLoading = true;
    // });

    try {
      final entropy = CryptoUtils.generateEntropy();
      final password = await CryptoUtils.getPassword(entropy);
      user.password = password;
      final keypair = await CryptoUtils.generateKeypair(entropy);
      user.wallet = keypair.address;
      final secretCode = CryptoUtils.getSecretCodeV2(entropy);
      await authApi.signup(user, keypair);
      navigateForward(secretCode);
    } on DioException catch (e) {
      displayError(e.response?.data['message']);
      navigateBack();
    } catch (e) {
      print(e.toString());
      navigateBack();
    } finally {
      // setState(() {
      //   _isLoading = false;
      // });
    }
  }

  navigateBack() {
    Navigator.of(context).pop();
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

  navigateForward(String code) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginCodeScreen(code: code)),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const ScreenScaffold(
      title: 'Creating account...',
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
