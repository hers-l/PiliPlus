import 'package:PiliPlus/common/skeleton/video_card_h.dart';
import 'package:PiliPlus/common/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/common/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/common/widgets/refresh_indicator.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models_new/sub/sub/list.dart';
import 'package:PiliPlus/models_new/sub/sub_detail/media.dart';
import 'package:PiliPlus/pages/subscription_detail/controller.dart';
import 'package:PiliPlus/pages/subscription_detail/widget/sub_video_card.dart';
import 'package:PiliPlus/utils/grid.dart';
import 'package:PiliPlus/utils/num_util.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubDetailPage extends StatefulWidget {
  const SubDetailPage({super.key});

  @override
  State<SubDetailPage> createState() => _SubDetailPageState();

  static void toSubDetailPage(
    int id, {
    String? heroTag,
    SubItemModel? subInfo,
  }) {
    Get.toNamed(
      '/subDetail',
      arguments: {
        'id': id,
        'subInfo': subInfo,
        'heroTag': heroTag,
      },
    );
  }
}

class _SubDetailPageState extends State<SubDetailPage> {
  late final SubDetailController _subDetailController = Get.put(
    SubDetailController(),
    tag: Utils.makeHeroTag(Get.parameters['id']),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = MediaQuery.paddingOf(context);
    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: refreshIndicator(
          onRefresh: _subDetailController.onRefresh,
          child: CustomScrollView(
            controller: _subDetailController.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _appBar(theme, padding),
              SliverPadding(
                padding: EdgeInsets.only(
                  top: 7,
                  bottom: padding.bottom + 80,
                ),
                sliver: Obx(
                  () => _buildBody(_subDetailController.loadingState.value),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(LoadingState<List<SubDetailItemModel>?> loadingState) {
    return switch (loadingState) {
      Loading() => SliverGrid(
        gridDelegate: Grid.videoCardHDelegate(context),
        delegate: SliverChildBuilderDelegate(
          (context, index) => const VideoCardHSkeleton(),
          childCount: 10,
        ),
      ),
      Success(:var response) =>
        response?.isNotEmpty == true
            ? SliverGrid(
                gridDelegate: Grid.videoCardHDelegate(context),
                delegate: SliverChildBuilderDelegate(
                  childCount: response!.length,
                  (context, index) {
                    if (index == response.length - 1) {
                      _subDetailController.onLoadMore();
                    }
                    return SubVideoCardH(
                      videoItem: response[index],
                    );
                  },
                ),
              )
            : HttpError(
                onReload: _subDetailController.onReload,
              ),
      Error(:var errMsg) => HttpError(
        errMsg: errMsg,
        onReload: _subDetailController.onReload,
      ),
    };
  }

  Widget _appBar(ThemeData theme, EdgeInsets padding) {
    final info = _subDetailController.subInfo;
    if (info != null) return _buildAppBar(theme, padding, info);
    return Obx(() {
      return switch (_subDetailController.loadingState.value) {
        Loading() || Error() => const SliverAppBar(),
        Success() => _buildAppBar(
          theme,
          padding,
          _subDetailController.subInfo!,
        ),
      };
    });
  }

  Widget _buildAppBar(ThemeData theme, EdgeInsets padding, SubItemModel info) {
    final style = TextStyle(
      fontSize: 12.5,
      color: theme.colorScheme.outline,
    );
    Widget cover = NetworkImgLayer(
      width: 176,
      height: 110,
      src: info.cover,
    );
    if (_subDetailController.heroTag != null) {
      cover = Hero(
        tag: _subDetailController.heroTag!,
        child: cover,
      );
    }
    return SliverAppBar.medium(
      expandedHeight: kToolbarHeight + 132,
      pinned: true,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            info.title!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium,
          ),
          Text(
            '共${info.mediaCount}条视频',
            style: theme.textTheme.labelMedium,
          ),
        ],
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.dividerColor.withValues(alpha: 0.2),
              ),
            ),
          ),
          padding: EdgeInsets.only(
            top: kToolbarHeight + padding.top + 10,
            left: 12,
            right: 12,
            bottom: 12,
          ),
          child: Row(
            spacing: 12,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              cover,
              Expanded(
                child: Column(
                  spacing: 4,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.title!,
                      style: TextStyle(
                        fontSize: theme.textTheme.titleMedium!.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(
                          '/member?mid=${info.upper!.mid}',
                        );
                      },
                      child: Text(
                        info.upper!.name!,
                        style: TextStyle(color: theme.colorScheme.primary),
                      ),
                    ),
                    const Spacer(),
                    Text('共${info.mediaCount}条视频', style: style),
                    Text(
                      '${NumUtil.numFormat(info.viewCount ?? info.cntInfo?.play)}次播放',
                      style: style,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
