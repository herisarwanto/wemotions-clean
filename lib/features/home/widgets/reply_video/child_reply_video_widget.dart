import 'package:flutter/material.dart';
import 'package:socialverse/export.dart';
import 'reusable_reply_video_page.dart';

class ChildReplyVideoWidget extends StatelessWidget {
  final List<Posts> childPosts;
  final PageController pageController;
  final ReplyProvider reply;
  final VideoProvider video;
  final HomeProvider home;

  const ChildReplyVideoWidget({
    Key? key,
    required this.childPosts,
    required this.pageController,
    required this.reply,
    required this.video,
    required this.home,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      controller: pageController,
      itemCount: childPosts.length,
      itemBuilder: (context, index) {
        bool isInit =
            reply.videoController(index)?.value.isInitialized ?? false;
        return ReusableReplyVideoPage(
          post: childPosts[index],
          index: index,
          isInit: isInit,
          reply: reply,
          video: video,
          home: home,
        );
      },
    );
  }
}
