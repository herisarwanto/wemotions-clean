import 'dart:isolate';
import 'package:dio/dio.dart';
import 'package:socialverse/export.dart';

enum RateItem { LOVE_IT, LIKE_IT, OKAY, DISLIKE_IT, HATE_IT }

class HomeProvider extends ChangeNotifier {
  final home = PageController();
  final replies = PageController();

  final _homeService = HomeService();
  final notification = getIt<NotificationProvider>();

  int _posts_page = 1;
  int get posts_page => _posts_page;

  set posts_page(int value) {
    _posts_page = value;
    notifyListeners();
  }

  //************
  bool _video_trend_bar = true;
  bool get video_trend_bar => _video_trend_bar;

  set video_trend_bar(bool value) {
    _video_trend_bar = value;
    notifyListeners();
  }

  int _vertical_drag_direction = 0; // 0 for no drag at initial
  int get vertical_drag_direction => _vertical_drag_direction;

  set vertical_drag_direction(int value) {
    _vertical_drag_direction = value;
    notifyListeners();
  }

  //*************

  double _playback_speed = 1.0;
  double get playback_speed => _playback_speed;

  set playback_speed(double value) {
    _playback_speed = value;
    notifyListeners();
  }

  Offset _tapPosition = Offset.zero;
  Offset get tapPosition => _tapPosition;

  set tapPosition(Offset value) {
    _tapPosition = value;
    notifyListeners();
  }

  void setTapPosition(Offset position) {
    _tapPosition = position;
    notifyListeners();
  }

  void getTapPosition(BuildContext context, TapDownDetails details) {
    final RenderBox referenceBox = context.findRenderObject() as RenderBox;
    _tapPosition = referenceBox.globalToLocal(details.globalPosition);
    notifyListeners();
    print(_tapPosition);
  }

  animateToPage(index) {
    home.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    notifyListeners();
  }

  int _index = 0;
  int get index => _index;

  set index(int value) {
    _index = value;
    notifyListeners();
  }

  int _horizontalIndex = 0;
  int get horizontalIndex => _horizontalIndex;

  set horizontalIndex(int value) {
    _horizontalIndex = value;
    // notifyListeners();
  }

  int _horizontalKeepRange = 1;

  double _slider_val = 0;
  double get slider_val => _slider_val;

  set slider_val(double value) {
    _slider_val = value;
    notifyListeners();
  }

  bool _isPlaying = true;
  bool get isPlaying => _isPlaying;

  set isPlaying(bool value) {
    _isPlaying = value;
    notifyListeners();
  }

  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;

  bool _isFollowing = false;
  bool get isFollowing => _isFollowing;

  set isFollowing(bool value) {
    _isFollowing = value;
    notifyListeners();
  }

  bool _loading = false;
  bool get loading => _loading;

  set loading(bool val) {
    if (_loading != val) {
      _loading = val;
      notifyListeners();
    }
  }

  bool _hasMorePosts = true;
  bool get hasMorePosts => _hasMorePosts;

  bool _isLiked = false;
  bool get isLiked => _isLiked;

  set isLiked(bool value) {
    _isLiked = value;
    notifyListeners();
  }

  List<List<Posts>> _posts = [];
  List<List<Posts>> get posts => _posts;

  set posts(List<List<Posts>> value) {
    _posts = value;
  }

  bool _canFetchReplies = false;

  bool _fetchingReplies = false;
  bool get fetchingReplies => _fetchingReplies;

  set fetchingReplies(bool value) {
    _fetchingReplies = value;
    notifyListeners();
  }

  List<Posts> _single_post = <Posts>[];
  List<Posts> get single_post => _single_post;

  set single_post(List<Posts> value) {
    _single_post = value;
  }

  bool _isTextExpanded = false;
  bool get isTextExpanded => _isTextExpanded;

  void toggleTextExpanded() {
    _isTextExpanded = !_isTextExpanded;
    if (_isTextExpanded) {
      _heightOfUserInfoBar = (5 + (6 * _expansionProgress)) * 10 + 120;
    } else {
      _heightOfUserInfoBar = 120;
    }

    _animateTextExpansion();
    notifyListeners();
  }

