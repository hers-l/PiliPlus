import 'dart:math';

import 'package:PiliPlus/common/widgets/custom_icon.dart';
import 'package:PiliPlus/common/widgets/refresh_indicator.dart';
import 'package:PiliPlus/http/constants.dart';
import 'package:PiliPlus/models/dynamics/result.dart';
import 'package:PiliPlus/pages/common/dyn/common_dyn_page.dart';
import 'package:PiliPlus/pages/dynamics/widgets/author_panel.dart';
import 'package:PiliPlus/pages/dynamics/widgets/dynamic_panel.dart';
import 'package:PiliPlus/pages/dynamics_detail/controller.dart';
import 'package:PiliPlus/pages/dynamics_repost/view.dart';
import 'package:PiliPlus/utils/context_ext.dart';
import 'package:PiliPlus/utils/feed_back.dart';
import 'package:PiliPlus/utils/grid.dart';
import 'package:PiliPlus/utils/num_util.dart';
import 'package:PiliPlus/utils/request_utils.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/storage_key.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart' hide ContextExtensionss;

class DynamicDetailPage extends CommonDynPage {
  const DynamicDetailPage({super.key});

  @override
  State<DynamicDetailPage> createState() => _DynamicDetailPageState();
}

class _DynamicDetailPageState extends CommonDynPageState<DynamicDetailPage> {
  @override
  final DynamicDetailController controller = Get.put(
    DynamicDetailController(),
    tag: Utils.generateRandomString(8),
  );

