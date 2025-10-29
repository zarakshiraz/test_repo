import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';

class MainPage extends StatefulWidget {
  final Widget child;

  const MainPage({
    super.key,
    required this.child,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<NavigationDestination> _destinations = [
    const NavigationDestination(
      icon: Icon(Icons.list_alt_outlined),
      selectedIcon: Icon(Icons.list_alt),
      label: 'Lists',
    ),
    const NavigationDestination(
      icon: Icon(Icons.bookmark_outline),
      selectedIcon: Icon(Icons.bookmark),
      label: 'Saved',
    ),
    const NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        context.go(AppRouter.lists);
        break;
      case 1:
        // TODO: Navigate to saved lists
        context.go(AppRouter.lists);
        break;
      case 2:
        context.go(AppRouter.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: _destinations,
        elevation: 8,
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: Theme.of(context).primaryColor.withOpacity(0.2),
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => context.go('${AppRouter.lists}/create'),
              tooltip: 'Create New List',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}