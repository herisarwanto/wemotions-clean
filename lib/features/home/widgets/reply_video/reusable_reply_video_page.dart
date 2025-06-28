import 'package:flutter/material.dart';
import 'package:socialverse/export.dart';
import '../home_video/cross_indicator_widget.dart';

class ReusableReplyVideoPage extends StatelessWidget {
  final Posts post;
  final int index;
  final bool isInit;
  final ReplyProvider reply;
  final VideoProvider video;
  final HomeProvider home;
  final double? height;
  final double? width;

  const ReusableReplyVideoPage({
    Key? key,
    required this.post,
    required this.index,
    required this.isInit,
    required this.reply,
    required this.video,
    required this.home,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        reply.setTapPosition(event.position);
      },
      child: GestureDetector(
        onDoubleTap: () {
          reply.handleDoubleTap();
          if (index < reply.posts.length &&
              reply.posts[index].upvoted == false) {
            reply.posts[index].upvoted = true;
            reply.posts[index].upvoteCount++;
            reply.postLikeAdd(id: reply.posts[index].id);
          }
          Timer(Duration(seconds: 1), () => reply.isLiked = false);
          if (reply.tapPosition != reply.prevTapPosition) {
            reply.consecutiveDoubleTaps = 0;
            reply.likeAnimationScale = 1.0;
          }
          reply.prevTapPosition = reply.tapPosition;
          reply.consecutiveDoubleTaps++;
          reply.likeAnimationScale = 1.0 + (reply.consecutiveDoubleTaps * 0.2);
          reply.timer?.cancel();
          reply.timer = Timer(
            Duration(seconds: 2),
            () {
              reply.consecutiveDoubleTaps = 0;
              reply.likeAnimationScale = 1.0;
            },
          );
        },
        onTap: () {
          final controller = reply.videoController(index);
          if (controller != null) {
            if (controller.value.isPlaying) {
              reply.isPlaying = false;
              controller.pause();
            } else {
              reply.isPlaying = true;
              controller.play();
            }
          }
        },
        child: Stack(
          children: [
            Container(
              height: height ?? MediaQuery.of(context).size.height,
              width: width ?? MediaQuery.of(context).size.width,
              decoration: BoxDecoration(color: Colors.black),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomNetworkImage(
                    height: cs.height(context),
                    width: cs.width(context),
                    imageUrl: index < reply.posts.length
                        ? reply.posts[index].thumbnailUrl
                        : post.thumbnailUrl,
                    isLoading: true,
                  ),
                  if (isInit) ...[
                    Builder(
                      builder: (context) {
                        final controller = reply.videoController(index);
                        if (controller != null) {
                          return SizedBox.expand(
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: controller.value.size.width,
                                height: controller.value.size.height,
                                child: VideoPlayer(controller),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                  if (video.downloading == true)
                    DownloadBar(
                      color: Colors.grey.withOpacity(0.4),
                      label: 'Saving: ${video.progressString}',
                    ),
                  if (video.downloadingCompleted == true)
                    DownloadBar(
                      color: Theme.of(context).hintColor,
                      label: 'Video Saved',
                    ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: home.heightOfUserInfoBar,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [
                              Colors.black12.withOpacity(0.56),
                              Colors.black12.withOpacity(0.56),
                              Colors.black12.withOpacity(0.46),
                              Colors.black12.withOpacity(0.34),
                              Colors.black12.withOpacity(0.24),
                              Colors.black12.withOpacity(0.24),
                              Colors.black12.withOpacity(0.21),
                              Colors.black12.withOpacity(0.18),
                              Colors.black12.withOpacity(0.12),
                              Colors.black12.withOpacity(0.08),
                              Colors.black12.withOpacity(0.04),
                              Colors.black12.withOpacity(0.0),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  ReplyInfoSideBar(),
                  if (!reply.isPlaying)
                    Container(
                      color: Colors.black12.withOpacity(0.04),
                      height: cs.height(context),
                      width: cs.width(context),
                    ),
                  ReplyPlayButton(),
                  if (reply.isLiked) ...[
                    Positioned(
                      left: reply.tapPosition.dx - 75,
                      top: reply.tapPosition.dy - 150,
                      child: SafeArea(
                        child: Transform.scale(
                          scale: reply.likeAnimationScale,
                          child: Image.asset(
                            AppAsset.like,
                            color: Colors.white,
                            height: 150,
                          ),
                        ),
                      ),
                    )
                  ],
                  Positioned(
                    bottom: 15,
                    right: 0,
                    child: Container(
                      width: cs.width(context) / 4.8,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ReplySideBar(),
                          height2,
                          CrossIndicatorWidget(
                            currentIndex: reply.index,
                            totalCount: reply.posts.length,
                            hasChild: reply.posts.isNotEmpty &&
                                reply.index < reply.posts.length &&
                                reply.posts[reply.index].childVideoCount > 0,
                            isRoot: reply.index == 0,
                            isLast: reply.posts.isNotEmpty &&
                                reply.index == reply.posts.length - 1,
                            childCount: reply.posts.isNotEmpty &&
                                    reply.index < reply.posts.length
                                ? reply.posts[reply.index].childVideoCount
                                : 0,
                          ),
                          height15,
                        ],
                      ),
                    ),
                  ),
                  ReplyVideoProgressIndicator(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