  @override
  dynamic get arguments => {
    'item': controller.dynItem,
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.scrollController.hasClients) {
        controller.showTitle.value =
            controller.scrollController.positions.first.pixels > 55;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPortrait = context.isPortrait;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Obx(
            () {
              final showTitle = controller.showTitle.value;
              return AnimatedOpacity(
                opacity: showTitle ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: IgnorePointer(
                  ignoring: !showTitle,
                  child: AuthorPanel(
                    item: controller.dynItem,
                    isDetail: true,
                  ),
                ),
              );
            },
          ),
        ),
        actions: isPortrait
            ? null
            : [
                IconButton(
                  tooltip: '页面比例调节',
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        margin: const EdgeInsets.only(
                          top: 56,
                          right: 16,
                        ),
                        width: context.width / 4,
                        height: 32,
                        child: Builder(
                          builder: (context) => Slider(
                            min: 1,
                            max: 100,
                            value: controller.ratio.first,
                            onChanged: (value) {
                              if (value >= 10 && value <= 90) {
                                value = value.toPrecision(2);
                                controller.ratio
                                  ..[0] = value
                                  ..[1] = 100 - value;
                                GStorage.setting.put(
                                  SettingBoxKey.dynamicDetailRatio,
                                  controller.ratio,
                                );
                                (context as Element).markNeedsBuild();
                                setState(() {});
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  icon: Transform.rotate(
                    angle: pi / 2,
                    child: const Icon(Icons.splitscreen, size: 19),
                  ),
                ),
                const SizedBox(width: 16),
              ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: isPortrait
            ? refreshIndicator(
                onRefresh: controller.onRefresh,
                child: _buildBody(isPortrait, theme),
              )
            : _buildBody(isPortrait, theme),
      ),
    );
  }

  Widget _buildBody(bool isPortrait, ThemeData theme) => Stack(
    clipBehavior: Clip.none,
    children: [
      Builder(
        builder: (context) {
          double padding = max(context.width / 2 - Grid.smallCardWidth, 0);
          if (isPortrait) {
            return CustomScrollView(
              controller: controller.scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  sliver: SliverMainAxisGroup(
                    slivers: [
                      SliverToBoxAdapter(
                        child: LayoutBuilder(
                          builder: (_, constrains) => DynamicPanel(
                            item: controller.dynItem,
                            isDetail: true,
                            callback: imageCallback,
                            maxWidth: constrains.maxWidth,
                          ),
                        ),
                      ),
                      buildReplyHeader(theme),
                      Obx(
                        () => replyList(theme, controller.loadingState.value),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Row(
              children: [
                Expanded(
                  flex: controller.ratio[0].toInt(),
                  child: CustomScrollView(
                    controller: controller.scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.only(
                          left: padding / 4,
                          bottom: MediaQuery.paddingOf(context).bottom + 80,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: LayoutBuilder(
                            builder: (_, constraints) => DynamicPanel(
                              item: controller.dynItem,
                              isDetail: true,
                              callback: imageCallback,
                              maxWidth: constraints.maxWidth,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: controller.ratio[1].toInt(),
                  child: Scaffold(
                    key: scaffoldKey,
                    backgroundColor: Colors.transparent,
                    body: refreshIndicator(
                      onRefresh: controller.onRefresh,
                      child: CustomScrollView(
                        controller: controller.scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverPadding(
                            padding: EdgeInsets.only(right: padding / 4),
                            sliver: buildReplyHeader(theme),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.only(right: padding / 4),
                            sliver: Obx(
                              () => replyList(
                                theme,
                                controller.loadingState.value,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
      _buildBottom(theme),
    ],
  );

  Widget _buildBottom(ThemeData theme) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SlideTransition(
        position: controller.fabAnim,
        child: Builder(
          builder: (context) {
            Widget button() => FloatingActionButton(
              heroTag: null,
              onPressed: () {
                feedBack();
                controller.onReply(
                  context,
                  oid: controller.oid,
                  replyType: controller.replyType,
                );
              },
              tooltip: '评论动态',
              child: const Icon(Icons.reply),
            );

            final bottom = MediaQuery.paddingOf(context).bottom;
            if (!controller.showDynActionBar) {
              return Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.only(
                    right: 14,
                    bottom: bottom + 14,
                  ),
                  child: button(),
                ),
              );
            }

            final moduleStat = controller.dynItem.modules.moduleStat;
            final primary = theme.colorScheme.primary;
            final outline = theme.colorScheme.outline;
            final btnStyle = TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              foregroundColor: outline,
            );

            Widget textIconButton({
              required IconData icon,
              required String text,
              required DynamicStat? stat,
              required VoidCallback onPressed,
              IconData? activitedIcon,
            }) {
              final status = stat?.status == true;
              final color = status ? primary : outline;
              return TextButton.icon(
                onPressed: onPressed,
                icon: Icon(
                  status ? activitedIcon : icon,
                  size: 16,
                  color: color,
                ),
                style: btnStyle,
                label: Text(
                  stat?.count != null ? NumUtil.numFormat(stat!.count) : text,
                  style: TextStyle(color: color),
                ),
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 14, bottom: 14),
                  child: button(),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        color: theme.colorScheme.outline.withValues(
                          alpha: 0.08,
                        ),
                      ),
                    ),
                  ),
                  padding: EdgeInsets.only(bottom: bottom),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: Builder(
                          builder: (btnContext) {
                            final forward = moduleStat?.forward;
                            return textIconButton(
                              icon: FontAwesomeIcons.shareFromSquare,
                              text: '转发',
                              stat: forward,
                              onPressed: () => showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                useSafeArea: true,
                                builder: (context) => RepostPanel(
                                  item: controller.dynItem,
                                  callback: () {
                                    if (forward != null) {
                                      int count = forward.count ?? 0;
                                      forward.count = count + 1;
                                      if (btnContext.mounted) {
                                        (btnContext as Element?)
                                            ?.markNeedsBuild();
                                      }
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: textIconButton(
                          icon: CustomIcon.share_node,
                          text: '分享',
                          stat: null,
                          onPressed: () => Utils.shareText(
                            '${HttpString.dynamicShareBaseUrl}/${controller.dynItem.idStr}',
                          ),
                        ),
                      ),
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            return textIconButton(
                              icon: FontAwesomeIcons.thumbsUp,
                              activitedIcon: FontAwesomeIcons.solidThumbsUp,
                              text: '点赞',
                              stat: moduleStat?.like,
                              onPressed: () => RequestUtils.onLikeDynamic(
                                controller.dynItem,
                                () {
                                  if (context.mounted) {
                                    (context as Element?)?.markNeedsBuild();
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
