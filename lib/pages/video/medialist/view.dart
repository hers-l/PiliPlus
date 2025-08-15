import 'package:PiliPlus/common/widgets/badge.dart';
import 'package:PiliPlus/common/widgets/button/icon_button.dart';
import 'package:PiliPlus/common/widgets/dialog/dialog.dart';
import 'package:PiliPlus/common/widgets/image/image_save.dart';
import 'package:PiliPlus/common/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/common/widgets/refresh_indicator.dart';
import 'package:PiliPlus/common/widgets/stat/stat.dart';
import 'package:PiliPlus/models/common/badge_type.dart';
import 'package:PiliPlus/models/common/stat_type.dart';
import 'package:PiliPlus/models_new/media_list/media_list.dart';
import 'package:PiliPlus/models_new/video/video_detail/episode.dart';
import 'package:PiliPlus/pages/common/slide/common_collapse_slide_page.dart';
import 'package:PiliPlus/utils/duration_util.dart';
import 'package:flutter/material.dart' hide RefreshCallback;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class MediaListPanel extends CommonCollapseSlidePage {
  const MediaListPanel({
    super.key,
    required this.mediaList,
    required this.onChangeEpisode,
    this.panelTitle,
    required this.getBvId,
    required this.loadMoreMedia,
    required this.count,
    required this.desc,
    required this.onReverse,
    required this.loadPrevious,
    this.onDelete,
  });

  final List<MediaListItemModel> mediaList;
  final ValueChanged<BaseEpisodeItem> onChangeEpisode;
  final String? panelTitle;
  final Function getBvId;
  final VoidCallback loadMoreMedia;
  final int? count;
  final bool desc;
  final VoidCallback onReverse;
  final RefreshCallback? loadPrevious;
  final Function(MediaListItemModel item, int index)? onDelete;

  @override
  State<MediaListPanel> createState() => _MediaListPanelState();
}

class _MediaListPanelState
    extends CommonCollapseSlidePageState<MediaListPanel> {
  late final int _index;

  @override
  void initState() {
    super.initState();
    final bvid = widget.getBvId();
    final bvIndex = widget.mediaList.indexWhere((item) => item.bvid == bvid);
    _index = bvIndex == -1 ? 0 : bvIndex;
  }

  @override
  Widget buildPage(ThemeData theme) {
    return Material(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          AppBar(
            toolbarHeight: 45,
            automaticallyImplyLeading: false,
            titleSpacing: 16,
            title: Text(widget.panelTitle ?? '稍后再看'),
            backgroundColor: Colors.transparent,
            actions: [
              mediumButton(
                tooltip: widget.desc ? '顺序播放' : '倒序播放',
                icon: widget.desc
                    ? MdiIcons.sortAscending
                    : MdiIcons.sortDescending,
                onPressed: () {
                  Get.back();
                  widget.onReverse();
                },
              ),
              mediumButton(
                tooltip: '关闭',
                icon: Icons.close,
                onPressed: Get.back,
              ),
              const SizedBox(width: 14),
            ],
          ),
          Divider(
            height: 1,
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
          Expanded(
            child: enableSlide ? slideList(theme) : buildList(theme),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildList(ThemeData theme) {
    return widget.loadPrevious != null
        ? refreshIndicator(
            onRefresh: widget.loadPrevious!,
            child: _buildList(theme),
          )
        : _buildList(theme);
  }

  Widget _buildList(ThemeData theme) => Obx(
    () {
      final showDelBtn = widget.onDelete != null && widget.mediaList.length > 1;
      return ScrollablePositionedList.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: widget.mediaList.length,
        initialScrollIndex: _index,
        padding: EdgeInsets.only(
          top: 7,
          bottom: MediaQuery.paddingOf(context).bottom + 80,
        ),
        itemBuilder: ((context, index) {
          if (index == widget.mediaList.length - 1 &&
              (widget.count == null ||
                  widget.mediaList.length < widget.count!)) {
            widget.loadMoreMedia();
          }
          var item = widget.mediaList[index];
          final isCurr = item.bvid == widget.getBvId();
          return _buildItem(theme, index, item, isCurr, showDelBtn);
        }),
        separatorBuilder: (context, index) => const SizedBox(height: 2),
      );
    },
  );

  Widget _buildItem(
    ThemeData theme,
    int index,
    MediaListItemModel item,
    bool isCurr,
    bool showDelBtn,
  ) {
    return SizedBox(
      height: 98,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () {
            if (item.type != 2) {
              SmartDialog.showToast('不支持播放该类型视频');
              return;
            }
            Get.back();
            widget.onChangeEpisode(item);
          },
          onLongPress: () => imageSaveDialog(
            title: item.title,
            cover: item.cover,
            aid: item.aid,
            bvid: item.bvid,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        NetworkImgLayer(
                          src: item.cover,
                          width: 140.8,
                          height: 88,
                        ),
                        if (item.badge?.isNotEmpty == true)
                          PBadge(
                            text: item.badge,
                            right: 6.0,
                            top: 6.0,
                            type: switch (item.badge) {
                              '充电专属' => PBadgeType.error,
                              _ => PBadgeType.primary,
                            },
                          ),
                        PBadge(
                          text: DurationUtil.formatDuration(
                            item.duration,
                          ),
                          right: 6.0,
                          bottom: 6.0,
                          type: PBadgeType.gray,
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: isCurr ? FontWeight.bold : null,
                              color: isCurr ? theme.colorScheme.primary : null,
                            ),
                          ),
                          if (item.type == 24 &&
                              item.intro?.isNotEmpty == true) ...[
                            const SizedBox(height: 3),
                            Text(
                              item.intro!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                          const Spacer(),
                          Text(
                            item.upper!.name!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          if (item.type == 2) ...[
                            const SizedBox(height: 3),
                            Row(
                              spacing: 8,
                              children: [
                                StatWidget(
                                  type: StatType.play,
                                  value: item.cntInfo!.play,
                                ),
                                StatWidget(
                                  type: StatType.danmaku,
                                  value: item.cntInfo!.danmaku,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (showDelBtn && !isCurr)
                Positioned(
                  right: 12,
                  bottom: -6,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => showConfirmDialog(
                      context: context,
                      title: '确定移除该视频？',
                      onConfirm: () => widget.onDelete!(item, index),
                    ),
                    onLongPress: () => widget.onDelete!(item, index),
                    child: Padding(
                      padding: const EdgeInsets.all(9),
                      child: Icon(
                        Icons.clear,
                        size: 18,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
