import 'dart:developer';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:socialverse/export.dart';

class VideoProvider with ChangeNotifier {
  HomeService _homeService = HomeService();
  final view_video = PageController();
  final notification = getIt<NotificationProvider>();

  List _posts = [];
  List get posts => _posts;

  set posts(List allPosts) {
    _posts = allPosts;
    notifyListeners();
  }

  List _replyPosts = [];
  List get replyPosts => _replyPosts;

  set replyPosts(List allPosts) {
    _replyPosts = allPosts;
    notifyListeners();
  }

  int _index = 0;
  bool _isPlaying = true;

  int get index => _index;
  bool get isPlaying => _isPlaying;

  set isPlaying(bool val) {
    if (_isPlaying != val) {
      _isPlaying = val;
      notifyListeners();
    }
  }

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  set isInitialized(bool val) {
    _isInitialized = val;
    notifyListeners();
  }

  VideoProvider(
      {required int initialIndex,
      required List<dynamic> posts,
      bool isFromProfile = false}) {
    _index = initialIndex;
    _posts = posts;

    if (posts.isNotEmpty) {
      initializedVideoPlayer(initialIndex);
    }
    if (!isFromProfile) {
      unawaited(createReplyIsolate(initialIndex, token: token));
    }
  }

  int _vertical_drag_direction = 0; // 0 for no drag at initial
  int get vertical_drag_direction => _vertical_drag_direction;

  set vertical_drag_direction(int value) {
    _vertical_drag_direction = value;
    notifyListeners();
  }

  double _heightOfUserInfoBar = 120;
  double get heightOfUserInfoBar => _heightOfUserInfoBar;

  bool _isFollowing = false;
  bool get isFollowing => _isFollowing;

  set isFollowing(bool value) {
    _isFollowing = value;
    notifyListeners();
  }

  bool _loading = false;
  bool get loading => _loading;

  bool _isLiked = false;
  bool get isLiked => _isLiked;

