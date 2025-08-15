// 内容
import 'package:PiliPlus/common/widgets/custom_icon.dart';
import 'package:PiliPlus/common/widgets/image/image_view.dart';
import 'package:PiliPlus/common/widgets/text/text.dart' as custom_text;
import 'package:PiliPlus/models/dynamics/result.dart';
import 'package:PiliPlus/pages/dynamics/widgets/rich_node_panel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget content(
  ThemeData theme,
  bool isSave,
  BuildContext context,
  DynamicItemModel item,
  bool isDetail,
  Function(List<String>, int)? callback, {
  floor = 1,
  required double maxWidth,
}) {
  if (floor == 1) {
    maxWidth -= 24;
  }
  TextSpan? richNodes = richNode(theme, item, context, maxWidth: maxWidth);
  return Padding(
    padding: floor == 1
        ? const EdgeInsets.fromLTRB(12, 0, 12, 6)
        : const EdgeInsets.only(bottom: 6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.modules.moduleDynamic?.topic != null)
          GestureDetector(
            onTap: () => Get.toNamed(
              '/dynTopic',
              parameters: {
                'id': item.modules.moduleDynamic!.topic!.id!.toString(),
                'name': item.modules.moduleDynamic!.topic!.name!,
              },
            ),
            child: Text.rich(
              TextSpan(
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.bottom,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        size: 18,
                        CustomIcon.topic_tag,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  TextSpan(text: item.modules.moduleDynamic!.topic!.name),
                ],
              ),
              style: TextStyle(
                fontSize: floor != 1
                    ? 14
                    : isDetail && !isSave
                    ? 16
                    : 15,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        if (richNodes != null)
          isDetail && floor == 1
              ? SelectableText.rich(
                  richNodes,
                  style: isSave
                      ? const TextStyle(fontSize: 15)
                      : const TextStyle(fontSize: 16),
                )
              : custom_text.Text.rich(
                  style: floor == 1
                      ? const TextStyle(fontSize: 15)
                      : const TextStyle(fontSize: 14),
                  richNodes,
                  maxLines: isSave ? null : 6,
                ),
        if (item.modules.moduleDynamic?.major?.opus?.pics?.isNotEmpty == true)
          imageView(
            maxWidth,
            item.modules.moduleDynamic!.major!.opus!.pics!
                .map(
                  (item) => ImageModel(
                    width: item.width,
                    height: item.height,
                    url: item.url ?? '',
                    liveUrl: item.liveUrl,
                  ),
                )
                .toList(),
            callback: callback,
          ),
      ],
    ),
  );
}
