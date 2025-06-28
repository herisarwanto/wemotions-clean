// Flutter & Dart
export 'package:flutter/material.dart' hide SearchBar;
export 'package:flutter/cupertino.dart' hide RefreshCallback;
export 'package:flutter/scheduler.dart' hide Flow, timeDilation;
export 'package:flutter/services.dart';
export 'package:socialverse/main.dart';
export 'package:flutter/foundation.dart' hide Category;
export 'dart:convert';
export 'dart:async';
export 'dart:io';
export 'package:socialverse/app.dart';

// Packages
export 'package:flutter_screenutil/flutter_screenutil.dart';
export 'package:url_launcher/url_launcher.dart';
export 'package:share_plus/share_plus.dart';
export 'package:flutter_svg/flutter_svg.dart';
export 'package:video_player/video_player.dart';
export 'package:cached_network_image/cached_network_image.dart';
export 'package:wechat_assets_picker/wechat_assets_picker.dart';
export 'package:percent_indicator/percent_indicator.dart';
export 'package:path/path.dart' hide context;
export 'package:image_gallery_saver/image_gallery_saver.dart';
export 'package:path_provider/path_provider.dart';
export 'package:image_picker/image_picker.dart';
export 'package:image_cropper/image_cropper.dart';
export 'package:permission_handler/permission_handler.dart';
export 'package:shared_preferences/shared_preferences.dart';
export 'package:unicons/unicons.dart';
export 'package:camera/camera.dart';
export 'package:provider/provider.dart';
// export 'package:flutter_stripe/flutter_stripe.dart' hide Card;
export 'package:qr_flutter/qr_flutter.dart';
export 'package:screenshot/screenshot.dart';
export 'package:qr_code_scanner/qr_code_scanner.dart' hide CameraException;
export 'package:flutter_switch/flutter_switch.dart';
// export 'package:flutter_dotenv/flutter_dotenv.dart';
export 'package:home_widget/home_widget.dart';
export 'package:shimmer/shimmer.dart';
export 'package:audioplayers/audioplayers.dart';
export 'package:flutter_linkify/flutter_linkify.dart';

// Utils, Widgets, Constants, Extensions, Configs
// export 'package:socialverse/app.dart';
export 'package:socialverse/core/utils/constants/api_paths.dart';
export 'package:socialverse/core/utils/constants/assets.dart';
export 'package:socialverse/core/utils/constants/constants.dart';
export 'package:socialverse/core/utils/constants/static_sizes.dart';
export 'package:socialverse/features/home/utils/empty_state.dart';
export 'package:socialverse/core/utils/constants/user_preferences.dart';
export 'package:socialverse/core/widgets/progress_indicator.dart';
export 'package:socialverse/core/widgets/bottom_nav_bar.dart';
export 'package:socialverse/core/widgets/custom_button.dart';
export 'package:socialverse/core/widgets/custom_circular_avatar.dart';
export 'package:socialverse/core/widgets/camera_selector.dart';
export 'package:socialverse/core/widgets/camera_button.dart';

export 'package:socialverse/core/configs/injection/locator.dart';
//
export 'package:socialverse/core/utils/extensions/date_extension.dart';
export 'package:socialverse/core/utils/extensions/form_extension.dart';
//
export 'package:socialverse/core/utils/network/internet_error.dart';
export 'package:socialverse/core/utils/network/network_dio.dart';

export 'package:socialverse/core/utils/style/text_style.dart';
export 'package:socialverse/core/utils/style/text_form_decoration.dart';
export 'package:socialverse/core/utils/theme/theme.dart';

export 'package:socialverse/core/widgets/overlay_notification.dart';
export 'package:socialverse/core/widgets/custom_network_image.dart';
export 'package:socialverse/features/home/widgets/home_video/home_video_widget.dart';
export 'package:socialverse/features/home/widgets/home_video/play_button.dart';
export 'package:socialverse/features/home/utils/side_bar_item.dart';
export 'package:socialverse/features/home/utils/share_sheet.dart';
export 'package:socialverse/features/home/utils/share_to_item.dart';
export 'package:socialverse/features/home/utils/video_sheet_item.dart';
export 'package:socialverse/features/home/utils/video_sheet.dart';
export 'package:socialverse/features/home/utils/report_sheet.dart';
export 'package:socialverse/features/home/utils/report_submit_dialog.dart';
export 'package:socialverse/features/auth/widgets/auth_textformfield.dart';

