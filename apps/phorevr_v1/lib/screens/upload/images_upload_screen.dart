import 'dart:math';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:phorevr_v1/api/auth_api.dart';
import 'package:phorevr_v1/api/storage_api.dart';
import 'package:phorevr_v1/theme/app_theme.dart';
import 'package:phorevr_v1/utils/image.dart';
import 'package:phorevr_v1/utils/js_deplan.dart' as deplan;
import 'package:phorevr_v1/widgets/view/screen_scaffold.dart';

class ImagesUploadScreen extends StatefulWidget {
  final PlatformFile file;

  const ImagesUploadScreen({super.key, required this.file});

  @override
  State<ImagesUploadScreen> createState() => _ImagesUploadScreenState();
}

class _ImagesUploadScreenState extends State<ImagesUploadScreen> {
  String progress = '';

  @override
  initState() {
    super.initState();
    uploadFile();
  }

  uploadFile() async {
    try {
      setState(() {
        progress = 'Encrypting...';
      });
      await Future.delayed(const Duration(milliseconds: 500));
      final compressedFile = await ImageUtils.compressImage(widget.file);
      final originalData = await authApi.encrypt(widget.file.bytes!);
      final compressedData = await authApi.encrypt(compressedFile.rawBytes);
      Response response = await storageApi.store(
        [originalData, compressedData],
        widget.file.name,
        onSendProgress: (sent, total) {
          setState(() {
            final p = (sent / total * 100).ceil();
            progress = 'Uploading...${min(49, p)}%';
          });
        },
      );
      final signedTxn = await deplan.signTransaction(response.data['txn']);
      setState(() {
        progress = 'Uploading...50%';
      });
      await storageApi.store(
        [originalData, compressedData],
        widget.file.name,
        txn: signedTxn['signedTransaction'],
        onSendProgress: (sent, total) {
          setState(() {
            final p = (sent / total * 100).ceil();
            progress = 'Uploading...${min(99, max(50, p))}%';
          });
        },
      );
      setState(() {
        progress = 'Uploading...100%';
      });
    } on DioException catch (e) {
      if (mounted) {
        displayError(context, e.response?.data['message']);
      }
    } catch (e) {
      if (mounted) {
        displayError(context, e.toString());
      }
    } finally {
      navigateHome();
    }
  }

  navigateHome() {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  displayError(BuildContext context, String message) {
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
      title: 'Uploading',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 20),
          Text(progress),
        ],
      ),
    );
  }
}
