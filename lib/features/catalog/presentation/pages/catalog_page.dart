import 'package:flutter/material.dart';

import 'package:uz_xarid/core/constants/app_dimens.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Каталог'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(AppDimens.paddingMedium),
        child: Center(
          child: Text('Каталог mahsulotlari shu yerda bo‘ladi.'),
        ),
      ),
    );
  }
}

