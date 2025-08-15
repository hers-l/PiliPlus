import 'package:PiliPlus/common/skeleton/msg_feed_top.dart';
import 'package:PiliPlus/common/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/common/widgets/refresh_indicator.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/follow_order_type.dart';
import 'package:PiliPlus/models_new/follow/list.dart';
import 'package:PiliPlus/pages/follow/child/child_controller.dart';
import 'package:PiliPlus/pages/follow/controller.dart';
import 'package:PiliPlus/pages/follow/widgets/follow_item.dart';
import 'package:PiliPlus/pages/share/view.dart' show UserModel;
import 'package:PiliPlus/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FollowChildPage extends StatefulWidget {
  const FollowChildPage({
    super.key,
    this.tag,
    this.controller,
    required this.mid,
    this.tagid,
    this.onSelect,
  });

  final String? tag;
  final FollowController? controller;
  final int mid;
  final int? tagid;
  final ValueChanged<UserModel>? onSelect;

  @override
  State<FollowChildPage> createState() => _FollowChildPageState();
}

class _FollowChildPageState extends State<FollowChildPage>
    with AutomaticKeepAliveClientMixin {
  late final _followController = Get.put(
    FollowChildController(widget.controller, widget.mid, widget.tagid),
    tag: '${widget.tag ?? Utils.generateRandomString(8)}${widget.tagid}',
  );

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final padding = MediaQuery.paddingOf(context);
    Widget child = refreshIndicator(
      onRefresh: _followController.onRefresh,
      child: CustomScrollView(
        controller: _followController.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(bottom: padding.bottom + 80),
            sliver: Obx(
              () => _buildBody(_followController.loadingState.value),
            ),
          ),
        ],
      ),
    );
    if (widget.onSelect != null ||
        (widget.controller?.isOwner == true && widget.tagid == null)) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          child,
          Positioned(
            right: 16 + padding.right,
            bottom: 16 + padding.bottom,
            child: FloatingActionButton.extended(
              onPressed: () => _followController
                ..orderType.value =
                    _followController.orderType.value == FollowOrderType.def
                    ? FollowOrderType.attention
                    : FollowOrderType.def
                ..onReload(),
              icon: const Icon(Icons.format_list_bulleted, size: 20),
              label: Obx(() => Text(_followController.orderType.value.title)),
            ),
          ),
        ],
      );
    }
    return child;
  }

  Widget _buildBody(LoadingState<List<FollowItemModel>?> loadingState) {
    return switch (loadingState) {
      Loading() => SliverList.builder(
        itemCount: 12,
        itemBuilder: (context, index) {
          return const MsgFeedTopSkeleton();
        },
      ),
      Success(:var response) =>
        response?.isNotEmpty == true
            ? SliverList.builder(
                itemCount: response!.length,
                itemBuilder: (context, index) {
                  if (index == response.length - 1) {
                    _followController.onLoadMore();
                  }
                  final item = response[index];
                  return FollowItem(
                    item: item,
                    isOwner: widget.controller?.isOwner,
                    onSelect: widget.onSelect,
                    callback: (attr) {
                      item.attribute = attr == 0 ? -1 : 0;
                      _followController.loadingState.refresh();
                    },
                  );
                },
              )
            : HttpError(onReload: _followController.onReload),
      Error(:var errMsg) => HttpError(
        errMsg: errMsg,
        onReload: _followController.onReload,
      ),
    };
  }

  @override
  bool get wantKeepAlive =>
      widget.onSelect != null || widget.controller?.tabController != null;
}
