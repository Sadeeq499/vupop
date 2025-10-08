import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:socials_app/models/post_models.dart' as postmodel;
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_styles.dart';
import 'package:socials_app/views/custom_widgets/CustomImage.dart';

class ViewedBy extends StatelessWidget {
  final List<postmodel.ViewsModel> viewedBy;
  final VoidCallback? onTap;

  const ViewedBy({
    super.key,
    required this.viewedBy,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: 60.h,
      width: 160.w,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Viewed By",
              style: AppStyles.labelTextStyle().copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          /// clipreact to show the image in circle with overlapping each other
          GestureDetector(
            onTap: onTap,
            child: SizedBox(
              height: 35.h,
              width: 150.w,
              child: viewedBy.isEmpty
                  ? Align(
                      alignment: Alignment.centerLeft,
                      child: CircleAvatar(
                        backgroundColor: kPrimaryColor,
                        radius: 38.w,
                        child: Text(
                          '0',
                          style: TextStyle(fontSize: 15.sp),
                        ),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: viewedBy.length > 3 ? 4 : viewedBy.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        if (index < 3) {
                          return Transform.translate(
                            offset: Offset(-20.0 * index, 0),
                            child: CachedImage(
                              url: viewedBy[index].image ?? '',
                              isCircle: true,
                              width: 40.w,
                              height: 30.h,
                              fit: BoxFit.fill,
                            ),
                          );
                        } else {
                          return Transform.translate(
                            offset: Offset(-25.0 * index, 0),
                            child: CircleAvatar(
                              backgroundColor: kPrimaryColor,
                              radius: 28.w,
                              child: Text(
                                '+${viewedBy.length - 3}',
                                style: TextStyle(fontSize: 15.sp),
                              ),
                            ),
                          );
                        }
                      },
                    ),
            ),
          )
        ],
      ),
    );
  }
}
