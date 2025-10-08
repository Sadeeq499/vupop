import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:socials_app/repositories/profile_repo.dart';
import 'package:socials_app/services/session_services.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_styles.dart';
import 'package:socials_app/views/custom_widgets/user_follow_row.dart';

class ShareOptionsBottomSheet extends StatelessWidget {
  final Function onInAppShare;
  final String videoLink;
  final Function onShareSuccess;

  const ShareOptionsBottomSheet({
    super.key,
    required this.onInAppShare,
    required this.videoLink,
    required this.onShareSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(height: 10),
        ListTile(
          leading: const Icon(
            Icons.share_outlined,
            color: kPrimaryColor,
            size: 30,
          ),
          title: Text(
            'Share within the app',
            style: AppStyles.labelTextStyle().copyWith(
              color: kWhiteColor,
              fontSize: 16.sp,
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            onInAppShare();
          },
        ),
        const Divider(
          height: 1,
          thickness: 1,
        ),
        ListTile(
          leading: const Icon(
            Icons.ios_share_outlined,
            color: kPrimaryColor,
            size: 30,
          ),
          title: Text(
            'Share with other apps',
            style: AppStyles.labelTextStyle().copyWith(
              color: kWhiteColor,
              fontSize: 16.sp,
            ),
          ),
          onTap: () async {
            Navigator.pop(context);
            ShareResult shareResult =
                await Share.share(videoLink, subject: 'Check out this video');
            if (shareResult.status == ShareResultStatus.success) {
              onShareSuccess();
            }
          },
        ),
      ],
    );
  }
}
