import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../enums/auth/user_role.dart';
import '../../widgets/shared/brand_mark.dart';
import '../../widgets/shared/state_panel.dart';
import '../../widgets/shared/status_badge.dart';
import '../../widgets/shared/user_avatar.dart';
import '../auth/auth_screen.dart';
import '../../services/media/media_service.dart';
import '../../widgets/shared/image_picker_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = AppScope.of(context).session;
    final user = session.user;
    if (user == null) {
      return StatePanel(
        icon: Icons.person_outline_rounded,
        title: 'A little space for you',
        message: 'Sign in to manage your account and reading journey.',
        actionLabel: 'Sign in',
        onAction: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => const AuthScreen()),
        ),
      );
    }
    final colors = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'YOUR ACCOUNT',
          style: TextStyle(
            color: colors.primary,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w800,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 8),
        Text('Your profile', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    UserAvatar(
                      radius: 31,
                      name: user.userName,
                      imagePath: user.profilePictureUrl,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.userName,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 5),
                          StatusBadge(
                            label: user.role.label,
                            color: user.role.color,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 30),
                if (user.permissions.contains('profile-media:write.own')) ...[
                  ImagePickerButton(
                    label: 'Change profile photo',
                    onPicked: (files) async {
                      await MediaService(AppScope.of(context).api)
                          .uploadProfile(files.single);
                      await session.refresh();
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  'EMAIL ADDRESS',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 5),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Icon(Icons.shield_outlined, color: colors.primary),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Your library account is protected by the server.',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.collections_bookmark_outlined),
                title: const Text('Your books and loans'),
                subtitle: const Text(
                  'Open the Library tab to see your reading history.',
                ),
              ),
              const Divider(height: 1, indent: 20, endIndent: 20),
              ListTile(
                leading: const Icon(Icons.lock_outline_rounded),
                title: const Text('Permissions'),
                subtitle: Text(
                  '${user.permissions.length} effective access rules',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: () async {
            await session.signOut();
          },
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Sign out'),
        ),
        const SizedBox(height: 24),
        const Center(child: BrandMark(size: 30)),
        const SizedBox(height: 7),
        const Center(child: Text('Good books. Open minds.')),
      ],
    );
  }
}