  set isLiked(bool value) {
    _isLiked = value;
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

// =============== downloading variables ==================

  bool _downloading = false;
  bool get downloading => _downloading;

  bool _downloadingCompleted = false;
  bool get downloadingCompleted => _downloadingCompleted;

  String _progressString = '';
  String get progressString => _progressString;

  Future<void> saveDownloadedVideoToGallery({required String videoPath}) async {
    await ImageGallerySaver.saveFile(videoPath);
    log("Video Saved to Gallery");
  }

  Future<void> removeDownloadedVideo({required String videoPath}) async {
    try {
      File file = File(videoPath);
      if (await file.exists()) {
        await file.delete(recursive: true);
        log("Video Deleted from App Directory");
      }
    } catch (error) {
      debugPrint('$error');
      log(error.toString());
    }
  }

  Future<void> saveVideo({
    required String videoUrl,
    required String title,
  }) async {
    Dio dio = Dio();
    try {
      Directory dir;
      if (Platform.isAndroid) {
        dir = await getExternalStorageDirectory() ??
            await getApplicationDocumentsDirectory();
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      final String videoPath = join(
        dir.path,
        '$title.mp4',
      );

      await dio.download(
        videoUrl,
        videoPath,
        onReceiveProgress: (rec, total) {
          _downloading = true;
          _progressString = ((rec / total) * 100).toStringAsFixed(0) + "%";
          notifyListeners();
        },
      );

      await saveDownloadedVideoToGallery(videoPath: videoPath);
      await removeDownloadedVideo(videoPath: videoPath);
    } catch (e) {
      debugPrint(e.toString());
    }
    _downloading = false;
    _downloadingCompleted = true;
    _progressString = "Completed";
    notifyListeners();
    Future.delayed(const Duration(seconds: 2)).then(
      (value) {
        _downloadingCompleted = false;
        notifyListeners();
      },
    );
    log("Download completed");
    notifyListeners();
  }

  // ==============controllers====================

  final Map<String, VideoPlayerController> _controllers = {};
  final Map<int, VoidCallback> _listeners = {};
  final Map<int, bool> _viewCountUpdated = {};

  initializedVideoPlayer(int index) async {
    if (_posts.isNotEmpty) {
      _index = index;
      _isPlaying = true;
      await _initController(index);
    }

    if (_posts.length > index + 1) {
      await _initController(index + 1);
    }
    if (0 <= index - 1) {
      await _initController(index - 1);
    }
  }

  Future<void> _initController(int index) async {
    if (_controllers.containsKey(_posts.elementAt(index).videoLink)) return;

    var controller = VideoPlayerController.networkUrl(
      Uri.parse(_posts.elementAt(index).videoLink),
      videoPlayerOptions: VideoPlayerOptions(
        allowBackgroundPlayback: false,
        mixWithOthers: false,
      ),
    );
    _viewCountUpdated[index] = false;
    _controllers[_posts.elementAt(index).videoLink] = controller;
    controller.initialize().then((_) {
      controller.setVolume(1.0);
      if (index == _index) {
        _isInitialized = true;
        notifyListeners();
        _playController(index);
      }
    });
  }

  Future<void> _stopController(int index) async {
    print(
        "stop: $index :::: ${_controllers[_posts.elementAt(index).videoLink]} ::::::::::::::::::::::::::::::::::::::");
    try {
      if (index < 0 || index >= _posts.length) return;

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
    print(
        "playing: $index :::: ${_controllers[_posts.elementAt(index).videoLink]} ::::::::::::::::::::::::::::::::::::::");
    try {
      if (index < 0 || index >= _posts.length) return;

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
              updateViewCount(id: _posts.elementAt(index).id);
              _viewCountUpdated[index] = true;
            }
          }

          if (positionDifference <= 0.4) {
            _viewCountUpdated[index] = false;
          }
        }
      }

      notifyListeners();
    };
  }

  VideoPlayerController? videoController(int index) {
    if (_posts.isEmpty || index < 0 || index >= _posts.length) {
      return null;
    }
    return _controllers[_posts.elementAt(index).videoLink];
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
  }

  onPageChanged(int index) async {
    _isPlaying = true;

    final oldIndex = _index;

    _index = index;

    if (!_controllers.containsKey(_posts.elementAt(index).videoLink)) {
      await _initController(index);
    }

    await _stopController(oldIndex);

    if (_vertical_drag_direction == -1) {
      // Going up
      if (_replyPosts.length > 0) {
        _replyPosts.clear();
      }
      await _previousVideo();
    } else if (_vertical_drag_direction == 1) {
      // Going down
      if (_replyPosts.length > 0) {
        _replyPosts.clear();
      }
      await _nextVideo();
    }

    if (_vertical_drag_direction == 1) {
      if (index + 1 < _posts.length) _initController(index + 1);
      if (index + 2 < _posts.length) _initController(index + 2);
    } else {
      if (index - 1 >= 0) _initController(index - 1);
      if (index - 2 >= 0) _initController(index - 2);
    }

    _cleanupControllers(index);

    // unawaited(createIsolate(token: token)
    //     .then((_) => notifyListeners())
    //     .catchError((e) => print("Error fetching new data: $e"))
    // );

    notifyListeners();
  }

  Future<void> _previousVideo() async {
    if (_index - 1 >= 0 &&
        !_controllers.containsKey(_posts.elementAt(_index - 1).videoLink)) {
      unawaited(
          _initController(_index - 1)); // Don't await here for faster playback
    }

    await _playController(_index);
    unawaited(createReplyIsolate(_index, token: token));
  }

  Future<void> _nextVideo() async {
    if (_index == _posts.length - 1) {
      await _playController(_index);
      return;
    }

    if (_index + 1 < _posts.length &&
        !_controllers.containsKey(_posts.elementAt(_index + 1).videoLink)) {
      unawaited(
          _initController(_index + 1)); // Don't await here for faster playback
    }

    await _playController(_index);

    unawaited(createReplyIsolate(_index, token: token));
  }

  void _cleanupControllers(int currentIndex) {
    final keepRange = 2; // Range of controllers to keep on each side
    final validIndices = <int>{};

    // Calculate valid indices to keep
    for (var i = currentIndex - keepRange; i <= currentIndex + keepRange; i++) {
      if (i >= 0 && i < _posts.length) {
        validIndices.add(i);
      }
    }

    // Cleanup controllers outside the range
    final linksToRemove = <String>[];
    _controllers.forEach((videoLink, controller) {
      bool shouldKeep = false;
      for (var idx in validIndices) {
        if (idx < _posts.length &&
            _posts.elementAt(idx).videoLink == videoLink) {
          shouldKeep = true;
          break;
        }
      }
      if (!shouldKeep) {
        controller.pause();
        controller.dispose();
        linksToRemove.add(videoLink);

        // Find and remove corresponding listener
        _listeners.removeWhere((index, _) =>
            index < 0 ||
            index >= _posts.length ||
            _posts.elementAt(index).videoLink == videoLink);
      }
    });

    linksToRemove.forEach(_controllers.remove);
  }

  Future<void> disposeAllControllers() async {
    _controllers.forEach((_, controller) async {
      await controller.pause();
      await controller.dispose();
    });
    _controllers.clear();
    _listeners.clear();
    _viewCountUpdated.clear();
  }

  Future<void> goingBack() async {
    await disposeAllControllers();
    _replyPosts.clear();
  }

  final Set<int> _fetchingIds = {};

  Future<void> createReplyIsolate(int indexForFetch, {String? token}) async {
    if (_fetchingIds.contains(indexForFetch)) return;

    _fetchingIds.add(indexForFetch);

    ReceivePort mainReceivePort = ReceivePort();

    try {
      await Isolate.spawn(getRepliesTask, mainReceivePort.sendPort);

      SendPort isolateSendPort = await mainReceivePort.first as SendPort;
      ReceivePort isolateResponseReceivePort = ReceivePort();

      isolateSendPort.send([
        _posts[indexForFetch].id,
        isolateResponseReceivePort.sendPort,
        token
      ]);

      final isolateResponse =
          await isolateResponseReceivePort.first as List<Posts>;

      // Clear existing replies before adding new ones
      if (_replyPosts.length > 0) {
        _replyPosts.clear();
      }

      if (isolateResponse.isEmpty) return;

      _replyPosts.addAll(isolateResponse);

      isolateResponseReceivePort.close();
      notifyListeners();
    } catch (e) {
      print("Error in view createReplyIsolate: $e");
    } finally {
      _fetchingIds.remove(indexForFetch);
      mainReceivePort.close();
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
}
