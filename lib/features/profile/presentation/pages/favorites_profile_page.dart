// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:uzxarid/core/constants/app_colors.dart';
// import 'package:uzxarid/core/theme/theme_colors.dart';
// import 'package:uzxarid/core/widgets/app_text.dart';
// import 'package:uzxarid/core/widgets/uzxarid_app_bar.dart';
// import 'package:uzxarid/core/widgets/w__container.dart';
// import 'package:uzxarid/l10n/app_localizations.dart';

// class FavoritesProfilePage extends StatefulWidget {
//   const FavoritesProfilePage({super.key});

//   @override
//   State<FavoritesProfilePage> createState() => _FavoritesProfilePageState();
// }

// class _FavoritesProfilePageState extends State<FavoritesProfilePage> {
//   int _selectedTab = 0;

//   List<_FilterItem> _savedFilters(AppLocalizations l10n) => [
//     _FilterItem(
//       title: 'iPhone 14 Pro 256GB',
//       date: l10n.savedFilterDateSample,
//       fields: {
//         l10n.savedFilterCategoryLabel: l10n.savedFilterCategoryHomeGarden,
//         l10n.savedFilterRegionLabel: l10n.savedFilterRegionTashkent,
//         l10n.savedFilterCityLabel: l10n.savedFilterCityTashkent,
//         l10n.savedFilterBusinessOnlyLabel: l10n.savedFilterBusinessOnlyValue,
//         l10n.savedFilterCurrencyLabel: l10n.savedFilterCurrencyValue,
//         l10n.savedFilterSortByLabel: l10n.savedFilterSortMostRelevant,
//       },
//       statusText: l10n.savedFilterStatusEmpty,
//     ),
//     _FilterItem(
//       title: 'iPhone 14 Pro 256GB',
//       date: l10n.savedFilterDateSample,
//       fields: {
//         l10n.savedFilterCategoryLabel: l10n.savedFilterCategoryHomeGarden,
//         l10n.savedFilterRegionLabel: l10n.savedFilterRegionTashkent,
//         l10n.savedFilterCityLabel: l10n.savedFilterCityTashkent,
//         l10n.savedFilterBusinessOnlyLabel: l10n.savedFilterBusinessOnlyValue,
//         l10n.savedFilterCurrencyLabel: l10n.savedFilterCurrencyValue,
//         l10n.savedFilterSortByLabel: l10n.savedFilterSortMostRelevant,
//       },
//       statusText: l10n.savedFilterStatusEmpty,
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final isDark = context.isDark;
//     final bodyBg = context.bodyBackground;
//     final cardColor = context.cardSurface;
//     final textColor = context.textPrimary;
//     final textSecondary = context.context.textSecondary;
//     final borderColor = context.context.borderColor;
//     final surfaceContainer = context.context.surfaceContainer;
//     final l10n = AppLocalizations.of(context)!;
//     final savedFilters = _savedFilters(l10n);

//     return Scaffold(
//       appBar: UzXaridAppBar(onSearchChanged: (query) {}, onMenuTap: () {}),
//       backgroundColor: context.bodyBackground,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   GestureDetector(
//                     onTap: () => context.pop(),
//                     child: ContainerW(
//                       color: context.cardSurface,
//                       radius: 8,
//                       child: const Padding(
//                         padding: EdgeInsets.all(10),
//                         child: Icon(Icons.arrow_back_ios_new, size: 16),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   AppText(
//                     text: l10n.favoritesProfileTitle,
//                     fontSize: 22,
//                     fontWeight: 700,
//                     color: context.textPrimary,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               _TabBar(
//                 tabs: [l10n.favoritesTab, l10n.savedFilterTab],
//                 selectedIndex: _selectedTab,
//                 onTap: (i) => setState(() => _selectedTab = i),
//                 activeColor: AppColors.white,
//                 inactiveColor: Colors.transparent,
//               ),
//               const SizedBox(height: 16),
//               Expanded(
//                 child: _selectedTab == 0
//                     ? _EmptyState(
//                         icon: Icons.favorite_border_rounded,
//                         title: l10n.favoritesEmptyTitle,
//                         subtitle: l10n.favoritesEmptySubtitle,
//                       )
//                     : ListView.separated(
//                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                         itemCount: savedFilters.length,
//                         separatorBuilder: (_, __) => const SizedBox(height: 12),
//                         itemBuilder: (context, i) =>
//                             _SavedFilterCard(item: savedFilters[i]),
//                       ),
//               ),
//               const SizedBox(height: 16),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _TabBar extends StatelessWidget {
//   const _TabBar({
//     required this.tabs,
//     required this.selectedIndex,
//     required this.onTap,
//     this.activeColor,
//     this.inactiveColor,
//   });

