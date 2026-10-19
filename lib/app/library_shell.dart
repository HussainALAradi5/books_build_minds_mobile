import 'package:flutter/material.dart';

import '../features/admin/presentation/admin_screen.dart';
import '../features/auth/presentation/auth_screen.dart';
import '../features/catalog/presentation/catalog_screen.dart';
import '../features/profile/presentation/member_library_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../shared/widgets/brand_mark.dart';
import 'app_scope.dart';

class LibraryShell extends StatefulWidget {
  const LibraryShell({super.key, required this.onToggleTheme});

  final VoidCallback onToggleTheme;

  @override
  State<LibraryShell> createState() => _LibraryShellState();
}

class _LibraryShellState extends State<LibraryShell> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    final session = AppScope.of(context).session;
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        final admin = session.user?.isAdmin ?? false;
        final tabs = <Widget>[
          const CatalogScreen(),
          const MemberLibraryScreen(),
          const ProfileScreen(),
          if (admin) const AdminScreen(),
        ];
        final index = selected.clamp(0, tabs.length - 1);
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 18,
            title: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                BrandMark(size: 35),
                SizedBox(width: 10),
                Text(
                  'BOOKS BUILD MINDS',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: .6,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: widget.onToggleTheme,
                icon: const Icon(Icons.brightness_6_outlined),
                tooltip: 'Switch color theme',
              ),
              if (session.user == null)
                IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(builder: (_) => const AuthScreen()),
                  ),
                  icon: const Icon(Icons.login_rounded),
                  tooltip: 'Sign in',
                )
              else
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: CircleAvatar(
                    radius: 16,
                    child: Text(
                      session.user!.userName.isEmpty
                          ? '?'
                          : session.user!.userName[0].toUpperCase(),
                    ),
                  ),
                ),
            ],
          ),
          body: IndexedStack(index: index, children: tabs),
          bottomNavigationBar: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: (value) => setState(() => selected = value),
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(Icons.explore_rounded),
                label: 'Explore',
              ),
              const NavigationDestination(
                icon: Icon(Icons.collections_bookmark_outlined),
                selectedIcon: Icon(Icons.collections_bookmark_rounded),
                label: 'Library',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Account',
              ),
              if (admin)
                const NavigationDestination(
                  icon: Icon(Icons.admin_panel_settings_outlined),
                  selectedIcon: Icon(Icons.admin_panel_settings_rounded),
                  label: 'Admin',
                ),
            ],
          ),
        );
      },
    );
  }
}