  double _expansionProgress = 0;
  double get expansionProgress => _expansionProgress;

  double _heightOfUserInfoBar = 120;
  double get heightOfUserInfoBar => _heightOfUserInfoBar;

  void _animateTextExpansion() {
    const stepDuration = Duration(milliseconds: 20);
    const steps = 5;
    int currentStep = 0;

    Timer.periodic(stepDuration, (timer) {
      _expansionProgress =
          _isTextExpanded ? (currentStep / steps) : 1 - (currentStep / steps);
      notifyListeners();
      currentStep++;

      if (currentStep > steps) {
        timer.cancel();
      }
    });
  }

  void handleVerticalDragUpdate(DragUpdateDetails details) {
    if (details.delta.dy < 0) {
      print('Swiping up');
      HapticFeedback.mediumImpact();
    } else if (details.delta.dy > 0) {
      print('Swiping down');
      HapticFeedback.mediumImpact();
    }
  }

  Future<void> updateViewCount({required int id}) async {
    Map data = {
      "post_id": id,
    };
    try {
      await _homeService.view(data: data);
    } catch (e) {
      print("Error in updateViewCount: $e");
    }

    notifyListeners();
  }

  // Future<void> updateExitCount({required int id}) async {
  //   Map data = {
  //     "post_id": id,
  //   };
  //   print(data);
  //   await _homeService.inspire(data: data);
  //   notifyListeners();
  // }

  // Future<void> updateRating({required int id, required int rating}) async {
  //   Map data = {
  //     "post_id": id,
  //     "rating": rating,
  //   };
  //   print(data);
  //   await _homeService.rating(data: data);
  //   notifyListeners();
  // }

  Future<void> onRefresh() async {
    HapticFeedback.mediumImpact();
    _posts.isEmpty ? null : await disposeAllControllers();

    _posts_page = 1;
    _hasMorePosts = true;
    _horizontalIndex = 0;
    _posts.clear();
    // hPosts.clear();
    notifyListeners();

    await createIsolate(token: token);
    notifyListeners();

    fetchingReplies = true;
    await createReplyIsolate(0, token: token);
    notifyListeners();
  }

  Future<void> postLikeAdd({required int id}) async {
    try {
      isLiked = true;
      await _homeService.postLikeAdd(id);
    } catch (e) {
      notification.show(
        title: 'User not logged in!',
        type: NotificationType.local,
      );
    }
  }

  Future<void> postLikeRemove({required int id}) async {
    try {
      isLiked = false;
      await _homeService.postLikeRemove(id);
    } catch (e) {
      notification.show(
        title: 'User not logged in!',
        type: NotificationType.local,
      );
    }
  }

  // Future<dynamic> deletePost({required int id}) async {
  //   final response = await _homeService.deletePost(id);
  //   if (response == 200 || response == 201) {
  //     return response;
  //   }
  // }

  // Future<void> blockPost({required int id}) async {
  //   await _homeService.blockPost(id);
  // }

  // Future<void> unblockPost({required int id}) async {
  //   await _homeService.unblockPost(id);
  // }

  // Future<dynamic> deletePostAdmin({required int id}) async {
  //   final response = await _homeService.deletePostAdmin(id);
  //   if (response == 200 || response == 201) {
  //     return response;
  //   }
  // }

//***************video related functions******************

  final Map<String, VideoPlayerController> _controllers = {};
  final Map<int, VoidCallback> _listeners = {};
  final Map<int, bool> _viewCountUpdated = {};

  initializedVideoPlayer() async {
    if (_posts.isNotEmpty) {
      _index = 0;
      _isPlaying = true;
      await _initController(0);
    }
    if (_posts.length > 1) {
      await _initController(1);
    }
    if (_posts.length > 2) {
      await _initController(2);
    }
  }