//   final List<String> tabs;
//   final int selectedIndex;
//   final void Function(int) onTap;
//   final Color? activeColor;
//   final Color? inactiveColor;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: context.surfaceContainer,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: context.borderColor),
//       ),
//       padding: const EdgeInsets.all(4),
//       child: Row(
//         children: List.generate(tabs.length, (i) {
//           final selected = i == selectedIndex;
//           return Expanded(
//             child: GestureDetector(
//               onTap: () => onTap(i),
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 padding: const EdgeInsets.symmetric(vertical: 10),
//                 decoration: BoxDecoration(
//                   color: selected
//                       ? (activeColor ?? AppColors.white)
//                       : (inactiveColor ?? Colors.transparent),
//                   borderRadius: BorderRadius.circular(8),
//                   boxShadow: selected
//                       ? [
//                           BoxShadow(
//                             color: Colors.black.withValues(alpha: 0.08),
//                             blurRadius: 4,
//                             offset: const Offset(0, 1),
//                           ),
//                         ]
//                       : null,
//                 ),
//                 child: Center(
//                   child: AppText(
//                     text: tabs[i],
//                     fontSize: 13,
//                     fontWeight: selected ? 600 : 400,
//                     color: selected ? AppColors.black500 : AppColors.black300,
//                   ),
//                 ),
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }

// class _EmptyState extends StatelessWidget {
//   const _EmptyState({required this.icon, required this.title, this.subtitle});

//   final IconData icon;
//   final String title;
//   final String? subtitle;

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 68,
//             height: 68,
//             decoration: BoxDecoration(
//               color: AppColors.blue500,
//               borderRadius: BorderRadius.circular(18),
//             ),
//             child: Icon(icon, color: AppColors.white, size: 34),
//           ),
//           const SizedBox(height: 20),
//           AppText(
//             text: title,
//             fontSize: 16,
//             fontWeight: 700,
//             color: context.textPrimary,
//           ),
//           if (subtitle != null) ...[
//             const SizedBox(height: 8),
//             AppText(
//               text: subtitle!,
//               fontSize: 13,
//               fontWeight: 400,
//               color: context.textSecondary,
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }

// class _FilterItem {
//   final String title;
//   final String date;
//   final Map<String, String> fields;
//   final String statusText;

//   const _FilterItem({
//     required this.title,
//     required this.date,
//     required this.fields,
//     required this.statusText,
//   });
// }

// class _SavedFilterCard extends StatelessWidget {
//   const _SavedFilterCard({required this.item});
//   final _FilterItem item;

//   @override
//   Widget build(BuildContext context) {
//     return ContainerW(
//       color: context.cardSurface,
//       radius: 12,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(
//                   Icons.access_time_rounded,
//                   size: 14,
//                   color: context.textSecondary,
//                 ),
//                 const SizedBox(width: 4),
//                 AppText(
//                   text: item.date,
//                   fontSize: 12,
//                   fontWeight: 400,
//                   color: context.textSecondary,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 6),
//             AppText(
//               text: item.title,
//               fontSize: 15,
//               fontWeight: 700,
//               color: context.textPrimary,
//             ),
//             const SizedBox(height: 10),
//             ...item.fields.entries.map(
//               (e) => Padding(
//                 padding: const EdgeInsets.only(bottom: 4),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Expanded(
//                       flex: 4,
//                       child: AppText(
//                         text: e.key,
//                         fontSize: 12,
//                         fontWeight: 400,
//                         color: context.textSecondary,
//                       ),
//                     ),
//                     Expanded(
//                       flex: 5,
//                       child: AppText(
//                         text: e.value,
//                         fontSize: 12,
//                         fontWeight: 400,
//                         color: context.textPrimary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       vertical: 12,
//                       horizontal: 16,
//                     ),
//                     decoration: BoxDecoration(
//                       color: context.surfaceContainer,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: AppText(
//                       text: item.statusText,
//                       fontSize: 13,
//                       fontWeight: 500,
//                       color: context.textPrimary,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Container(
//                   width: 44,
//                   height: 44,
//                   decoration: BoxDecoration(
//                     color: context.surfaceContainer,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(
//                     Icons.open_in_new_rounded,
//                     size: 20,
//                     color: context.textPrimary,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
