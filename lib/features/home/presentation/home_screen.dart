import 'package:socialverse/export.dart';

import '../widgets/home_video/post_upload_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<HomeProvider>(
      builder: (_, provider, ___) {
        return Scaffold(
          backgroundColor: Colors.black,
          resizeToAvoidBottomInset: false,
          body: RefreshIndicator(
            color: Theme.of(context).hintColor,
            backgroundColor: Colors.black,
            onRefresh: () async => provider.onRefresh(),
            // onRefresh: ()async{},
            child: Stack(
              children: [
                EmptyState(),
                if (provider.posts.isNotEmpty) ...[
                  HomeVideoWidget(
                    posts: provider.posts,
                    pageController: provider.home,
                    pageIndex: 0,
                    isFromFeed: true,
                  ),
                  Positioned(
                    child: PostUploadIndicator(),
                    bottom: provider.heightOfUserInfoBar,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