export 'package:socialverse/features/auth/widgets/auth_aligned_text.dart';
export 'package:socialverse/features/auth/widgets/auth_button.dart';
export 'package:socialverse/features/auth/widgets/auth_button_withBorder.dart';
export 'package:socialverse/features/auth/widgets/auth_button_withColor.dart';
export 'package:socialverse/features/auth/widgets/auth_obscure_icon.dart';
export 'package:socialverse/features/auth/widgets/auth_save_button.dart';
export 'package:socialverse/features/auth/widgets/auth_sheet.dart';
export 'package:socialverse/features/auth/widgets/login_nav.dart';
export 'package:socialverse/features/auth/widgets/signup_nav.dart';
export 'package:socialverse/features/auth/widgets/social_button.dart';
export 'package:socialverse/features/auth/widgets/terms.dart';

export 'package:socialverse/features/profile/widgets/settings/custom_alert_dialog.dart';

export 'package:socialverse/features/home/widgets/reply_video/reply_info_side_bar.dart';
export 'package:socialverse/features/home/widgets/reply_video/reply_play_button.dart';
export 'package:socialverse/features/home/widgets/reply_video/reply_side_bar.dart';
export 'package:socialverse/features/home/widgets/reply_video/reply_video_progress_indicator.dart';
export 'package:socialverse/features/home/widgets/reply_video/reply_video_sheet.dart';
export 'package:socialverse/features/home/widgets/reply_video/reply_video_widget.dart';
export 'package:socialverse/features/home/utils/download_bar.dart';
export 'package:socialverse/features/home/utils/motions_sheet.dart';

export 'package:socialverse/features/create/widgets/camera_bar_item.dart';
export 'package:socialverse/features/create/widgets/circular_button.dart';
export 'package:socialverse/features/create/widgets/post_list_tile.dart';
export 'package:socialverse/features/create/widgets/post_tag_tile.dart';
export 'package:socialverse/features/create/widgets/post_textformfield.dart';
export 'package:socialverse/features/create/widgets/record_button.dart';
export 'package:socialverse/features/create/widgets/tagpeople_widget.dart';
export 'package:socialverse/features/create/widgets/image_picker.dart';

export 'package:socialverse/features/profile/presentation/edit_profile/edit_bio_screen.dart';
export 'package:socialverse/features/profile/presentation/edit_profile/edit_links_screen.dart';
export 'package:socialverse/features/profile/presentation/edit_profile/edit_name_screen.dart';
export 'package:socialverse/features/profile/presentation/edit_profile/edit_profile_screen.dart';
export 'package:socialverse/features/profile/presentation/edit_profile/edit_username_screen.dart';
export 'package:socialverse/features/profile/presentation/follow/follower_screen.dart';
export 'package:socialverse/features/profile/presentation/follow/following_screen.dart';
export 'package:socialverse/features/profile/presentation/invite/add_screen.dart';
export 'package:socialverse/features/profile/presentation/invite/invite_screen.dart';
export 'package:socialverse/features/profile/presentation/profile/profile_screen.dart';
export 'package:socialverse/features/profile/presentation/profile/user_profile_screen.dart';
export 'package:socialverse/features/profile/presentation/settings/account/account_information_screen.dart';
export 'package:socialverse/features/profile/presentation/settings/account/data_controls_screen.dart';
export 'package:socialverse/features/profile/presentation/settings/account/change_username_screen.dart';
export 'package:socialverse/features/profile/presentation/settings/account/manage_account_screen.dart';
export 'package:socialverse/features/profile/presentation/settings/general/qr_code_screen.dart';
export 'package:socialverse/features/profile/presentation/settings/general/settings_screen.dart';
export 'package:socialverse/features/profile/presentation/settings/general/theme_switch_screen.dart';

export 'package:socialverse/features/profile/widgets/account/account_save_button.dart';
export 'package:socialverse/features/profile/widgets/profile/edit_profile/profile_aligned_text.dart';
export 'package:socialverse/features/profile/widgets/profile/edit_profile/profile_textformfield.dart';
export 'package:socialverse/features/profile/widgets/profile/edit_profile/save_button.dart';
export 'package:socialverse/features/profile/widgets/profile/invite/add_item.dart';
export 'package:socialverse/features/profile/widgets/profile/invite/invite_item.dart';
export 'package:socialverse/features/profile/widgets/profile/invite/invite_list_tile_item.dart';
export 'package:socialverse/features/profile/widgets/profile/profile/following_item.dart';
export 'package:socialverse/features/profile/widgets/profile/profile/follower_item.dart';
export 'package:socialverse/features/profile/widgets/profile/profile/profile_body.dart';
export 'package:socialverse/features/profile/widgets/profile/profile/profile_button.dart';
export 'package:socialverse/features/profile/widgets/profile/profile/profile_header.dart';
export 'package:socialverse/features/profile/widgets/profile/profile/profile_tab_item.dart';
export 'package:socialverse/features/profile/widgets/profile/shared/bio.dart';
export 'package:socialverse/features/profile/widgets/profile/shared/post_grid_item.dart';
export 'package:socialverse/features/profile/widgets/profile/shared/posts_grid.dart';
export 'package:socialverse/features/profile/widgets/profile/shared/profile_info.dart';
export 'package:socialverse/features/profile/widgets/profile/shared/profile_link_tree.dart';
export 'package:socialverse/features/profile/widgets/profile/shared/profile_stats_item.dart';
export 'package:socialverse/features/profile/widgets/profile/user/user_profile_button.dart';
export 'package:socialverse/features/profile/widgets/profile/user/user_profile_header.dart';
export 'package:socialverse/features/profile/widgets/profile/user/user_tab_item.dart';