  // Future<void> preFetchData(int currentIndex) async {
  //   if (currentIndex + 2 < _posts.length) {
  //     await createReplyIsolate(currentIndex + 2, token: token);
  //   }
  //   if (currentIndex - 2 >= 0) {
  //     await createReplyIsolate(currentIndex - 2, token: token);
  //   }
  // }

  // void setPlaybackSpeed(double speed) {
  //   _playback_speed = speed;
  //   _controllers.values.forEach((controller) {
  //     controller.setPlaybackSpeed(speed);
  //   });
  //   notifyListeners();
  // }

  VideoPlayerController? videoController(int index) {
    if (posts.isEmpty || index < 0 || index >= posts.length) {
      return null;
    }
    return _controllers[posts.elementAt(index)[0].videoLink];
  }

  // VideoPlayerController? videoController(int index) {
  //  return _controllers[posts.elementAt(index)[0].videoLink] ??
  //       _controllers[API.video_link];
  // }

  void disposed(index) {
    final controller = videoController(index);
    if (controller != null) {
      try {
        controller.dispose();
      } catch (e) {
        // Controller might already be disposed
        print("Controller already disposed for index $index: $e");
      }
    }
    _controllers.remove(posts.elementAt(index));
  }

  VoidCallback _listenerSpawner(index) {
    return () {
      final controller = videoController(index);

      if (controller?.value.hasError == true) {
        // Handle errors here, e.g., show a snackbar
        print(controller?.value.errorDescription ?? '');
      }
      if (controller?.value.isInitialized == true) {
        // _nextAutoVideo();
        // print("Video initialized $index");
        final position = controller?.value.position;
        final duration = controller?.value.duration;

        // print("Video initialized $position");
        // print("Video initialized $duration");

        if (position != null && duration != null) {
          // Use a small range to account for floating-point precision
          final positionInSeconds = position.inMilliseconds;
          final durationInSeconds = duration.inMilliseconds;
          final positionDifference = durationInSeconds - positionInSeconds;

          if (durationInSeconds < 1) {
            return;
          }

          if (positionInSeconds > 1) {
            if (positionInSeconds > 1 &&
                (_viewCountUpdated[index] ?? false) == false &&
                logged_in!) {
              updateViewCount(id: posts.elementAt(index)[0].id);
              _viewCountUpdated[index] = true;
            }
          }

          if (positionDifference <= 0.4) {
            // Video playback is near or at the end, move to the next video
            // print("Video playback ended for index $index");
            _viewCountUpdated[index] = false;
            // _isAutoScroll ? _autoScroll(index) : null;
          }
        }
      }

      notifyListeners();
    };
  }

  Future<void> removeController(index) async {
    if (index == posts.length - 1) {
      return;
    }
    _stopController(index);
    if (index - 1 >= 0) {
      _removeController(index - 1);
    }
    _playController(
      ++index,
    );
    if (index == posts.length - 1) {
    } else {
      _initController(index + 1);
    }
  }

  void _removeController(int index) {
    final controller = videoController(index);
    if (controller != null) {
      try {
        controller.dispose();
      } catch (e) {
        // Controller might already be disposed
        print("Controller already disposed for index $index: $e");
      }
    }
    _controllers.remove(posts.elementAt(index));
    _listeners.remove(index);
  }

  void _cleanupControllers(int currentIndex) {
    final keepRange = 2; // Range of controllers to keep on each side
    final validIndices = <int>{};

    // Calculate valid indices to keep
    for (var i = currentIndex - keepRange; i <= currentIndex + keepRange; i++) {
      if (i >= 0 && i < posts.length) {
        validIndices.add(i);
      }
    }

    // Cleanup controllers outside the range
    final linksToRemove = <String>[];
    _controllers.forEach((videoLink, controller) {
      bool shouldKeep = false;
      for (var idx in validIndices) {
        if (idx < posts.length &&
            posts.elementAt(idx)[0].videoLink == videoLink) {
          shouldKeep = true;
          break;
        }
      }
      if (!shouldKeep) {
        try {
          controller.pause();
          controller.dispose();
        } catch (e) {
          // Controller might already be disposed
          print("Controller already disposed during cleanup: $e");
        }
        linksToRemove.add(videoLink);

        // Find and remove corresponding listener
        _listeners.removeWhere((index, _) =>
            index < 0 ||
            index >= posts.length ||
            posts.elementAt(index)[0].videoLink == videoLink);
      }
    });

    linksToRemove.forEach(_controllers.remove);
  }

