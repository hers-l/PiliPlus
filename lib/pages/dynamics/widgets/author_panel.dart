import 'dart:math';

import 'package:PiliPlus/common/constants.dart';
import 'package:PiliPlus/common/widgets/dialog/report.dart';
import 'package:PiliPlus/common/widgets/pendant_avatar.dart';
import 'package:PiliPlus/http/constants.dart';
import 'package:PiliPlus/http/user.dart';
import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/models/dynamics/result.dart';
import 'package:PiliPlus/pages/dynamics/controller.dart';
import 'package:PiliPlus/pages/save_panel/view.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:PiliPlus/utils/context_ext.dart';
import 'package:PiliPlus/utils/date_util.dart';
import 'package:PiliPlus/utils/extension.dart';
import 'package:PiliPlus/utils/feed_back.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/utils/request_utils.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart' hide ContextExtensionss;

class AuthorPanel extends StatelessWidget {
  final DynamicItemModel item;
  final Function? addBannedList;
  final bool isDetail;
  final ValueChanged? onRemove;
  final bool isSave;
  final Function(bool isTop, dynamic dynId)? onSetTop;
  final VoidCallback? onBlock;

  const AuthorPanel({
    super.key,
    required this.item,
    this.addBannedList,
    this.isDetail = false,
    this.onRemove,
    this.isSave = false,
    this.onSetTop,
    this.onBlock,
  });

  Widget _buildAvatar() {
    String? pendant = item.modules.moduleAuthor?.pendant?.image;
    Widget avatar = PendantAvatar(
      avatar: item.modules.moduleAuthor?.face,
      size: pendant.isNullOrEmpty ? 40 : 34,
      isVip: null,
      officialType: null, // 已被注释
      garbPendantImage: pendant,
    );
    if (!pendant.isNullOrEmpty) {
      avatar = Padding(padding: const EdgeInsets.all(3), child: avatar);
    }
    return avatar;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pubTime = item.modules.moduleAuthor?.pubTs != null
        ? isSave
              ? DateUtil.format(
                  item.modules.moduleAuthor!.pubTs,
                  format: DateUtil.longFormatDs,
                )
              : DateUtil.dateFormat(item.modules.moduleAuthor!.pubTs)
        : item.modules.moduleAuthor?.pubTime;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: item.modules.moduleAuthor!.type == 'AUTHOR_TYPE_NORMAL'
                ? () {
                    feedBack();
                    Get.toNamed(
                      '/member?mid=${item.modules.moduleAuthor!.mid}',
                    );
                  }
                : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAvatar(),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.modules.moduleAuthor?.name ?? '',
                      style: TextStyle(
                        color:
                            item.modules.moduleAuthor!.vip != null &&
                                item.modules.moduleAuthor!.vip!.status > 0 &&
                                item.modules.moduleAuthor!.vip!.type == 2
                            ? theme.colorScheme.vipColor
                            : theme.colorScheme.onSurface,
                        fontSize: theme.textTheme.titleSmall!.fontSize,
                      ),
                    ),
                    if (pubTime != null)
                      Text(
                        '$pubTime${item.modules.moduleAuthor?.pubAction != null ? ' ${item.modules.moduleAuthor!.pubAction}' : ''}',
                        style: TextStyle(
                          color: theme.colorScheme.outline,
                          fontSize: theme.textTheme.labelSmall!.fontSize,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: !isDetail && item.modules.moduleTag?.text != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(4),
                        ),
                        border: Border.all(
                          width: 1.25,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      child: Text(
                        item.modules.moduleTag!.text!,
                        style: TextStyle(
                          height: 1,
                          fontSize: 12,
                          color: theme.colorScheme.primary,
                        ),
                        strutStyle: const StrutStyle(
                          leading: 0,
                          height: 1,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    _moreWidget(context),
                  ],
                )
              : item.modules.moduleAuthor!.decorate != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.centerRight,
                      children: [
                        CachedNetworkImage(
                          height: 32,
                          imageUrl: item
                              .modules
                              .moduleAuthor!
                              .decorate!
                              .cardUrl
                              .http2https,
                        ),
                        if (item
                                .modules
                                .moduleAuthor
                                ?.decorate
                                ?.fan
                                ?.numStr
                                ?.isNotEmpty ==
                            true)
                          Padding(
                            padding: const EdgeInsets.only(right: 32),
                            child: Text(
                              '${item.modules.moduleAuthor!.decorate!.fan!.numStr}',
                              style: TextStyle(
                                height: 1,
                                fontSize: 11,
                                fontFamily: 'digital_id_num',
                                color:
                                    item
                                            .modules
                                            .moduleAuthor!
                                            .decorate!
                                            .fan
                                            ?.color
                                            ?.startsWith('#') ==
                                        true
                                    ? Color(
                                        int.parse(
                                          item
                                              .modules
                                              .moduleAuthor!
                                              .decorate!
                                              .fan!
                                              .color!
                                              .replaceFirst('#', '0xFF'),
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                      ],
                    ),
                    _moreWidget(context),
                  ],
                )
              : _moreWidget(context),
        ),
      ],
    );
  }

