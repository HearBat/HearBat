import 'package:flutter/material.dart';
import 'home_page.dart';
import 'profile_page.dart';

class MyNavBar extends StatefulWidget {
  @override
  State<MyNavBar> createState() => _MyNavBarState();
}

class _MyNavBarState extends State<MyNavBar> {
  int selectedIndex = 0;
  Key _profilePageKey = UniqueKey();
  
  // Store navigation keys to maintain state
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
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
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: _selectTab,
          destinations: const <Widget>[
            NavigationDestination(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  void _selectTab(int index) {
    setState(() {
      if (index == 1 && selectedIndex != 1) {
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
              return index == 0 ?
                HomePage() :
                ProfilePage(key: _profilePageKey);
            },
          );
        },
      ),
    );
  }
}