  onPageChanged(int index) async {
    // Add bounds checking
    if (index < 0 || index >= posts.length) {
      return;
    }

    // Update index
    _index = index;
    _isPlaying = true;

    // Stop ALL videos immediately
    await stopAllVideos();

    // Initialize current video if needed
    if (!_controllers.containsKey(posts.elementAt(index)[0].videoLink)) {
      await _initController(index);
    }

    // Play only the current video
    final controller = videoController(index);
    if (controller != null && _isPlaying) {
      try {
        await controller.seekTo(Duration.zero);
        await controller.setLooping(true);
        await controller.play();
      } catch (e) {
        print("Error playing video: $e");
      }
    }

    // Pre-initialize adjacent videos
    if (index + 1 < posts.length) {
      unawaited(_initController(index + 1));
    }
    if (index - 1 >= 0) {
      unawaited(_initController(index - 1));
    }

    // Cleanup old controllers
    _cleanupControllers(index);

    notifyListeners();
  }

  Future<void> _playCurrentVideo(int index) async {
    try {
      if (index < 0 || index >= posts.length) return;

      final controller = videoController(index);
      if (controller == null) return;

      // Ensure listener is set up
      if (!_listeners.keys.contains(index)) {
        _listeners[index] = _listenerSpawner(index);
      }

      // Remove and re-add listener to prevent duplicates
      controller.removeListener(_listeners[index]!);
      controller.addListener(_listeners[index]!);

      // Play the video
      if (_isPlaying) {
        await controller.seekTo(const Duration(milliseconds: 0));
        await controller.setLooping(true);
        await controller.play();
      }
    } catch (e) {
      print("Error playing current video at index $index: $e");
    }
  }

  Future<void> disposeAllControllers() async {
    for (var entry in _controllers.entries) {
      try {
        await entry.value.pause();
        await entry.value.dispose();
      } catch (e) {
        // Controller might already be disposed
        print("Controller already disposed: $e");
      }
    }
    _controllers.clear();
    _listeners.clear();
    _viewCountUpdated.clear();
  }

  Future<void> _previousVideo() async {
    // Simply play the current video
    await _playController(_index);
  }

  Future<void> _nextVideo() async {
    // Simply play the current video
    await _playController(_index);
  }

  Future<void> _initController(int index) async {
    if (_controllers.containsKey(posts.elementAt(index)[0].videoLink)) return;

    var controller = VideoPlayerController.network(
      posts.elementAt(index)[0].videoLink,
      videoPlayerOptions: VideoPlayerOptions(
        allowBackgroundPlayback: false,
        mixWithOthers: false,
      ),
    );
    _viewCountUpdated[index] = false;
    _controllers[posts.elementAt(index)[0].videoLink] = controller;

    try {
      await controller.initialize();
      controller.setVolume(1.0);
      controller.setLooping(true);
      // Don't auto-play here - let the onPageChanged handle it
    } catch (e) {
      print("Error initializing controller for index $index: $e");
    }
  }

  Future<void> _stopAllVideos() async {
    for (var entry in _controllers.entries) {
      try {
        final controller = entry.value;
        if (controller.value.isPlaying) {
          await controller.pause();
        }
        await controller.seekTo(const Duration(milliseconds: 0));
      } catch (e) {
        print("Error stopping video: $e");
      }
    }
  }

  Future<void> _stopController(int index) async {
    try {
      if (index < 0 || index >= posts.length) return;

      if (_listeners[index] != null) {
        videoController(index)?.removeListener(_listeners[index]!);
      }
      await videoController(index)?.pause();
      await videoController(index)?.seekTo(const Duration(milliseconds: 0));
    } catch (e) {
      print("Error stopping controller at index $index: $e");
    }
  }

