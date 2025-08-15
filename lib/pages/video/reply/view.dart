import 'package:PiliPlus/common/skeleton/video_reply.dart';
import 'package:PiliPlus/common/widgets/custom_sliver_persistent_header_delegate.dart';
import 'package:PiliPlus/common/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/common/widgets/refresh_indicator.dart';
import 'package:PiliPlus/grpc/bilibili/main/community/reply/v1.pb.dart'
    show ReplyInfo;
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/pages/video/reply/controller.dart';
import 'package:PiliPlus/pages/video/reply/widgets/reply_item_grpc.dart';
import 'package:PiliPlus/utils/feed_back.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

class VideoReplyPanel extends StatefulWidget {
  const VideoReplyPanel({
    super.key,
    this.replyLevel = 1,
    required this.heroTag,
    required this.replyReply,
    this.onViewImage,
    this.onDismissed,
    this.callback,
    this.needController,
  });

  final int replyLevel;
  final String heroTag;
  final Function(ReplyInfo replyItem, int? rpid) replyReply;
  final VoidCallback? onViewImage;
  final ValueChanged<int>? onDismissed;
  final Function(List<String>, int)? callback;
  final bool? needController;

  @override
  State<VideoReplyPanel> createState() => _VideoReplyPanelState();
}

class _VideoReplyPanelState extends State<VideoReplyPanel>
    with AutomaticKeepAliveClientMixin {
  late VideoReplyController _videoReplyController;

  String get heroTag => widget.heroTag;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _videoReplyController = Get.find<VideoReplyController>(tag: heroTag);
    if (_videoReplyController.loadingState.value is Loading) {
      _videoReplyController.queryData();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _videoReplyController.showFab();
    if (widget.needController != false) {
      _videoReplyController.scrollController.addListener(listener);
    } else {
      _videoReplyController.scrollController.removeListener(listener);
    }
  }

  @override
  void dispose() {
    if (widget.needController != false) {
      _videoReplyController.scrollController.removeListener(listener);
    }
    super.dispose();
  }

  void listener() {
    final ScrollDirection direction =
        _videoReplyController.scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.forward) {
      if (mounted) {
        _videoReplyController.showFab();
      }
    } else if (direction == ScrollDirection.reverse) {
      if (mounted) {
        _videoReplyController.hideFab();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;
    return refreshIndicator(
      onRefresh: _videoReplyController.onRefresh,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomScrollView(
            controller: widget.needController == false
                ? null
                : _videoReplyController.scrollController,
            physics: widget.needController == false
                ? const AlwaysScrollableScrollPhysics(
                    parent: ClampingScrollPhysics(),
                  )
                : const AlwaysScrollableScrollPhysics(),
            key: const PageStorageKey<String>('评论'),
            slivers: <Widget>[
              SliverPersistentHeader(
                pinned: false,
                floating: true,
                delegate: CustomSliverPersistentHeaderDelegate(
                  extent: 40,
                  bgColor: theme.colorScheme.surface,
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.fromLTRB(12, 0, 6, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(
                          () => Text(
                            _videoReplyController.sortType.value.title,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        SizedBox(
                          height: 35,
                          child: TextButton.icon(
                            onPressed: _videoReplyController.queryBySort,
                            icon: Icon(
                              Icons.sort,
                              size: 16,
                              color: theme.colorScheme.secondary,
                            ),
                            label: Obx(
                              () => Text(
                                _videoReplyController.sortType.value.label,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Obx(
                () => _buildBody(
                  theme,
                  bottom,
                  _videoReplyController.loadingState.value,
                ),
              ),
            ],
          ),
          Positioned(
            bottom: bottom + 14,
            right: 14,
            child: SlideTransition(
              position: _videoReplyController.anim,
              child: FloatingActionButton(
                heroTag: null,
                onPressed: () {
                  feedBack();
                  _videoReplyController.onReply(
                    context,
                    oid: _videoReplyController.aid,
                    replyType: _videoReplyController.videoType.replyType,
                  );
                },
                tooltip: '发表评论',
                child: const Icon(Icons.reply),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme, double bottom, LoadingState loadingState) {
    return switch (loadingState) {
      Loading() => SliverList.builder(
        itemBuilder: (BuildContext context, index) {
          return const VideoReplySkeleton();
        },
        itemCount: 5,
      ),
      Success(:var response) =>
        response?.isNotEmpty == true
            ? SliverList.builder(
                itemBuilder: (context, index) {
                  if (index == response.length) {
                    _videoReplyController.onLoadMore();
                    return Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(bottom: bottom),
                      height: bottom + 100,
                      child: Text(
                        _videoReplyController.isEnd ? '没有更多了' : '加载中...',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    );
                  } else {
                    return ReplyItemGrpc(
                      replyItem: response[index],
                      replyLevel: widget.replyLevel,
                      replyReply: widget.replyReply,
                      onReply: (replyItem) => _videoReplyController.onReply(
                        context,
                        replyItem: replyItem,
                      ),
                      onDelete: (item, subIndex) =>
                          _videoReplyController.onRemove(index, item, subIndex),
                      upMid: _videoReplyController.upMid,
                      getTag: () => heroTag,
                      onViewImage: widget.onViewImage,
                      onDismissed: widget.onDismissed,
                      callback: widget.callback,
                      onCheckReply: (item) => _videoReplyController
                          .onCheckReply(item, isManual: true),
                      onToggleTop: (item) => _videoReplyController.onToggleTop(
                        item,
                        index,
                        _videoReplyController.aid,
                        _videoReplyController.videoType.replyType,
                      ),
                    );
                  }
                },
                itemCount: response.length + 1,
              )
            : HttpError(
                errMsg: '还没有评论',
                onReload: _videoReplyController.onReload,
              ),
      Error(:var errMsg) => HttpError(
        errMsg: errMsg,
        onReload: _videoReplyController.onReload,
      ),
    };
  }
}
