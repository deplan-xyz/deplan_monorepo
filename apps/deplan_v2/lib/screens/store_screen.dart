import 'package:deplan/api/common_api.dart';
import 'package:deplan/components/screen_wrapper.dart';
import 'package:deplan/models/organization.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  late Future<List<Organization>> futureFeaturedApps;

  @override
  void initState() {
    super.initState();
    futureFeaturedApps = api.getApps('featured');
  }

  void openUrl(String url) {
    launchUrl(Uri.parse(url));
  }

  Widget buildApp(Organization app) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xffE9E9EE),
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FadeInImage(
                  fit: BoxFit.cover,
                  placeholder: MemoryImage(kTransparentImage),
                  image: NetworkImage(app.logo),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: Text(
                app.name,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xff11243E),
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '\$${app.settings.pricePerMonth}/mo',
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                      color: Color(0xff828C9A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Text(
            app.description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xff87899B),
              fontFamily: 'SF Pro Display',
              fontWeight: FontWeight.w400,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 25),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                openUrl(app.settings.appUrl);
              },
              style: ElevatedButton.styleFrom(
                visualDensity: VisualDensity.comfortable,
                backgroundColor: const Color(0xffE2E2E8),
                foregroundColor: const Color(0xff11243E),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('Open App'),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                openUrl(app.link);
              },
              style: ElevatedButton.styleFrom(
                visualDensity: VisualDensity.comfortable,
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('Subscribe with DePlan'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      showAppBar: true,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 25,
              height: 25,
              child: Image.asset('assets/icons/apps_icon.png'),
            ),
            const SizedBox(width: 10),
            const Text('DePlan Store'),
          ],
        ),
      ),
      child: FutureBuilder(
        future: futureFeaturedApps,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          final apps = snapshot.data!;
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Featured',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.separated(
                  itemBuilder: (context, index) => buildApp(apps[index]),
                  separatorBuilder: (context, index) => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(),
                  ),
                  itemCount: apps.length,
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 30),
              ),
            ],
          );
        },
      ),
    );
  }
}
