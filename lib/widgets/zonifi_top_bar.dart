import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// ZonifiTopBar: the logo + title + optional back arrow, reused across
/// screens. Change it here once, and every screen using it updates.
class ZonifiTopBar extends StatelessWidget {
  final bool showBackButton;

  const ZonifiTopBar({
    super.key,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (showBackButton)
              Positioned(
                left: 16,
                top: 4,
                child: Icon(
                  Icons.chevron_left,
                  color: AppColors.navy,
                  size: 22,
                ),
              ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppColors.teal,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.wifi, color: Colors.white, size: 18),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Zonifi',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}