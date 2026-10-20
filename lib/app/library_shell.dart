import 'package:flutter/material.dart';

import '../screens/admin/admin_screen.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/catalog/catalog_screen.dart';
import '../screens/profile/member_library_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../widgets/shared/brand_mark.dart';
import '../widgets/shared/user_avatar.dart';
import '../enums/auth/account_menu_action.dart';
import './app_scope.dart';

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
        final isDark = Theme.of(context).brightness == Brightness.dark;
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
                Flexible(
                  child: Text(
                    'BOOKS BUILD MINDS',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: .6,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: widget.onToggleTheme,
                icon: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                ),
                tooltip: isDark
                    ? 'Switch to light mode'
                    : 'Switch to dark mode',
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
                PopupMenuButton<AccountMenuAction>(
                  tooltip: 'Account options',
                  onSelected: (action) async {
                    if (action == AccountMenuAction.profile) {
                      setState(() => selected = 2);
                    } else {
                      await session.signOut();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: AccountMenuAction.profile,
                      child: Text('View profile'),
                    ),
                    PopupMenuItem(
                      value: AccountMenuAction.signOut,
                      child: Text('Sign out'),
                    ),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: UserAvatar(
                      radius: 17,
                      name: session.user!.userName,
                      imagePath: session.user!.profilePictureUrl,
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
