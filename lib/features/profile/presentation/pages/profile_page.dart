import 'package:flutter/material.dart';

import 'package:uz_xarid/core/constants/app_dimens.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(AppDimens.paddingMedium),
        child: Center(
          child: Text('Profil ma’lumotlari shu yerda bo‘ladi.'),
        ),
      ),
    );
  }
}

