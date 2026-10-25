import 'package:flutter/material.dart';

class ResponsiveFieldRow extends StatelessWidget {
  const ResponsiveFieldRow({
    super.key,
    required this.first,
    required this.second,
    this.minimumWidth = 320,
  });

  final Widget first;
  final Widget second;
  final double minimumWidth;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => constraints.maxWidth >= minimumWidth
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: first),
              const SizedBox(width: 12),
              Expanded(child: second),
            ],
          )
        : Column(children: [first, const SizedBox(height: 12), second]),
  );
}