export 'package:socialverse/features/profile/widgets/settings/custom_app_bar.dart';
export 'package:socialverse/features/profile/widgets/settings/custom_list_tile.dart';
export 'package:socialverse/features/profile/widgets/settings/icon_list_tile.dart';
export 'package:socialverse/features/profile/widgets/settings/qr_code_scanner.dart';
export 'package:socialverse/features/profile/widgets/settings/qr_view.dart';
export 'package:socialverse/features/profile/widgets/settings/theme_switcher.dart';

export 'package:socialverse/features/profile/utils/create_sheet.dart';
export 'package:socialverse/features/profile/utils/create_sheet_item.dart';
export 'package:socialverse/features/profile/utils/link_sheet.dart';
export 'package:socialverse/features/profile/utils/link_sheet_item.dart';
export 'package:socialverse/features/profile/utils/profile_share_item.dart';
export 'package:socialverse/features/profile/utils/profile_share_sheet.dart';

// export 'package:socialverse/core/configs/route_generator/custom_router.dart';

export 'package:socialverse/features/search/widgets/subverse_detail/subverse_post_grid_placeholder.dart';
export 'package:socialverse/features/search/helper/image_helper.dart';
export 'package:socialverse/features/search/utils/subverse_share_item.dart';
export 'package:socialverse/features/search/utils/subverse_share_sheet.dart';
export 'package:socialverse/features/search/widgets/search/post_search_list.dart';
export 'package:socialverse/features/search/widgets/search/search_bar.dart';
export 'package:socialverse/features/search/widgets/search/subverse_search_list.dart';
export 'package:socialverse/features/search/widgets/search/user_search_list.dart';

export 'package:socialverse/features/search/widgets/subverse/custom_button.dart';
export 'package:socialverse/features/search/widgets/subverse/custom_cached_network_image.dart';
export 'package:socialverse/features/search/widgets/subverse/grid_holder.dart';
export 'package:socialverse/features/search/widgets/subverse/grid_placeholder.dart';
export 'package:socialverse/features/search/widgets/subverse/grid_view_button.dart';
export 'package:socialverse/features/search/widgets/subverse/list_holder.dart';
export 'package:socialverse/features/search/widgets/subverse/list_placeholder.dart';
export 'package:socialverse/features/search/widgets/subverse/subverse_aligned_text.dart';
export 'package:socialverse/features/search/widgets/subverse/subverse_grid_item.dart';
export 'package:socialverse/features/search/widgets/subverse/subverse_header.dart';
export 'package:socialverse/features/search/widgets/subverse/subverse_list_item.dart';
export 'package:socialverse/features/search/widgets/subverse/subverse_textformfield.dart';
export 'package:socialverse/features/search/widgets/subverse/subverse_widget.dart';

// Models, Services, Repositories
export 'package:socialverse/core/domain/models/category_model.dart';
export 'package:socialverse/core/domain/models/notifications_model.dart';
export 'package:socialverse/core/domain/models/post_model.dart';
export 'package:socialverse/core/domain/models/notification_model.dart';
export 'package:socialverse/features/home/domain/models/feed_model.dart';
export 'package:socialverse/features/auth/domain/service/auth_service.dart';
export 'package:socialverse/features/auth/domain/models/user.dart';
export 'package:socialverse/features/profile/domain/models/profile_model.dart';
export 'package:socialverse/features/profile/domain/models/activer_users_model.dart';
export 'package:socialverse/features/profile/domain/models/profile_posts_model.dart';
export 'package:socialverse/features/profile/domain/models/user_post_model.dart';
export 'package:socialverse/features/profile/domain/models/users_model.dart';

export 'package:socialverse/features/profile/domain/services/account_service.dart';
export 'package:socialverse/features/profile/domain/services/edit_profile_service.dart';
export 'package:socialverse/features/profile/domain/services/invite_service.dart';
export 'package:socialverse/features/profile/domain/services/settings_services.dart';
export 'package:socialverse/features/profile/domain/services/user_service.dart';

export 'package:socialverse/features/home/domain/models/single_post_model.dart';

