import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../pages/account_page.dart';
import '../pages/home_page.dart';
import '../pages/nearby_page.dart';
import '../providers/scaffold_provider.dart';

class AppScaffold extends ConsumerStatefulWidget {
  const AppScaffold({super.key});

  @override
  ConsumerState<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends ConsumerState<AppScaffold> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int currentPageIndex = 0;

  static const List<Widget> pages = <Widget>[
    HomePage(),
    NearbyPage(),
    AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    ref.listen(appScaffoldProvider, (previousState, newState) {
      if (newState && !(scaffoldKey.currentState?.isDrawerOpen ?? false)) {
        scaffoldKey.currentState?.openDrawer();
      } else if (!newState &&
          (scaffoldKey.currentState?.isDrawerOpen ?? false)) {
        scaffoldKey.currentState?.closeDrawer();
      }
    });

    return Scaffold(
      key: scaffoldKey,
      drawer: NavigationDrawer(
        backgroundColor: Colors.white,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
              child: Text(
                'Header test',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
        ],
      ),

      onDrawerChanged: (isOpened) {
        final providerShouldBeOpen = ref.read(appScaffoldProvider);

        if (isOpened != providerShouldBeOpen) {
          ref.read(appScaffoldProvider.notifier).toggleDrawer();
        }
      },
      body: pages[currentPageIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.business_sharp),
            label: 'Nearby',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_2_rounded),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
