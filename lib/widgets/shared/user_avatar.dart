import 'package:flutter/material.dart';

import '../../app/app_scope.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.name,
    this.imagePath,
    this.radius = 19,
  });

  final String name;
  final String? imagePath;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final image = imagePath;
    final api = AppScope.of(context).api;
    return CircleAvatar(
      radius: radius,
      backgroundImage: image == null
          ? null
          : NetworkImage(api.assetUri(image).toString()),
      child: image == null
          ? Text(name.isEmpty ? '?' : name[0].toUpperCase())
          : null,
    );
  }
}
