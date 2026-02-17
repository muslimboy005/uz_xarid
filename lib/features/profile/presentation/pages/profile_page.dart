import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:uz_xarid/core/dp/infection.dart';
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
    return BlocProvider(
      create: (context) => getIt<ProfileBloc>()..add(const ProfileLoadEvent()),
      child: Scaffold(
        backgroundColor: AppColors.primary,
        appBar: UzXaridAppBar(onSearchChanged: (query) {}, onMenuTap: () {}),
        body: Container(
          height: MediaQuery.of(context).size.height,
          color: AppColors.background,
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

                      if (state.status == ProfileStatus.success && isAuthorized)
                        Container(
                          color: AppColors.background,
                          child: AuthorizedProfileContent(
                            fullName:
                                "${state.profileModel!.data.user!.firstName} ${state.profileModel!.data.user!.lastName}",
                            phoneNumber: state.profileModel!.data.user!.phone,
                          ),
                        ),

                      if (state.status == ProfileStatus.loading &&
                          profile == null)
                        Container(
                          color: AppColors.background,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
