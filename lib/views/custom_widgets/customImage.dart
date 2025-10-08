import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../utils/app_colors.dart';

class CachedImage extends StatelessWidget {
  final String url;
  final String errorImage;
  final BoxFit fit;
  final double height;
  final double width;
  final bool isCircle;
  final BorderRadius? borderRadius;
  const CachedImage(
      {super.key,
      this.fit = BoxFit.cover,
      this.isCircle = true,
      this.height = 100,
      this.width = 100,
      this.errorImage = 'assets/images/dummypersoon.png',
      this.borderRadius,
      required this.url});

  @override
  Widget build(BuildContext context) {
    return url == ""
        ? ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(110)),
            child: SizedBox(
              height: height,
              width: width,
              child: getImage(),
            ),
          )
        : Container(
            height: height,
            width: width,
            decoration: BoxDecoration(borderRadius: borderRadius, shape: isCircle ? BoxShape.circle : BoxShape.rectangle),
            child: !isCircle ? ClipRRect(borderRadius: BorderRadius.circular(16.0), child: getImage()) : ClipOval(child: getImage()));
  }

  Widget getImage() {
    return url == ""
        ? Image.asset(
            'assets/images/dummypersoon.png',
            fit: BoxFit.fill,
          )
        : CachedNetworkImage(
            imageUrl: url,
            fit: fit,
            progressIndicatorBuilder: (context, url, progress) => Shimmer.fromColors(
                baseColor: kShimmerbaseColor,
                highlightColor: kShimmerhighlightColor,
                child: Container(
                  color: Colors.white,
                )),
            // placeholder: (context, url) => Image.asset(errorImage),
            errorWidget: (context, url, error) => Image.asset(
              errorImage,
              height: height,
              width: width,
              fit: fit,
            ),
          );
  }
}
