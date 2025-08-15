import 'package:PiliPlus/common/widgets/image/image_save.dart';
import 'package:PiliPlus/common/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/models/dynamics/result.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:flutter/material.dart';

Widget livePanel(
  ThemeData theme,
  bool isDetail,
  DynamicItemModel item,
  BuildContext context, {
  int floor = 1,
}) {
  DynamicMajorModel? content = item.modules.moduleDynamic!.major;
  if (content == null) {
    return const SizedBox.shrink();
  }
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => PageUtils.toLiveRoom(content.live?.id),
        onLongPress: () {
          Feedback.forLongPress(context);
          imageSaveDialog(
            title: content.live!.title,
            cover: content.live!.cover,
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NetworkImgLayer(
              width: 120,
              height: 75,
              src: content.live!.cover,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.live!.title!,
                    maxLines: isDetail ? null : 2,
                    overflow: isDetail ? null : TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (content.live?.descFirst != null)
                    Text(
                      content.live!.descFirst!,
                      style: TextStyle(
                        color: theme.colorScheme.outline,
                        fontSize: theme.textTheme.labelMedium!.fontSize,
                      ),
                    ),
                ],
              ),
            ),
            if (content.live!.badge?.text != null)
              Text(
                content.live!.badge!.text!,
                style: TextStyle(
                  fontSize: theme.textTheme.labelMedium!.fontSize,
                ),
              ),
          ],
        ),
      ),
    ],
  );
}
