import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uz_xarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uz_xarid/core/widgets/app_text.dart';
import 'package:uz_xarid/core/widgets/w__container.dart';

class SoonPage extends StatelessWidget {
  const SoonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UzXaridAppBar(
        onSearchChanged: (_) {},
        onMenuTap: () {},
        leading: ContainerW(
          onTap: () => context.pop(),
          radius: 10,
          color: Colors.white.withOpacity(0.2),
          child: const Padding(
            padding: EdgeInsets.all(10),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
      body: const Center(
        child: AppText(
          text: "bu funksiya yaqinda qo'shilsin",
          fontSize: 18,
          fontWeight: 600,
        ),
      ),
    );
  }
}
