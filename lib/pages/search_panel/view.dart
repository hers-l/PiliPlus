import 'package:PiliPlus/common/constants.dart';
import 'package:PiliPlus/common/skeleton/media_bangumi.dart';
import 'package:PiliPlus/common/skeleton/msg_feed_top.dart';
import 'package:PiliPlus/common/skeleton/video_card_h.dart';
import 'package:PiliPlus/common/skeleton/video_card_v.dart';
import 'package:PiliPlus/common/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/common/widgets/refresh_indicator.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/search/search_type.dart';
import 'package:PiliPlus/models/search/result.dart';
import 'package:PiliPlus/pages/search_panel/controller.dart';
import 'package:PiliPlus/utils/grid.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class CommonSearchPanel extends StatefulWidget {
  const CommonSearchPanel({
    super.key,
    required this.keyword,
    required this.searchType,
    required this.tag,
  });

  final String keyword;
  final SearchType searchType;
  final String tag;
}

abstract class CommonSearchPanelState<
  S extends CommonSearchPanel,
  R extends SearchNumData<T>,
  T
>
    extends State<S>
    with AutomaticKeepAliveClientMixin {
  SearchPanelController<R, T> get controller;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    return refreshIndicator(
      onRefresh: controller.onRefresh,
      child: CustomScrollView(
        controller: controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (widget.searchType.hasHeader) buildHeader(theme),
          Obx(() => _buildBody(theme, controller.loadingState.value)),
        ],
      ),
    );
  }

  Widget get _builLoading {
    return SliverGrid(
      gridDelegate: switch (widget.searchType) {
        SearchType.media_bangumi ||
        SearchType.media_ft => SliverGridDelegateWithExtentAndRatio(
          mainAxisSpacing: 2,
          maxCrossAxisExtent: Grid.smallCardWidth * 2,
          childAspectRatio: StyleString.aspectRatio * 1.5,
          minHeight: MediaQuery.textScalerOf(context).scale(155),
        ),
        SearchType.live_room => SliverGridDelegateWithExtentAndRatio(
          mainAxisSpacing: StyleString.cardSpace,
          crossAxisSpacing: StyleString.cardSpace,
          maxCrossAxisExtent: Grid.smallCardWidth,
          childAspectRatio: StyleString.aspectRatio,
          mainAxisExtent: MediaQuery.textScalerOf(context).scale(90),
        ),
        SearchType.bili_user => SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: Grid.smallCardWidth * 2,
          mainAxisExtent: 66,
        ),
        _ => Grid.videoCardHDelegate(context),
      },
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          switch (widget.searchType) {
            case SearchType.media_bangumi || SearchType.media_ft:
              return const MediaPgcSkeleton();
            case SearchType.bili_user:
              return const MsgFeedTopSkeleton();
            case SearchType.live_room:
              return const VideoCardVSkeleton();
            default:
              return const VideoCardHSkeleton();
          }
        },
        childCount: 16,
      ),
    );
  }

  Widget _buildBody(ThemeData theme, LoadingState<List<T>?> loadingState) {
    return switch (loadingState) {
      Loading() =>
        widget.searchType == SearchType.live_room
            ? SliverPadding(
                padding: const EdgeInsets.only(
                  left: StyleString.cardSpace,
                  right: StyleString.cardSpace,
                ),
                sliver: _builLoading,
              )
            : _builLoading,
      Success(:var response) =>
        response?.isNotEmpty == true
            ? SliverPadding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.paddingOf(context).bottom + 80,
                ),
                sliver: buildList(theme, response!),
              )
            : HttpError(
                onReload: controller.onReload,
              ),
      Error(:var errMsg) => HttpError(
        errMsg: errMsg,
        onReload: controller.onReload,
      ),
    };
  }

  Widget buildHeader(ThemeData theme) => throw UnimplementedError();

  Widget buildList(ThemeData theme, List<T> list);
}
