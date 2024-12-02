import 'package:cached_network_image/cached_network_image.dart';
import 'package:classroom_app/constant/app_icons.dart';
import 'package:classroom_app/src/widget/loading_indicator_widget.dart';
import 'package:flutter/material.dart';

class FileIconHelper {
  /// Get the appropriate widget for a file type
  static Widget getWidgetForFile({
    required String extension,
    String? imageUrl,
    double iconSize = 24.0,
  }) {
    switch (extension.toLowerCase()) {
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
        if (imageUrl != null && imageUrl.isNotEmpty) {
          return CachedNetworkImage(
            imageUrl: imageUrl,
            imageBuilder: (context, imageProvider) => Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
              ),
            ),
            placeholder: (context, url) => Container(height: iconSize, width: iconSize, alignment: Alignment.center, child: const LoadingIndicatorWidget(size: 20)),
            errorWidget: (context, url, error) => Icon(
              Icons.image_not_supported,
              size: iconSize,
              color: Colors.grey,
            ),
            fit: BoxFit.cover,
          );
        } else {
          return Icon(
            Icons.image,
            size: iconSize,
            color: Colors.grey,
          );
        }
      case 'pdf':
        return Image.asset(AppIcons.pdf, height: iconSize, width: iconSize);
      case 'doc':
      case 'docx':
        return Image.asset(AppIcons.word, height: iconSize, width: iconSize);
      case 'ppt':
      case 'pptx':
        return Image.asset(AppIcons.powerpoint, height: iconSize, width: iconSize);
      case 'xls':
      case 'xlsx':
        return Image.asset(AppIcons.excel, height: iconSize, width: iconSize);
      case 'rar':
      case 'zip':
        return Image.asset(AppIcons.winrar, height: iconSize, width: iconSize);
      case 'txt':
        return Image.asset(AppIcons.text, height: iconSize, width: iconSize);
      default:
        return Image.asset(AppIcons.file, height: iconSize, width: iconSize);
    }
  }
}
