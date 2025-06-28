import 'package:socialverse/export.dart';
import '../home_video/cross_indicator_widget.dart';
import 'reusable_reply_video_page.dart';
import 'child_reply_video_widget.dart';

class ReplyVideoWidget extends StatefulWidget {
  final Posts video;
  final PageController pageController;
  final int postIndex;
  final int parentIndex;
  final bool isInit;
  final Function()? onExitReply;

  const ReplyVideoWidget({
    super.key,
    required this.video,
    required this.pageController,
    required this.postIndex,
    required this.parentIndex,
    required this.isInit,
    this.onExitReply,
  });

  @override
  State<ReplyVideoWidget> createState() => _ReplyVideoWidgetState();
}

class _ReplyVideoWidgetState extends State<ReplyVideoWidget> {
  late ReplyProvider _reply;
  late HomeProvider _home;
  late NestedRProvider _nestedR;
  late SmoothPageIndicatorProvider _page;

  // Track if we are showing child videos (level 2)
  bool _showChildPageView = false;
  // Controller for vertical PageView (main reply + child videos)
  final PageController _verticalController = PageController();
  final PageController _horizontalController = PageController();

  // Add state to track if we are in child level 2 mode
  bool isInChildLevel2 = false;
  final PageController _childVerticalController = PageController();

  // Tambah state untuk child level 2 per horizontal index
  int? _activeChildLevel2PostId;

