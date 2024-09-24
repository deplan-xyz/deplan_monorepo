import 'package:deplan/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:transparent_image/transparent_image.dart';

class OrganizationItemVertical extends StatelessWidget {
  // constructor should get an organization name, organization logo url, subscribtion price, organization name, organization website
  final String organizationName;
  final String organizationLogoUrl;
  final String subscriptionPrice;
  final String organizationWebsite;

  const OrganizationItemVertical({
    super.key,
    required this.organizationName,
    required this.organizationLogoUrl,
    required this.subscriptionPrice,
    required this.organizationWebsite,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 85,
          height: 85,
          child: FadeInImage(
            placeholder: MemoryImage(kTransparentImage),
            image: NetworkImage(organizationLogoUrl),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          organizationName,
          style: const TextStyle(
            fontSize: 24,
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          organizationWebsite,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            fontFamily: 'SF Pro Display',
            color: TEXT_SECONDARY_ACCENT,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '\$$subscriptionPrice /mo',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            fontFamily: 'SF Pro Display',
            color: TEXT_SECONDARY,
          ),
        ),
      ],
    );
  }
}

class OrganizationItemVerticalSkeleton extends StatelessWidget {
  const OrganizationItemVerticalSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(child: _buildSkeleton());
  }
}

_buildSkeleton() {
  return Column(
    children: [
      Skeletonizer(
        child: Container(
          width: 85,
          height: 85,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      const SizedBox(height: 15),
      Skeletonizer(
        enabled: true,
        child: Container(
          width: 200,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      const SizedBox(height: 15),
      Skeletonizer(
        child: Container(
          width: 200,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      const SizedBox(height: 30),
      Skeletonizer(
        child: Container(
          width: 100,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    ],
  );
}
