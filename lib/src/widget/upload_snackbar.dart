import 'package:classroom_app/constant/app_colors.dart';
import 'package:classroom_app/src/widget/loading_indicator_widget.dart';
import 'package:flutter/material.dart';

class DonwloadSnackBar {
  static SnackBar build({required BuildContext context, required String message, required String subtitle, int? durationMilliseconds, required double progress}) {
    return SnackBar(
      //showCloseIcon: true,
      //closeIconColor: Theme.of(context).textTheme.bodyMedium!.color,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      duration: Duration(milliseconds: durationMilliseconds ?? 2000),
      backgroundColor: Theme.of(context).cardTheme.color!.withAlpha(200),

      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              height: 35,
              width: 35,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: const LoadingIndicatorWidget(size: 30)),
          const SizedBox(width: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    softWrap: true,
                    message,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                  ),
                  Text(
                    softWrap: true,
                    subtitle,
                    style: const TextStyle(fontSize: 14, color: AppColors.darkGrey),
                  ),
                ],
              ),
            ),
          ),
          Text(
            softWrap: true,
            '$progress',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium!.color,
            ),
          ),
        ],
      ),
    );
  }
}
