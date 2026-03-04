import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:uz_xarid/features/profile/presentation/widgets/authorized_profile_content.dart';
import 'package:uz_xarid/features/profile/presentation/widgets/unauth_profile_content.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!context.mounted) return const SizedBox.shrink();
    final isDark = context.isDark;
    final bodyBg = context.bodyBackground;
    final containerBg = context.surfaceContainer;
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: UzXaridAppBar(onSearchChanged: (query) {}, onMenuTap: () {}),
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: isDark ? AppColors.darkBackground : AppColors.black50,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.paddingMedium),
            child: BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                final profile = state.profileModel;

                final bool isAuthorized =
                    profile != null &&
                    profile.status &&
                    profile.data.user != null &&
                    !profile.data.askName &&
                    profile.data.user!.firstName.isNotEmpty;

                return Stack(
                  children: [
                    const UnauthProfileContent(),

                    // loading paytida ham eski data bo'lsa ko'rsatamiz (flash oldini olish)
                    if (isAuthorized ||
                        (state.status == ProfileStatus.loading &&
                            profile != null &&
                            profile.data.user != null))
                      Container(
                        color: bodyBg,
                        child: AuthorizedProfileContent(
                          user: state.profileModel!.data.user!,
                        ),
                      ),

                    // Faqat birinchi yuklanishda (data yo'q) spinner ko'rsatamiz
                    if (state.status == ProfileStatus.loading &&
                        profile == null)
                      Container(
                        color: containerBg,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