export 'package:socialverse/features/search/domain/models/search/post_search_model.dart';
export 'package:socialverse/features/search/domain/models/search/subverse_search_model.dart';
export 'package:socialverse/features/search/domain/models/search/user_search_model.dart';
export 'package:socialverse/features/search/domain/models/subverse/category_model.dart';
export 'package:socialverse/features/search/domain/models/subverse/subverse_model.dart';
export 'package:socialverse/features/search/domain/services/create_subverse_service.dart';
export 'package:socialverse/features/search/domain/services/edit_subverse_service.dart';
export 'package:socialverse/features/search/domain/services/subscription_service.dart';
export 'package:socialverse/features/search/domain/services/subverse_service.dart';

// Providers
// export 'package:socialverse/core/providers/bottom_nav_provider.dart';
// export 'package:socialverse/core/providers/notification_provider.dart';
export 'package:socialverse/core/providers/theme_provider.dart';
export 'package:socialverse/features/home/providers/home_provider.dart';
export 'package:socialverse/features/home/providers/smooth_page_indicator_provider.dart';
export 'package:socialverse/features/home/domain/services/home_service.dart';
export 'package:socialverse/core/providers/report_provider.dart';
export 'package:socialverse/features/search/providers/video_provider.dart';
export 'package:socialverse/features/home/providers/reply_provider.dart';
export 'package:socialverse/features/auth/providers/auth_provider.dart';
export 'package:socialverse/core/providers/notification_provider.dart';
export 'package:socialverse/features/create/providers/camera_provider.dart';
export 'package:socialverse/features/create/providers/post_provider.dart';
export 'package:socialverse/core/providers/bottom_nav_provider.dart';
export 'package:socialverse/features/home/providers/exit_provider.dart';

// export 'package:socialverse/core/providers/snackbar_provider.dart';

export 'package:socialverse/features/profile/providers/edit_profile/edit_profile_provider.dart';
export 'package:socialverse/features/profile/providers/profile/profile_provider.dart';
export 'package:socialverse/features/profile/providers/profile/user_profile_provider.dart';

export 'package:socialverse/features/profile/providers/settings/account_provider.dart';
export 'package:socialverse/features/profile/providers/settings/invite_provider.dart';
export 'package:socialverse/features/profile/providers/settings/qr_code_provider.dart';
export 'package:socialverse/features/profile/providers/settings/settings_provider.dart';

export 'package:socialverse/features/search/providers/create_subverse_provider.dart';
export 'package:socialverse/features/search/providers/edit_subverse_provider.dart';
export 'package:socialverse/features/search/providers/search_provider.dart';
export 'package:socialverse/features/search/providers/subscription_provider.dart';

export 'package:socialverse/features/home/providers/nested_provider.dart';

// Screens

export 'package:socialverse/features/home/presentation/home_screen.dart';
export 'package:socialverse/features/auth/presentation/login/create_username_screen.dart';
export 'package:socialverse/features/auth/presentation/login/forgot_password_screen.dart';
export 'package:socialverse/features/auth/presentation/login/login_screen.dart';
export 'package:socialverse/features/auth/presentation/onboarding/onboarding_screen.dart';
export 'package:socialverse/features/auth/presentation/sign_up/email_screen.dart';

export 'package:socialverse/features/auth/presentation/sign_up/name_screen.dart';
export 'package:socialverse/features/auth/presentation/sign_up/password_screen.dart';
export 'package:socialverse/features/auth/presentation/sign_up/signup_screen.dart';
export 'package:socialverse/features/auth/presentation/sign_up/username_screen.dart';
export 'package:socialverse/features/auth/presentation/sign_up/verify_screen.dart';

export 'package:socialverse/features/create/presentation/camera_screen.dart';
export 'package:socialverse/features/create/presentation/post_screen.dart';

export 'package:socialverse/core/presentation/notifications.dart';

export 'package:socialverse/features/search/presentation/create_edit/create_subverse_screen.dart.dart';
export 'package:socialverse/features/search/presentation/create_edit/edit_subverse_screen.dart';
export 'package:socialverse/features/search/presentation/subverse/search_screen.dart';
export 'package:socialverse/features/search/presentation/subverse/subverse_detail_screen.dart';
export 'package:socialverse/features/search/presentation/subverse/subverse_empty_screen.dart';
export 'package:socialverse/features/search/presentation/subverse/subverse_screen.dart';
export 'package:socialverse/features/search/widgets/subverse_detail/subverse_detail_header.dart';
export 'package:socialverse/features/search/widgets/subverse_detail/subverse_post_grid_item.dart';
export 'package:socialverse/features/search/widgets/video/video_widget.dart';

// export 'package:socialverse/core/presentation/welcome_screen.dart';

export 'package:firebase_core/firebase_core.dart';
export 'package:firebase_crashlytics/firebase_crashlytics.dart';
export 'package:firebase_messaging/firebase_messaging.dart';
