import 'package:PiliPlus/common/skeleton/video_card_h.dart';
import 'package:PiliPlus/common/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/common/widgets/refresh_indicator.dart';
import 'package:PiliPlus/grpc/bilibili/main/community/reply/v1.pb.dart'
    show SearchItem;
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/reply/reply_search_type.dart';
import 'package:PiliPlus/pages/video/reply_search_item/child/controller.dart';
import 'package:PiliPlus/pages/video/reply_search_item/child/widgets/item.dart';
import 'package:PiliPlus/utils/grid.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReplySearchChildPage extends StatefulWidget {
  const ReplySearchChildPage({
    super.key,
    required this.controller,
    required this.searchType,
  });

  final ReplySearchChildController controller;
  final ReplySearchType searchType;

  @override
  State<ReplySearchChildPage> createState() => _ReplySearchChildPageState();
}

class _ReplySearchChildPageState extends State<ReplySearchChildPage>
    with AutomaticKeepAliveClientMixin {
  ReplySearchChildController get _controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return refreshIndicator(
      onRefresh: _controller.onRefresh,
      child: CustomScrollView(
        controller: _controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(
              top: 7,
              bottom: MediaQuery.paddingOf(context).bottom + 80,
            ),
            sliver: Obx(() => _buildBody(_controller.loadingState.value)),
          ),
        ],
      ),
    );
  }

  Widget get _buildLoading {
    return SliverGrid(
      gridDelegate: Grid.videoCardHDelegate(context),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return const VideoCardHSkeleton();
        },
        childCount: 10,
      ),
    );
  }

  Widget _buildBody(LoadingState<List<SearchItem>?> loadingState) {
    return switch (loadingState) {
      Loading() => _buildLoading,
      Success(:var response) =>
        response?.isNotEmpty == true
            ? SliverGrid(
                gridDelegate: Grid.videoCardHDelegate(context),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == response.length - 1) {
                      _controller.onLoadMore();
                    }
                    return ReplySearchItem(
                      item: response[index],
                      type: widget.searchType,
                    );
                  },
                  childCount: response!.length,
                ),
              )
            : HttpError(onReload: _controller.onReload),
      Error(:var errMsg) => HttpError(
        errMsg: errMsg,
        onReload: _controller.onReload,
      ),
    };
  }

  @override
  bool get wantKeepAlive => true;
}
