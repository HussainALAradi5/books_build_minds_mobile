import 'package:flutter/material.dart';

import '../shared/network/api_client.dart';
import '../controllers/auth/session_controller.dart';
import './app_scope.dart';
import './library_shell.dart';
import './library_theme.dart';

class LibraryApp extends StatefulWidget {
  const LibraryApp({super.key, required this.api, required this.session});

  final ApiClient api;
  final SessionController session;

  @override
  State<LibraryApp> createState() => _LibraryAppState();
}

class _LibraryAppState extends State<LibraryApp> {
  ThemeMode mode = ThemeMode.system;

  @override
  Widget build(BuildContext context) => AppScope(
    api: widget.api,
    session: widget.session,
    child: MaterialApp(
      title: 'Books Build Minds',
      debugShowCheckedModeBanner: false,
      theme: LibraryTheme.build(Brightness.light),
      darkTheme: LibraryTheme.build(Brightness.dark),
      themeMode: mode,
      home: LibraryShell(
        onToggleTheme: () => setState(() {
          mode = mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
        }),
      ),
    ),
  );
}