  Future<void> _playController(int index) async {
    try {
      if (index < 0 || index >= posts.length) return;

      // Stop all videos first to ensure clean state
      await _stopAllVideos();

      if (!_listeners.keys.contains(index)) {
        _listeners[index] = _listenerSpawner(index);
      }

      final controller = videoController(index);
      if (controller != null) {
        controller.removeListener(_listeners[index]!);
        controller.addListener(_listeners[index]!);

        if (_isPlaying) {
          await controller.seekTo(const Duration(milliseconds: 0));
          await controller.play();
          await controller.setLooping(true);
        } else {
          await controller.pause();
          await controller.setLooping(true);
        }
      }
    } catch (e) {
      print("Error playing controller at index $index: $e");
    }
  }

  final Set<int> _fetchingIndices = {};

  Future<void> createIsolate({String? token}) async {
    if (_loading) return; // Prevent duplicate requests

    _loading = true;
    notifyListeners();

    ReceivePort mainReceivePort = ReceivePort();

    try {
      await Isolate.spawn(getVideosTask, mainReceivePort.sendPort);
    } catch (e) {
      print("Failed to spawn isolate: $e");
      _loading = false;
      notifyListeners();
      // Show error notification
      notification.show(
        title: 'Failed to load videos',
        type: NotificationType.local,
      );
      return;
    }

    mainReceivePort.listen((message) {
      if (message is SendPort) {
        SendPort isolateSendPort = message;
        ReceivePort isolateResponseReceivePort = ReceivePort();

        isolateSendPort
            .send([_posts_page, isolateResponseReceivePort.sendPort, token]);

        isolateResponseReceivePort.listen((isolateResponse) {
          if (isolateResponse is List) {
            final newPosts = isolateResponse.cast<List<Posts>>();
            if (newPosts.isNotEmpty) {
              final existingPostIds =
                  _posts.map((postList) => postList[0].id).toSet();
              final uniquePosts = newPosts
                  .where(
                      (postList) => !existingPostIds.contains(postList[0].id))
                  .toList();

              if (uniquePosts.isNotEmpty) {
                _posts.addAll(uniquePosts);
                _posts_page++;
              }
            } else {
              _hasMorePosts = false;
            }
            _canFetchReplies = true;
          } else if (isolateResponse is String &&
              isolateResponse.contains('error')) {
            // Handle error response
            notification.show(
              title: 'Failed to load videos',
              type: NotificationType.local,
            );
          }
          _loading = false;
          notifyListeners();
        });
      }
    });
  }

  static void getVideosTask(SendPort mySendPort) async {
    final _homeService = HomeService();
    ReceivePort isolateReceivePort = ReceivePort();
    mySendPort.send(isolateReceivePort.sendPort);

    await for (var message in isolateReceivePort) {
      if (message is List && message.length >= 2) {
        final int index = message[0];
        final SendPort isolateResponseSendPort = message[1];
        final String? token = message.length > 2 ? message[2] : null;

        try {
          final response = await _homeService.getFeed(index, token ?? '');
          final List<Posts> data = FeedModel.fromJson(response).posts;
          isolateResponseSendPort.send(data.map((e) => [e]).toList());
        } catch (e) {
          print("Error fetching feed in isolate: $e");
          isolateResponseSendPort.send([]); // Send empty response on failure
        }
      }
    }
  }

