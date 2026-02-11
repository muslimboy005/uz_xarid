import 'package:flutter/material.dart';

import 'package:uz_xarid/core/constants/app_dimens.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Избранные'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(AppDimens.paddingMedium),
        child: Center(
          child: Text('Sevimli mahsulotlaringiz shu yerda bo‘ladi.'),
        ),
      ),
    );
  }
}