  @override
  void initState() {
    super.initState();
    _reply = Provider.of<ReplyProvider>(context, listen: false);
    _home = Provider.of<HomeProvider>(context, listen: false);
    _nestedR = Provider.of<NestedRProvider>(context, listen: false);
    _page = Provider.of<SmoothPageIndicatorProvider>(context, listen: false);

    // Disable parent (home) vertical scroll hanya sekali saat masuk halaman reply
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_home.home.hasClients) {
        _home.home.position.isScrollingNotifier.value = false;
        _home.home.position.activity?.dispose();
      }
    });

    initializeVideo();
  }

  initializeVideo() async {
    await _reply.initializedVideoPlayer();
    // _reply.index = widget.postIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePageIndicator();
    });
  }

  void _initializePageIndicator() {
    _page.totalVerticalPages = _home.posts.length;
    _page.currentVerticalIndex = _home.index;
    _page.totalHorizontalPages = _reply.posts.length;
    _page.currentHorizontalIndex = _reply.index;
  }

  // Handle vertical drag to trigger loading child videos
  void _handleVerticalDragEnd(DragEndDetails details, int index) async {
    // Only trigger on downward swipe
    if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
      final currentReply = _reply.posts[index];
      if (currentReply.childVideoCount > 0) {
        // Fetch child videos for this reply
        await _nestedR.navigateToNestedReplies(currentReply.id, true);
        setState(() {
          _showChildPageView = true;
        });
      }
    } else if (details.primaryVelocity != null &&
        details.primaryVelocity! > 0) {
      // Swipe up: go back to main reply
      setState(() {
        _showChildPageView = false;
      });
    }
  }

  void _enterChildLevel2(NestedRProvider nestedR, int postId) async {
    await nestedR.navigateToNestedReplies(postId, true);
    setState(() {
      isInChildLevel2 = true;
    });
  }

  void _exitChildLevel2() {
    setState(() {
      isInChildLevel2 = false;
    });
  }

  void _showChildLevel2(int postId) {
    setState(() {
      _activeChildLevel2PostId = postId;
    });
  }

  void _hideChildLevel2() {
    setState(() {
      _activeChildLevel2PostId = null;
    });
  }

  @override
  void dispose() {
    // _reply.dispose();
    try {
      _verticalController.dispose();
    } catch (e) {
      print("VerticalController already disposed: $e");
    }
    try {
      _horizontalController.dispose();
    } catch (e) {
      print("HorizontalController already disposed: $e");
    }
    try {
      _childVerticalController.dispose();
    } catch (e) {
      print("ChildVerticalController already disposed: $e");
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer5<ReplyProvider, HomeProvider, VideoProvider,
        SmoothPageIndicatorProvider, NestedRProvider>(
      builder: (_, reply, home, video, page, nestedR, ___) {
        // Safety check for empty posts
        if (reply.posts.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Ambil data child level 2 dari NestedRProvider
        final List<List<Posts>> verticalChildPosts =
            nestedR.vPosts.isNotEmpty ? nestedR.vPosts : [reply.posts];
        return Stack(
          children: [
            PageView.builder(
              scrollDirection: Axis.vertical,
              controller: _verticalController,
              itemCount: verticalChildPosts.length,
              physics: _activeChildLevel2PostId != null
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              onPageChanged: (vIndex) {
                // Optionally: handle vertical page change logic here
              },
              itemBuilder: (context, vIndex) {
                final List<Posts> horizontalReplies =
                    verticalChildPosts[vIndex];
                return GestureDetector(
                  onHorizontalDragEnd: (details) {
                    // Only handle right swipe when at index 0
                    if (reply.index == 0 &&
                        details.primaryVelocity != null &&
                        details.primaryVelocity! > 0) {
                      // User swiped right from index 0, go back to parent
                      if (widget.onExitReply != null) {
                        widget.onExitReply!();
                      }
                    }
                  },
                  child: PageView.builder(
                    scrollDirection: Axis.horizontal,
                    controller: _horizontalController,
                    itemCount: horizontalReplies.length,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (hIndex) {
                      reply.index = hIndex; // Update reply index
                      if (hIndex == 0) {
                        // Reset state jika perlu, misal:
                        if (_reply.onReply != false) {
                          _reply.onReply = false;
                          _reply.isPlaying = false;
                          _reply.videoController(_reply.index)?.pause();
                          _reply
                              .videoController(_reply.index)
                              ?.seekTo(Duration.zero);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() {});
                          });
                        }
                      } else {
                        // Jika ke kanan (masuk reply), update state
                        _reply.onReply = true;
                        _reply.isPlaying = true;
                        _reply.index = hIndex;
                        _reply.videoController(hIndex)?.setLooping(true);
                        _reply.videoController(hIndex)?.play();
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          setState(() {});
                        });
                      }
                    },
                    itemBuilder: (context, hIndex) {
                      final Posts post = horizontalReplies[hIndex];

                      // Ensure reply.index is always valid
                      // if (hIndex != reply.index) {
                      //   reply.index = hIndex;
                      // }

                      final bool isInit =
                          reply.videoController(hIndex)?.value.isInitialized ??
                              false;
                      if (post.childVideoCount > 0) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!home.isChildLevel2Loading(post.id) &&
                              home.getChildLevel2Replies(post.id).isEmpty) {
                            home.fetchChildLevel2Replies(post.id);
                          }
                        });
                        final childLevel2List =
                            home.getChildLevel2Replies(post.id);
                        final isLoading = home.isChildLevel2Loading(post.id);
                        // --- tombol masuk child level 2 ---
                        return Stack(
                          children: [
                            ReusableReplyVideoPage(
                              post: post,
                              index: hIndex,
                              isInit: isInit,
                              reply: reply,
                              video: video,
                              home: home,
                            ),
                            if (isLoading)
                              Center(child: CircularProgressIndicator()),
                            if (!isLoading &&
                                childLevel2List.isNotEmpty &&
                                _activeChildLevel2PostId != post.id)
                              Positioned(
                                bottom: 40,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        setState(() =>
                                            _activeChildLevel2PostId = post.id);
                                      });
                                    },
                                    child: Text('Lihat balasan ke balasan'),
                                  ),
                                ),
                              ),
                          ],
                        );
                      }
                      return ReusableReplyVideoPage(
                        post: post,
                        index: hIndex,
                        isInit: isInit,
                        reply: reply,
                        video: video,
                        home: home,
                      );
                    },
                  ),
                );
              },
            ),
            if (_activeChildLevel2PostId != null)
              Positioned.fill(
                child: Builder(
                  builder: (context) {
                    final childLevel2List =
                        home.getChildLevel2Replies(_activeChildLevel2PostId!);
                    return PageView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: childLevel2List.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, v2Index) {
                        final childPost = childLevel2List[v2Index];
                        return GestureDetector(
                          onVerticalDragEnd: (details) {
                            if (v2Index == 0 &&
                                details.primaryVelocity != null &&
                                details.primaryVelocity! > 0) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                setState(() => _activeChildLevel2PostId = null);
                              });
                            }
                          },
                          child: ReusableReplyVideoPage(
                            post: childPost,
                            index: v2Index,
                            isInit: true,
                            reply: reply,
                            video: video,
                            home: home,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class CustomBouncingScrollPhysics extends BouncingScrollPhysics {
  final double nFrictionFactor;

  CustomBouncingScrollPhysics(
      {ScrollPhysics? parent, this.nFrictionFactor = 0.001})
      : super(parent: parent);

  @override
  CustomBouncingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomBouncingScrollPhysics(
      parent: buildParent(ancestor),
      nFrictionFactor: nFrictionFactor,
    );
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 80,
        stiffness: 60,
        damping: 1,
      );

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    final double friction = offset > 0.0 ? nFrictionFactor : nFrictionFactor;
    return super.applyPhysicsToUserOffset(position, offset) * friction;
  }
}