  Widget _moreWidget(BuildContext context) => isSave
      ? const SizedBox.shrink()
      : SizedBox(
          width: 32,
          height: 32,
          child: IconButton(
            tooltip: '更多',
            style: ButtonStyle(
              padding: WidgetStateProperty.all(EdgeInsets.zero),
            ),
            onPressed: () => morePanel(context),
            icon: const Icon(Icons.more_vert_outlined, size: 18),
          ),
        );

  void morePanel(BuildContext context) {
    String? bvid;
    try {
      String? getBvid(String? type, DynamicMajorModel? major) => switch (type) {
        'DYNAMIC_TYPE_AV' => major?.archive?.bvid,
        'DYNAMIC_TYPE_UGC_SEASON' => major?.ugcSeason?.bvid,
        _ => null,
      };
      bvid = getBvid(item.type, item.modules.moduleDynamic?.major);
      if (bvid == null && item.orig != null) {
        bvid = getBvid(
          item.orig!.type,
          item.orig?.modules.moduleDynamic?.major,
        );
      }
    } catch (_) {}

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxWidth: min(640, context.mediaQueryShortestSide),
      ),
      builder: (context1) {
        final theme = Theme.of(context);
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.paddingOf(context1).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: Get.back,
                borderRadius: StyleString.bottomSheetRadius,
                child: Container(
                  height: 35,
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Center(
                    child: Container(
                      width: 32,
                      height: 3,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outline,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (bvid != null)
                ListTile(
                  onTap: () async {
                    Get.back();
                    try {
                      var res = await UserHttp.toViewLater(bvid: bvid);
                      SmartDialog.showToast(res['msg']);
                    } catch (err) {
                      SmartDialog.showToast('出错了：${err.toString()}');
                    }
                  },
                  minLeadingWidth: 0,
                  leading: const Icon(Icons.watch_later_outlined, size: 19),
                  title: Text(
                    '稍后再看',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ListTile(
                onTap: () {
                  Get.back();
                  SavePanel.toSavePanel(item: item);
                },
                minLeadingWidth: 0,
                leading: const Icon(Icons.save_alt, size: 19),
                title: Text('保存动态', style: theme.textTheme.titleSmall!),
              ),
              ListTile(
                title: Text(
                  '分享动态',
                  style: theme.textTheme.titleSmall,
                ),
                leading: const Icon(Icons.share_outlined, size: 19),
                onTap: () {
                  Get.back();
                  Utils.shareText(
                    '${HttpString.dynamicShareBaseUrl}/${item.idStr}',
                  );
                },
                minLeadingWidth: 0,
              ),
              if ((item.basic!.commentType == 17 ||
                      item.basic!.commentType == 11) &&
                  item.modules.moduleDynamic?.major?.blocked == null)
                ListTile(
                  title: Text(
                    '分享至消息',
                    style: theme.textTheme.titleSmall,
                  ),
                  leading: const Icon(Icons.forward_to_inbox, size: 19),
                  onTap: () {
                    Get.back();
                    try {
                      bool isDyn = item.basic!.commentType == 17;
                      String id = isDyn ? item.idStr : item.basic!.ridStr!;
                      int source = isDyn ? 11 : 2;
                      String title;
                      if (item.modules.moduleDynamic?.desc != null) {
                        title = item.modules.moduleDynamic!.desc!.text!;
                      } else if (item.modules.moduleDynamic?.major != null) {
                        title = item
                            .modules
                            .moduleDynamic!
                            .major!
                            .opus!
                            .summary!
                            .text!;
                      } else {
                        throw UnsupportedError(
                          'error getting title: {"type": ${item.basic!.commentType}, "id": $id}',
                        );
                      }
                      String? thumb = isDyn
                          ? item.modules.moduleAuthor?.face
                          : item
                                .modules
                                .moduleDynamic
                                ?.major
                                ?.opus
                                ?.pics
                                ?.firstOrNull
                                ?.url;
                      PageUtils.pmShare(
                        context,
                        content: {
                          "id": id,
                          "title": title,
                          "headline": "",
                          "source": source,
                          if (thumb?.isNotEmpty == true) "thumb": thumb,
                          "author": item.modules.moduleAuthor!.name,
                          "author_id": item.modules.moduleAuthor!.mid
                              .toString(),
                        },
                      );
                    } catch (e) {
                      SmartDialog.showToast(e.toString());
                    }
                  },
                  minLeadingWidth: 0,
                ),
              ListTile(
                title: Text(
                  '临时屏蔽：${item.modules.moduleAuthor?.name}',
                  style: theme.textTheme.titleSmall,
                ),
                leading: const Icon(Icons.visibility_off_outlined, size: 19),
                onTap: () {
                  Get.back();
                  onBlock?.call();
                  try {
                    Get.find<DynamicsController>().tempBannedList.add(
                      item.modules.moduleAuthor!.mid!,
                    );
                    SmartDialog.showToast(
                      '已临时屏蔽${item.modules.moduleAuthor?.name}(${item.modules.moduleAuthor!.mid!})，重启恢复',
                    );
                  } catch (_) {}
                },
                minLeadingWidth: 0,
              ),
              if (item.modules.moduleAuthor?.mid == Accounts.main.mid) ...[
                ListTile(
                  onTap: () {
                    Get.back();
                    RequestUtils.checkCreatedDyn(
                      id: item.idStr,
                      isManual: true,
                    );
                  },
                  minLeadingWidth: 0,
                  leading: const Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.shield_outlined, size: 19),
                      Icon(Icons.published_with_changes_sharp, size: 12),
                    ],
                  ),
                  title: Text('检查动态', style: theme.textTheme.titleSmall!),
                ),
                if (onSetTop != null)
                  ListTile(
                    onTap: () {
                      Get.back();
                      onSetTop!(
                        item.modules.moduleTag?.text != null,
                        item.idStr,
                      );
                    },
                    minLeadingWidth: 0,
                    leading: const Icon(Icons.vertical_align_top, size: 19),
                    title: Text(
                      '${item.modules.moduleTag?.text != null ? '取消' : ''}置顶',
                      style: theme.textTheme.titleSmall!,
                    ),
                  ),
                if (onRemove != null)
                  ListTile(
                    onTap: () {
                      Get.back();
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('确定删除该动态?'),
                          actions: [
                            TextButton(
                              onPressed: Get.back,
                              child: Text(
                                '取消',
                                style: TextStyle(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.back();
                                onRemove!(item.idStr);
                              },
                              child: const Text('确定'),
                            ),
                          ],
                        ),
                      );
                    },
                    minLeadingWidth: 0,
                    leading: Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.error,
                      size: 19,
                    ),
                    title: Text(
                      '删除',
                      style: theme.textTheme.titleSmall!.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
              ],
              if (Accounts.main.isLogin)
                ListTile(
                  title: Text(
                    '举报',
                    style: theme.textTheme.titleSmall!.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  leading: Icon(
                    Icons.error_outline_outlined,
                    size: 19,
                    color: theme.colorScheme.error,
                  ),
                  onTap: () {
                    Get.back();
                    autoWrapReportDialog(
                      context,
                      ReportOptions.dynamicReport,
                      (reasonType, reasonDesc, banUid) {
                        if (banUid) {
                          VideoHttp.relationMod(
                            mid: item.modules.moduleAuthor!.mid!,
                            act: 5,
                            reSrc: 11,
                          );
                        }
                        return UserHttp.dynamicReport(
                          mid: item.modules.moduleAuthor!.mid,
                          dynId: item.idStr,
                          reasonType: reasonType,
                        );
                      },
                    );
                  },
                  minLeadingWidth: 0,
                ),
              const Divider(thickness: 0.1, height: 1),
              ListTile(
                onTap: Get.back,
                minLeadingWidth: 0,
                dense: true,
                title: Text(
                  '取消',
                  style: TextStyle(color: theme.colorScheme.outline),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
