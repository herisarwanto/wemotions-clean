import 'package:socialverse/export.dart';

class SubverseScreen extends StatelessWidget {
  const SubverseScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (_, __, ___) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(56),
            child: SafeArea(child: CustomAppBar()),
          ),
          body: RefreshIndicator(
            color: Theme.of(context).indicatorColor,
            backgroundColor: Theme.of(context).primaryColor,
            onRefresh: () async {
              __.loading = true;
              __.currentSortedPosts.clear();
              __.posts_page = 1;
              if(!logged_in!){
                __.loading = false;
                return Future.value();
              }
              await __.fetchCurrentSortedPosts;
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Stack(
                children: [

                  if (!__.loading) ...[
                    GridView.builder(
                      controller: __.controller,
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(top: 20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 1,
                        mainAxisSpacing: 1,
                        childAspectRatio: 0.65,
                      ),
                      itemCount: __.currentSortedPosts.length,
                      itemBuilder: (BuildContext context, int index) {
                        return SubversePostGridItem(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              VideoWidget.routeName,
                              arguments: VideoWidgetArgs(
                                posts: __.currentSortedPosts,
                                pageController:
                                    PageController(initialPage: index),
                                pageIndex: index,
                              ),
                            );
                          },
                          imageUrl: __.currentSortedPosts[index].thumbnailUrl,
                          createdAt: __.currentSortedPosts[index].createdAt,
                          viewCount: __.currentSortedPosts[index].viewCount,
                          username: __.currentSortedPosts[index].username,
                          pictureUrl: __.currentSortedPosts[index].pictureUrl,

                        );
                      },
                    ),
                  ],
                  if (__.loading) ...[
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 1,
                        mainAxisSpacing: 1,
                        childAspectRatio: 0.65,
                      ),
                      itemCount: 12,
                      itemBuilder: (_, __) {
                        return SubversePostGridPlaceholder();
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
