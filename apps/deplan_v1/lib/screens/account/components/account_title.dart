import 'package:flutter/cupertino.dart';
import 'package:deplan_v1/models/user.dart';
import 'package:deplan_v1/theme/app_theme.dart';
import 'package:deplan_v1/widgets/image/ipfs_image.dart';

class AccountTitle extends StatelessWidget {
  final User? user;

  const AccountTitle({super.key, this.user});

  @override
  Widget build(BuildContext context) {
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
        Text(
          '@${user?.username}',
          style: const TextStyle(fontWeight: FontWeight.normal),
        ),
      ],
    );
  }
}
