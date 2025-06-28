import 'dart:developer';

import 'package:socialverse/export.dart';
import 'package:socialverse/features/home/helper/smooth_page_indicator.dart';
import 'package:socialverse/features/home/widgets/main_video/home_bottom_bar.dart';
import 'package:socialverse/features/home/widgets/main_video/home_side_bar.dart';

import 'home_video_progress_indicator.dart';
import 'last_page_gradient.dart';

class HomeVideoWidget extends StatefulWidget {
  final List<List<Posts>> posts;
  final PageController pageController;
  final int pageIndex;
  final bool isFromFeed;

  const HomeVideoWidget({
    Key? key,
    required this.posts,
    required this.pageController,
    required this.pageIndex,
    required this.isFromFeed,
  }) : super(key: key);

  @override
  State<HomeVideoWidget> createState() => _HomeVideoWidgetState();
}

class _HomeVideoWidgetState extends State<HomeVideoWidget> {
  int _previousPage = 0;
  bool _isLastPage = false;

  late final HomeProvider _home;
  late final ReplyProvider _reply;
  late final SmoothPageIndicatorProvider _page;
  late final VideoProvider _video;
  late final NestedRProvider nestedR;

  @override
  void initState() {
    super.initState();
    _reply = Provider.of<ReplyProvider>(context, listen: false);
    _home = Provider.of<HomeProvider>(context, listen: false);
    _video = Provider.of<VideoProvider>(context, listen: false);
    nestedR = Provider.of<NestedRProvider>(context, listen: false);

    initializeVideo();

    _initializeReplies();

    widget.pageController.addListener(_pageListener);
  }

  Future<void> _initializeReplies() async {
    // Load initial replies in background
    unawaited(_loadInitialReplies());
  }

  Future<void> _loadInitialReplies() async {
    await _home.createReplyIsolate(0, token: token);
    if (_home.posts[0].length > 1) {
      _reply.posts = _home.posts[0].sublist(1);
    }

    // Pre fetch next page replies
    if (_home.posts.length > 1) {
      unawaited(_home.createReplyIsolate(1, token: token));
    }
  }

  void _initializePageIndicator() {
    _page.onReply = _reply.onReply;
    _page.totalVerticalPages = _home.posts.length;
    _page.currentVerticalIndex = _home.index;
    _page.totalHorizontalPages = _reply.posts.length;
    _page.currentHorizontalIndex = _reply.index;
  }

