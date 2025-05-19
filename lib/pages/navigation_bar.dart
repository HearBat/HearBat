import 'package:flutter/material.dart';

import 'package:hearbat/pages/home_page.dart';
import 'package:hearbat/pages/insights_page.dart';
import 'package:hearbat/pages/profile_page.dart';
import 'package:hearbat/utils/translations.dart';

class MyNavBar extends StatefulWidget {
  @override
  State<MyNavBar> createState() => _MyNavBarState();
}

class _MyNavBarState extends State<MyNavBar> {
  int selectedIndex = 0;
  Key _insightsPageKey = UniqueKey();
  Key _profilePageKey = UniqueKey();

  // Store navigation keys to maintain state
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>()
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, 
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }
        
        final isFirstRouteInCurrentTab = 
            !await _navigatorKeys[selectedIndex].currentState!.maybePop();
        
        if (isFirstRouteInCurrentTab && selectedIndex != 0) {
            _selectTab(0);
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            _buildOffstageNavigator(0),
            _buildOffstageNavigator(1),
            _buildOffstageNavigator(2),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: _selectTab,
          destinations: <Widget>[
            NavigationDestination(
              icon: Icon(Icons.home),
              label: AppLocale.navBarHome.getString(context),
            ),
            NavigationDestination(
              icon: Icon(Icons.query_stats),
              label: AppLocale.navBarInsights.getString(context),
            ),
            NavigationDestination(
              icon: Icon(Icons.person),
              label: AppLocale.navBarProfile.getString(context),
            ),
          ],
        ),
      ),
    );
  }

  void _selectTab(int index) {
    setState(() {
      if (index == 1 && selectedIndex != 1) {
        // Rebuild insights page
        _insightsPageKey = UniqueKey();
      }
      if (index == 2 && selectedIndex != 2) {
        // Rebuild profile page
        _profilePageKey = UniqueKey();
      }
      selectedIndex = index;
    });
  }

  Widget _buildOffstageNavigator(int index) {
    return Offstage(
      offstage: selectedIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
            builder: (context) {
              final pages = [
                HomePage(),
                InsightsPage(key: _insightsPageKey),
                ProfilePage(key: _profilePageKey)];
              return pages[index];
            },
          );
        },
      ),
    );
  }
}