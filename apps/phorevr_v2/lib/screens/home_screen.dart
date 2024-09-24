import 'dart:async';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:phorevr/api/auth_api.dart';
import 'package:phorevr/api/balance_api.dart';
import 'package:phorevr/api/storage_api.dart';
import 'package:phorevr/app_storage.dart';
import 'package:phorevr/models/file_info.dart';
import 'package:phorevr/models/token_amount.dart';
import 'package:phorevr/models/user.dart';
import 'package:phorevr/screens/account/account_settings_screen.dart';
import 'package:phorevr/screens/image_viewer/image_viewer_screen.dart';
import 'package:phorevr/screens/upload/images_upload_screen.dart';
import 'package:phorevr/theme/app_theme.dart';
import 'package:phorevr/utils/ipfs.dart';
import 'package:phorevr/widgets/image/ipfs_image.dart';
import 'package:phorevr/widgets/view/app_padding.dart';
import 'package:transparent_image/transparent_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<User> futureUser;
  late Future<double?> futureBalance;
  late Future<List<FileInfo>?> futureFiles;

  @override
  void initState() {
    super.initState();
    futureUser = fetchUser();
    futureBalance = fetchBalance();
    futureFiles = fetchFiles();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final redirectTo = await appStorage.getValue('redirect_to');
      if (redirectTo != null && mounted) {
        Navigator.of(context).pushNamed(redirectTo);
        appStorage.deleteValue('redirect_to');
      }
    });
  }

  Future<User> fetchUser() =>
      authApi.getMe().then((response) => User.fromJson(response.data['user']));

  Future<double?> fetchBalance() async {
    final response = await balanceApi.getBalance();
    return TokenAmount.fromJson(response.data['balance']).uiAmount;
  }

  Future<List<FileInfo>?> fetchFiles() async {
    try {
      final response = await storageApi.getFiles();
      final files = (response.data['files'] as List)
          .map((f) => FileInfo.fromJson(f))
          .toList();
      fetchFilesData(files);
      return files;
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<void> fetchFileData(FileInfo file) async {
    Uint8List? data;
    try {
      data = await IpfsUtils.fetch('${file.entityId}/preview');
      data = await authApi.decrypt(data);
      setState(() {
        file.data = data;
      });
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        await Future.delayed(Durations.extralong4 * 4);
        fetchFileData(file);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchFilesData(List<FileInfo> files) async {
    for (var i = 0; i < files.length; i++) {
      fetchFileData(files[i]);
    }
  }

  Future onRefresh() {
    setState(() {
      futureBalance = fetchBalance();
      futureUser = fetchUser();
      futureFiles = fetchFiles();
    });
    return Future.wait([futureBalance, futureUser, futureFiles]);
  }

  onPhotoUploadPressed() async {
    final pickedImage = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (pickedImage != null && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ImagesUploadScreen(file: pickedImage.files.first),
        ),
      );
    }
  }

  navigateToImage(FileInfo fileInfo) {
    Navigator.of(context).push(
      PageRouteBuilder(
        fullscreenDialog: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return ImageViewerScreen(fileInfo: fileInfo);
        },
        transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
        ) {
          const begin = 0.0;
          const end = 1.0;
          const curve = Curves.easeInOut;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          var fadeAnimation = animation.drive(tween);

          return FadeTransition(
            opacity: fadeAnimation,
            child: child,
          );
        },
      ),
    );
  }

  buildInitialCard({double balance = 0}) {
    return Card(
      margin: const EdgeInsets.all(0),
      color: COLOR_LIGHT_GRAY,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () {
          onPhotoUploadPressed();
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: COLOR_GRAY2,
                  ),
                  child: const Icon(
                    CupertinoIcons.add,
                    size: 30,
                    color: COLOR_ALMOST_BLACK,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Add Photos',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Text(
                    'Enjoy the first Pay-As-You-Go photo storage ever.',
                    style: TextStyle(color: COLOR_GRAY),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'No subscription.\nNo commitment.\nNo ads.',
                    style: TextStyle(color: COLOR_GRAY),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'End-to-end encrypted.',
                    style: TextStyle(color: COLOR_GRAY),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  buildImageLoaderContainer() {
    return Container(
      color: COLOR_LIGHT_GRAY,
      child: const Center(
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: COLOR_LIGHT_GRAY2,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: APP_BODY_BG,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: FutureBuilder(
          future: futureUser,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            }
            final user = snapshot.data;

            return Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: COLOR_GRAY2,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: user?.avatarCid != null
                        ? IpfsImage(path: user!.avatarCid!)
                        : const SizedBox(
                            width: 20,
                            height: 20,
                            child: Icon(
                              CupertinoIcons.person_fill,
                              color: COLOR_WHITE,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('@${user?.username}'),
                ),
              ],
            );
          },
        ),
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: COLOR_ALMOST_BLACK,
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const AccountSettingsSreen();
                  },
                ),
              );
            },
            icon: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            CupertinoSliverRefreshControl(
              onRefresh: onRefresh,
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 45),
                  AppPadding(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Photos',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        IconButton(
                          onPressed: onPhotoUploadPressed,
                          iconSize: 32,
                          icon: const Icon(
                            Icons.add_photo_alternate_outlined,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            FutureBuilder<List>(
              future: Future.wait([futureFiles, futureBalance]),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final balance = snapshot.data?[1];
                final List<FileInfo> files = snapshot.data?[0] ?? [];
                if (files.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AppPadding(
                        child: SizedBox(
                          width: 240,
                          child: buildInitialCard(balance: balance),
                        ),
                      ),
                    ),
                  );
                }
                return SliverGrid(
                  gridDelegate: files.length < 4
                      ? SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              (MediaQuery.of(context).size.width / 150).floor(),
                          mainAxisSpacing: 2,
                          crossAxisSpacing: 2,
                        )
                      : SliverQuiltedGridDelegate(
                          crossAxisCount: 4,
                          mainAxisSpacing: 2,
                          crossAxisSpacing: 2,
                          repeatPattern: QuiltedGridRepeatPattern.inverted,
                          pattern: [
                            const QuiltedGridTile(2, 2),
                            const QuiltedGridTile(1, 1),
                            const QuiltedGridTile(1, 1),
                            const QuiltedGridTile(1, 2),
                          ],
                        ),
                  delegate: SliverChildBuilderDelegate(
                    childCount: files.length,
                    (context, index) {
                      final fileInfo = files[index];
                      final entityId = files[index].entityId ?? '';
                      if (fileInfo.data == null) {
                        return buildImageLoaderContainer();
                      }
                      return Hero(
                        tag: entityId,
                        flightShuttleBuilder:
                            (_, __, ___, ____, toHeroContext) {
                          return toHeroContext.widget;
                        },
                        child: Material(
                          child: InkWell(
                            onTap: () => navigateToImage(fileInfo),
                            child: ClipRRect(
                              clipBehavior: Clip.antiAlias,
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: FadeInImage(
                                  fadeInDuration:
                                      const Duration(milliseconds: 300),
                                  placeholder: MemoryImage(kTransparentImage),
                                  imageErrorBuilder:
                                      (context, error, stackTrace) {
                                    return Image.memory(kTransparentImage);
                                  },
                                  image: MemoryImage(
                                    fileInfo.data ?? kTransparentImage,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