  Future<void> initializeVideo() async {
    await _home.initializedVideoPlayer();
    _reply.posts = _home.posts[0].sublist(1);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _home.index = widget.pageIndex;
      _initializePageIndicator();
    });
  }

  Future<void> _handleRepliesInBackground(int idx) async {
    // Load current post replies if available
    if (_home.posts[idx].length > 1) {
      _reply.posts = _home.posts[idx].sublist(1);
    }

    // Pre-fetch next/previous replies based on scroll direction
    if (_home.vertical_drag_direction == 1) {
      if (idx + 1 <= _home.posts.length - 1) {
        unawaited(_home.createReplyIsolate(idx + 1, token: token));
      }
    } else {
      if (idx - 1 >= 0) {
        unawaited(_home.createReplyIsolate(idx - 1, token: token));
      }
    }
  }

  void _pageListener() {
    if (!mounted) return;

    final currentPage = widget.pageController.page?.round() ?? 0;
    final lastPage = widget.posts.length - 1;

    if (currentPage == lastPage && _previousPage != lastPage) {
      setState(() => _isLastPage = true);
    } else if (currentPage != lastPage && _isLastPage) {
      setState(() => _isLastPage = false);
    }

    _previousPage = currentPage;

    final totalPosts = _home.posts.length;

    if (currentPage >= totalPosts - 5 && _home.hasMorePosts) {
      unawaited(_home.createIsolate(token: token));
    }
  }

  @override
  void dispose() {
    widget.pageController.removeListener(_pageListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedContainer(
          duration: Duration(milliseconds: 100),
          child: PageView.builder(
            itemCount: widget.posts.length + (_home.hasMorePosts ? 1 : 0),
            controller: widget.pageController,
            scrollDirection: Axis.vertical,
            physics: const ClampingScrollPhysics(),
            onPageChanged: (idx) async {
              // Add bounds checking
              if (idx >= _home.posts.length) {
                return;
              }

              // Simple page change without complex logic
              _home.onPageChanged(idx);

              // Reset horizontal index
              _home.horizontalIndex = 0;

              // Stop all videos
              await _home.stopAllVideos();
            },
            itemBuilder: (context, index) {
              if (index < widget.posts.length) {
                return _buildVideoPage(index);
              } else {
                // Show loading indicator at the end
                return _buildLoadingIndicator();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPage(int index) {
    // Add bounds checking
    if (index >= _home.posts.length || _home.posts[index].isEmpty) {
      return const SizedBox.shrink();
    }

    log("${_home.posts[index][0].id}");
    bool isInit = _home.videoController(index)?.value.isInitialized ?? false;

    return PageView(
      scrollDirection: Axis.horizontal,
      controller: _home.replies,
      physics:
          const ClampingScrollPhysics(), // Use ClampingScrollPhysics to prevent scroll stuck
      onPageChanged: (idx) => _handleHorizontalPageChange(idx, index),
      children: [
        _buildMainVideoContent(index, isInit),
        if (_home.posts[index].length > 1 &&
            _reply.posts.length == _home.posts[index].length - 1)
          _buildReplyContent(index, isInit),
      ],
    );
  }

  Widget _buildMainVideoContent(int index, bool isInit) {
    return GestureDetector(
      onTap: () => _handleVideoTap(index),
      child: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(color: Colors.black),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // if (!_isLastPage) ...[

                _buildThumbnail(index),

                if (isInit) _buildVideoPlayer(index),

                // if (home.video_trend_bar) _buildTrendingBar(),

                if (_video.downloading == true)
                  DownloadBar(
                    color: Colors.grey.withOpacity(0.4),
                    label: 'Saving: ${_video.progressString}',
                  ),
                if (_video.downloadingCompleted == true)
                  DownloadBar(
                    color: Theme.of(context).hintColor,
                    label: 'Video Saved',
                  ),

                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: _home.heightOfUserInfoBar,
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

                HomeUserInfoBar(),

                if (!_home.isPlaying)
                  Container(
                    color: Colors.black12.withOpacity(0.04),
                    height: cs.height(context),
                    width: cs.width(context),
                  ),
                PlayButton(),

                _buildSideBar(),

                HomeVideoProgressIndicator(),

                // ],
                // if (_isLastPage) _buildLastPage(index, isInit),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(
    int index,
  ) {
    // Add bounds checking
    if (index >= _home.posts.length || _home.posts[index].isEmpty) {
      return const SizedBox.shrink();
    }

    return CustomNetworkImage(
      height: cs.availableHeightWithNav(context),
      width: cs.width(context),
      imageUrl: _home.posts[index][0].thumbnailUrl,
      isLoading: true,
    );
  }

  Widget _buildVideoPlayer(int index) {
    final controller = _home.videoController(index);
    if (controller == null) {
      return const SizedBox.shrink();
    }

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

  Widget _buildTrendingBar() {
    return Positioned(
      top: -30,
      left: -10,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 78),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Constants.primaryColor, width: 2),
                ),
              ),
              child: Text(
                "Trending",
                style: AppTextStyle.normalBold.copyWith(
                  color: Constants.primaryColor,
                ),
              ),
            ),
            width20,
            // Text(
            //   "Following",
            //   style: AppTextStyle.normalBold.copyWith(color: Colors.white),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideBar() {
    return Positioned(
      bottom: 15,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Container(
          width: cs.width(context) / 4.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HomeSideBar(),
              height2,
              Consumer2<HomeProvider, ReplyProvider>(
                builder: (context, home, reply, _) {
                  // if (reply.index == 0 || reply.posts.isEmpty) {
                  return SmoothPageIndicatorView();
                  // } else {
                  //   final isOnHome = (home.index == 0 &&
                  //       (reply.index <= 0 || reply.posts.isEmpty));
                  //   final isOnParent = (reply.index == 0 &&
                  //       home.index > 0 &&
                  //       reply.posts.isNotEmpty);
                  //   final isOnReply =
                  //       (reply.index > 0 && reply.posts.isNotEmpty);
                  //   final replyCount = reply.posts.length;
                  //   final feedCount = home.posts.length - home.index - 1;
                  //   return CrossIndicatorWidget(
                  //     currentIndex: reply.index,
                  //     totalCount: reply.posts.length,
                  //     hasChild: reply.posts.isNotEmpty &&
                  //         reply.posts[reply.index].childVideoCount > 0,
                  //     isRoot: reply.index == 0,
                  //     isLast: reply.index == reply.posts.length - 1,
                  //     childCount: reply.posts.isNotEmpty
                  //         ? reply.posts[reply.index].childVideoCount
                  //         : 0,
                  //   );
                  // }
                },
              ),
              height15,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLastPage(int index, bool isInit) {
    // Add bounds checking
    if (index >= _home.posts.length || _home.posts[index].isEmpty) {
      return const SizedBox.shrink();
    }

    final controller = _home.videoController(index);
    if (controller == null) {
      return const SizedBox.shrink();
    }

    return LastPageGradient(
      isInit: isInit,
      child: SizedBox(
        width: controller.value.size.width,
        height: controller.value.size.height,
        child: VideoPlayer(controller),
      ),
      childImage: _home.posts[_home.index][0].thumbnailUrl,
    );
  }

  Widget _buildReplyContent(int index, bool isInit) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // Only handle scroll when it's a meaningful scroll
        if (notification is ScrollUpdateNotification) {
          // Don't interfere with normal scrolling
          return false;
        }
        return _handleReplyScroll(notification);
      },
      child: ReplyVideoWidget(
        video: _home.posts[index][0],
        pageController: _reply.home,
        postIndex: 0,
        parentIndex: index,
        isInit: isInit,
        onExitReply: () {
          // Handle navigation back to parent feed
          if (_reply.index == 0) {
            // Animate back to parent video
            _home.replies.animateToPage(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastEaseInToSlowEaseOut,
            );
          }
        },
      ),
    );
  }

  bool _hasMoreRepliesForPost(int postIndex) {
    // Check if there are more replies available for this post
    // This could be based on API response or a flag in your data model
    return _home.posts[postIndex].length > 1 &&
        _home.posts[postIndex].length < 10; // Assuming max 10 replies per page
  }

  void _handleReplyPagination(int postIndex, int replyIndex) async {
    // If user scrolls to the end of replies and more are available, fetch them
    if (replyIndex >= _home.posts[postIndex].length - 2 &&
        _hasMoreRepliesForPost(postIndex) &&
        !_home.fetchingReplies) {
      // Fetch more replies for this post
      await _home.createReplyIsolate(postIndex, token: token);
    }
  }

  void _handleVideoTap(int index) {
    final controller = _home.videoController(index);
    if (controller == null) return;

    if (controller.value.isPlaying) {
      _home.isPlaying = false;
      controller.pause();
    } else {
      _home.isPlaying = true;
      controller.play();
    }
  }

  void _handleHorizontalPageChange(int idx, int index) async {
    try {
      _reply.horizontal_drag_direction = _reply.index < idx ? 1 : -1;

      // Handle reply pagination when scrolling to the end
      if (idx >= _reply.posts.length - 2 &&
          _hasMoreRepliesForPost(index) &&
          !_home.fetchingReplies) {
        // Fetch more replies for this post
        await _home.createReplyIsolate(index, token: token);
      }

      if (idx == 1) {
        _home.horizontalIndex = 1;

        // Stop main video
        try {
          await _home.videoController(_home.index)?.pause();
          await _home.videoController(_home.index)?.seekTo(Duration.zero);
        } catch (e) {
          print("Error stopping main video: $e");
        }

        _reply.onReply = true;
        _reply.isPlaying = true;

        // Play reply video
        try {
          _reply.videoController(_reply.index)?.setLooping(true);
          _reply.videoController(_reply.index)?.play();
        } catch (e) {
          print("Error playing reply video: $e");
        }
      } else if (idx == 0) {
        _home.horizontalIndex = 0;

        // Stop reply video
        try {
          _reply.videoController(_reply.index)?.pause();
          _reply.videoController(_reply.index)?.seekTo(Duration.zero);
        } catch (e) {
          print("Error stopping reply video: $e");
        }

        _reply.onReply = false;
        _reply.horizontal_drag_direction = 0;
        _reply.isPlaying = false;

        // Play main video
        try {
          final homeController = _home.videoController(_home.index);
          if (homeController != null) {
            homeController.play();
          }
        } catch (e) {
          print("Error playing main video: $e");
        }
      }

      // Use addPostFrameCallback to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializePageIndicator();
      });
    } catch (e) {
      print("Error in horizontal page change: $e");
    }
  }

  bool _handleReplyScroll(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      if (_reply.index == 0 &&
          notification.metrics.pixels < notification.metrics.minScrollExtent) {
        _home.replies.animateToPage(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.fastEaseInToSlowEaseOut,
        );
      }
    }
    return false;
  }

  Widget _buildLoadingIndicator() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Constants.primaryColor),
            ),
            height20,
            Text(
              'Loading more videos...',
              style: AppTextStyle.normalRegular16.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 64,
              color: Colors.white.withOpacity(0.5),
            ),
            height20,
            Text(
              'No videos available',
              style: AppTextStyle.normalBold.copyWith(
                color: Colors.white,
              ),
            ),
            height10,
            Text(
              'Pull to refresh',
              style: AppTextStyle.normalRegular16.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
