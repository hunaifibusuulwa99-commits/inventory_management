import 'package:flutter/material.dart';

import '../theme.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 34});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(Icons.inventory_2_rounded, color: Colors.white, size: size * 0.56),
    );
  }
}

class BrandName extends StatelessWidget {
  const BrandName({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BrandLogo(size: 32),
        SizedBox(width: 9),
        Text(
          'stockwise',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: -0.4),
        ),
      ],
    );
  }
}