  Future<void> createReplyIsolate(int indexForFetch, {String? token}) async {
    if (!_canFetchReplies) {
      print("Cannot fetch replies: waiting for posts to be loaded");
      return;
    }

    if (_fetchingIndices.contains(indexForFetch)) return;

    if (_posts.isEmpty || indexForFetch >= _posts.length) return;

    _fetchingIndices.add(indexForFetch);
    _fetchingReplies = true;
    notifyListeners();

    ReceivePort mainReceivePort = ReceivePort();

    try {
      await Isolate.spawn(getRepliesTask, mainReceivePort.sendPort);

      SendPort isolateSendPort = await mainReceivePort.first as SendPort;
      ReceivePort isolateResponseReceivePort = ReceivePort();

      isolateSendPort.send([
        _posts[indexForFetch][0].id,
        isolateResponseReceivePort.sendPort,
        token
      ]);

      final isolateResponse =
          await isolateResponseReceivePort.first as List<Posts>;

      // Clear existing replies before adding new ones
      if (_posts[indexForFetch].length > 1) {
        _posts[indexForFetch] = [_posts[indexForFetch][0]];
      }

      _posts[indexForFetch].addAll(isolateResponse);

      isolateResponseReceivePort.close();
      notifyListeners();
    } catch (e) {
      print("Error in createReplyIsolate: $e");
      // Show error notification for reply loading failure
      notification.show(
        title: 'Failed to load replies',
        type: NotificationType.local,
      );
    } finally {
      _fetchingIndices.remove(indexForFetch);
      _fetchingReplies = false;
      mainReceivePort.close();
      notifyListeners();
    }
  }

  static void getRepliesTask(SendPort mySendPort) async {
    final _homeService = HomeService();
    ReceivePort isolateReceivePort = ReceivePort();

    mySendPort.send(isolateReceivePort.sendPort);

    await for (var message in isolateReceivePort) {
      if (message is List && message.length >= 2) {
        final int postId = message[0];
        final SendPort isolateResponseSendPort = message[1];
        final String? token = message.length > 2 ? message[2] : null;

        try {
          final response = await _homeService.getReplies(postId, token ?? '');
          final List<Posts> data = ReplyModel.fromJson(response).post;
          isolateResponseSendPort.send(data);
        } catch (e) {
          print("Error in isolate: $e");
          isolateResponseSendPort.send([]);
        }
      }
    }
  }

  Future<void> getSinglePost({required int id}) async {
    Response response = await _homeService.getSinglePost(id: id);
    if (response.statusCode == 200 && response.statusCode == 201) {
      final post = SinglePostModel.fromJson(response.data).post;
      _single_post.addAll(post);
      print(_single_post);
      notifyListeners();
    }
  }

  // Cache for child level 2 replies: key = parent post id (child level 1), value = list of Posts (child level 2)
  final Map<int, List<Posts>> _childLevel2Replies = {};
  final Map<int, bool> _childLevel2Loading = {};

  List<Posts> getChildLevel2Replies(int parentId) =>
      _childLevel2Replies[parentId] ?? [];
  bool isChildLevel2Loading(int parentId) =>
      _childLevel2Loading[parentId] ?? false;

  Future<void> fetchChildLevel2Replies(int parentId, {String? token}) async {
    if (_childLevel2Loading[parentId] == true) return;
    _childLevel2Loading[parentId] = true;
    notifyListeners();
    ReceivePort mainReceivePort = ReceivePort();
    try {
      await Isolate.spawn(getRepliesTask, mainReceivePort.sendPort);
      SendPort isolateSendPort = await mainReceivePort.first as SendPort;
      ReceivePort isolateResponseReceivePort = ReceivePort();
      isolateSendPort
          .send([parentId, isolateResponseReceivePort.sendPort, token]);
      final isolateResponse =
          await isolateResponseReceivePort.first as List<Posts>;
      _childLevel2Replies[parentId] = isolateResponse;
      isolateResponseReceivePort.close();
    } catch (e) {
      print("Error fetching child level 2 replies: $e");
      _childLevel2Replies[parentId] = [];
    } finally {
      _childLevel2Loading[parentId] = false;
      mainReceivePort.close();
      notifyListeners();
    }
  }

  Future<void> stopAllVideos() async {
    for (var entry in _controllers.entries) {
      try {
        final controller = entry.value;
        if (controller.value.isPlaying) {
          await controller.pause();
        }
        await controller.seekTo(const Duration(milliseconds: 0));
      } catch (e) {
        print("Error stopping video: $e");
      }
    }
  }
}
