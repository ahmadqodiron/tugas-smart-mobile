import 'package:flutter/material.dart';

import '../utils/constants.dart';
import 'cart_screen.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';

/// Represents a navigation item with its properties
class NavigationItem {
  const NavigationItem({
    required this.icon,
    required this.label,
    required this.screen,
  });

  final IconData icon;
  final String label;
  final Widget screen;
}

/// Main navigation widget with bottom navigation bar
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => MainNavigationState();

  /// Provides access to the MainNavigationState from descendant widgets
  static MainNavigationState? of(BuildContext context) {
    return context.findAncestorStateOfType<MainNavigationState>();
  }
}

class MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  /// List of navigation items with their screens
  static const List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home,
      label: 'Home',
      screen: HomeScreen(),
    ),
    NavigationItem(
      icon: Icons.favorite_border,
      label: 'Favorite',
      screen: FavoritesScreen(),
    ),
    NavigationItem(
      icon: Icons.shopping_cart,
      label: 'Cart',
      screen: CartScreen(),
    ),
    NavigationItem(
      icon: Icons.search,
      label: 'Search',
      screen: SearchScreen(),
    ),
    NavigationItem(
      icon: Icons.person,
      label: 'Profile',
      screen: ProfileScreen(),
    ),
  ];

  /// Sets the selected index programmatically
  void setIndex(int index) {
    if (index < 0 || index >= _navigationItems.length) {
      // Log error or handle invalid index
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Handles tap on navigation items
  void _onItemTapped(int index) {
    setIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _navigationItems.map((item) => item.screen).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color.fromARGB(255, 255, 255, 255),
        unselectedItemColor: AppColors.navUnselected,
        showUnselectedLabels: true,
        selectedIconTheme: const IconThemeData(
          size: 27,
          opacity: 1.0,
        ),
        unselectedIconTheme: const IconThemeData(
          size: 24,
          opacity: 1.0,
        ),
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        items: _navigationItems
            .map(
              (item) => BottomNavigationBarItem(
                icon: Icon(item.icon),
                activeIcon: item.label == 'Favorite' ? const Icon(Icons.favorite) : Icon(item.icon),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }
}