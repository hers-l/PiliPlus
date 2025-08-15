import 'package:PiliPlus/common/constants.dart';
import 'package:PiliPlus/common/skeleton/video_card_v.dart';
import 'package:PiliPlus/common/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/common/widgets/refresh_indicator.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models_new/live/live_follow/item.dart';
import 'package:PiliPlus/pages/live_follow/controller.dart';
import 'package:PiliPlus/pages/live_follow/widgets/live_item_follow.dart';
import 'package:PiliPlus/utils/grid.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LiveFollowPage extends StatefulWidget {
  const LiveFollowPage({super.key});

  @override
  State<LiveFollowPage> createState() => _LiveFollowPageState();
}

class _LiveFollowPageState extends State<LiveFollowPage> {
  final _controller = Get.put(LiveFollowController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () {
            final count = _controller.count.value;
            return Text(count != null ? '$count人正在直播' : '关注直播');
          },
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: refreshIndicator(
          onRefresh: _controller.onRefresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.only(
                  left: StyleString.safeSpace,
                  right: StyleString.safeSpace,
                  bottom: MediaQuery.paddingOf(context).bottom + 80,
                ),
                sliver: Obx(() => _buildBody(_controller.loadingState.value)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(LoadingState<List<LiveFollowItem>?> loadingState) {
    return switch (loadingState) {
      Loading() => SliverGrid(
        gridDelegate: SliverGridDelegateWithExtentAndRatio(
          mainAxisSpacing: StyleString.cardSpace,
          crossAxisSpacing: StyleString.cardSpace,
          maxCrossAxisExtent: Grid.smallCardWidth,
          childAspectRatio: StyleString.aspectRatio,
          mainAxisExtent: MediaQuery.textScalerOf(context).scale(90),
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return const VideoCardVSkeleton();
          },
          childCount: 10,
        ),
      ),
      Success(:var response) =>
        response?.isNotEmpty == true
            ? SliverGrid(
                gridDelegate: SliverGridDelegateWithExtentAndRatio(
                  mainAxisSpacing: StyleString.cardSpace,
                  crossAxisSpacing: StyleString.cardSpace,
                  maxCrossAxisExtent: Grid.smallCardWidth,
                  childAspectRatio: StyleString.aspectRatio,
                  mainAxisExtent: MediaQuery.textScalerOf(context).scale(90),
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == response.length - 1) {
                      _controller.onLoadMore();
                    }
                    return LiveCardVFollow(
                      liveItem: response[index],
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
}
