import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uz_xarid/core/constants/app_assets.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';

import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:uz_xarid/core/widgets/app_image.dart';
import 'package:uz_xarid/core/widgets/app_text.dart';
import 'package:uz_xarid/core/widgets/w__container.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: Padding(
        padding: EdgeInsets.all(AppDimens.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: "Главная",
              color: AppColors.black300,
              fontSize: 12,
              fontWeight: 400,
            ),
            SizedBox(height: 18.h),
            Row(
              children: [
                AppText(
                  text: "Профиль",
                  color: AppColors.black500,
                  fontSize: 20,
                  fontWeight: 700,
                ),
                SizedBox(width: 12.w,),
                ContainerW(
                  color: AppColors.blue500,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                                
                    children: [
                      AppImage(path: AppAssets.labelImportant),
                      AppText(
                    text: "Базовый аккаунт",
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: 500,
                                    ),
                    ],
                                    ),
                  ),)
              ],
            ),
          ],
        ),
      ),
    );
  }
}
