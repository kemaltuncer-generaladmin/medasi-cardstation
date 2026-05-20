import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class SBShadows {
  const SBShadows._();

  static List<BoxShadow> get card => [
    BoxShadow(
      color: AppColors.navy.withValues(alpha: 0.055),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> get elevated => [
    BoxShadow(
      color: AppColors.blue.withValues(alpha: 0.18),
      blurRadius: 18,
      offset: const Offset(0, 10),
    ),
  ];
}
