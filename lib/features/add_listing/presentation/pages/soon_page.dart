import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uzxarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uzxarid/core/widgets/app_text.dart';
import 'package:uzxarid/core/widgets/w__container.dart';

class SoonPage extends StatelessWidget {
  const SoonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return UzXaridScaffold(
      leading: ContainerW(
        onTap: () => context.pop(),
        radius: 10,
        color: Colors.white.withValues(alpha: 0.2),
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
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
