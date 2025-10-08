import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_images.dart';

class QualityRulesBottomSheet extends StatelessWidget {
  const QualityRulesBottomSheet({
    super.key,
    this.title = 'Vupop Quality Rules',
    this.description = 'Before uploading your video, please review the following guidelines to ensure your content meets our standards:',
    this.allowedTitle = "What's Allowed",
    this.avoidTitle = 'What to Avoid',
    required this.allowedRules,
    required this.avoidRules,
    this.onConfirm,
    this.confirmText = 'I Understand',
    this.logo,
  });

  final String title;
  final String description;
  final String allowedTitle;
  final String avoidTitle;
  final List<String> allowedRules;
  final List<String> avoidRules;
  final VoidCallback? onConfirm;
  final String confirmText;
  final Widget? logo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = true; // force dark sheet like screenshot
    final bg = const Color(0xFF121212);
    final panel = const Color(0xFF1C1C1E);
    final divider = Colors.white.withOpacity(0.08);
    final green = const Color(0xFF48AD18);
    final red = const Color(0xFFD02A2C);
    final textPrimary = Colors.white;
    final textSecondary = Colors.white.withOpacity(0.78);
    final accentYellow = kPrimaryColor;

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: bg.withOpacity(0.001), // transparent edges
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          decoration: const BoxDecoration(
            color: Color(0xFF1C1C1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // drag handle
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Top row: logo (optional)
                if (logo != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: logo!,
                  ),

                SizedBox(
                  height: 12,
                ),
                // Title
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 24, fontFamily: 'poppins'),
                ),

                const SizedBox(height: 6),

                // Description
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: textSecondary,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 16),
                Container(height: 1, color: divider),
                const SizedBox(height: 16),

                // Allowed Section
                _RuleSection(
                  badgeColor: green,
                  badgeIcon: kAcceptIcon,
                  heading: allowedTitle,
                  bullets: allowedRules,
                  textColor: textPrimary,
                  subtitleColor: textSecondary,
                ),

                const SizedBox(height: 16),

                // Avoid Section
                _RuleSection(
                  badgeColor: red,
                  badgeIcon: kRejectIcon,
                  heading: avoidTitle,
                  bullets: avoidRules,
                  textColor: textPrimary,
                  subtitleColor: textSecondary,
                ),

                const SizedBox(height: 20),

                // Confirm button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back(); // close sheet
                      onConfirm?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentYellow,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                      elevation: 0,
                    ),
                    child: Text(confirmText),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RuleSection extends StatelessWidget {
  const _RuleSection({
    required this.badgeColor,
    required this.badgeIcon,
    required this.heading,
    required this.bullets,
    required this.textColor,
    required this.subtitleColor,
  });

  final Color badgeColor;
  final String badgeIcon;
  final String heading;
  final List<String> bullets;
  final Color textColor;
  final Color subtitleColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            /*CircleAvatar(
              radius: 12,
              backgroundColor: badgeColor.withOpacity(0.15),
              child: Icon(badgeIcon, size: 22, color: badgeColor),
            ),*/

            Image.asset(
              badgeIcon,
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 8),
            Text(
              heading,
              style: theme.textTheme.titleMedium?.copyWith(color: textColor, fontWeight: FontWeight.w600, fontSize: 18, fontFamily: 'poppins'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...bullets.map(
          (b) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Icon(Icons.circle, size: 6, color: Colors.white70),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    b,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: subtitleColor,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
