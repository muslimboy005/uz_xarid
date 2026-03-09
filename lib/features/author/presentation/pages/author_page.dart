import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/core/widgets/app_image.dart';
import 'package:uz_xarid/core/widgets/product_card.dart';
import 'package:uz_xarid/core/widgets/shimmer_placeholders.dart';
import 'package:uz_xarid/features/author/domain/entities/author_entity.dart';
import 'package:uz_xarid/features/author/presentation/bloc/author/author_bloc.dart';
import 'package:uz_xarid/features/author/presentation/bloc/author/author_event.dart';
import 'package:uz_xarid/features/author/presentation/bloc/author/author_state.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';

class AuthorPage extends StatefulWidget {
  final int userId;
  const AuthorPage({super.key, required this.userId});

  @override
  State<AuthorPage> createState() => _AuthorPageState();
}

class _AuthorPageState extends State<AuthorPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<AuthorBloc>().add(AuthorLoadStarted(userId: widget.userId));

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<AuthorBloc>().add(AuthorLoadMore(userId: widget.userId));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          '',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.textPrimary,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: context.textPrimary),
      ),
      body: BlocBuilder<AuthorBloc, AuthorState>(
        builder: (context, state) {
          if (state is AuthorLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AuthorError) {
            return Center(
              child: Text(
                state.message,
                style: TextStyle(color: context.textPrimary),
              ),
            );
          } else if (state is AuthorLoaded) {
            final author = state.author;
            return NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: _buildAuthorHeader(context, author),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        controller: _tabController,
                        labelColor: Colors.white,
                        unselectedLabelColor: context.textSecondary,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorPadding: const EdgeInsets.all(4),
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.blue600,
                        ),
                        tabs: [
                          Tab(text: AppLocalizations.of(context)!.authorTabAds),
                          Tab(
                            text: AppLocalizations.of(context)!.authorTabAbout,
                          ),
                          Tab(
                            text: AppLocalizations.of(
                              context,
                            )!.authorTabContacts,
                          ),
                        ],
                      ),
                      Theme.of(context).scaffoldBackgroundColor,
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildAdsGrid(context, author, state.isFetchingMore),
                  Center(
                    child: Text(AppLocalizations.of(context)!.authorAboutEmpty),
                  ),
                  _buildContacts(context, author),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildAuthorHeader(BuildContext context, AuthorEntity author) {
    return Container(
      color: context.surfaceContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: ClipOval(
                  child: AppImage(path: author.avatar ?? '', fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author.fullName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: AppColors.orange, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          author.averageRatingAuthor.toStringAsFixed(2),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: context.textPrimary,
                              ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 14,
                          color: AppColors.blue600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${author.totalCommentsAuthor} ${AppLocalizations.of(context)!.reviewsLabel}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: context.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildIconButton(context, Icons.ios_share),
              _buildIconButton(context, Icons.camera_alt_outlined), // Inst
              _buildIconButton(context, Icons.facebook),
              _buildIconButton(context, Icons.telegram),
              _buildCallButton(context, author),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(BuildContext context, IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(child: Icon(icon, color: context.textPrimary, size: 24)),
    );
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchMaps(String address) async {
    final encoded = Uri.encodeComponent(address);
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encoded',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildCallButton(BuildContext context, AuthorEntity author) {
    return GestureDetector(
      onTap: () {
        if (author.phone != null && author.phone!.isNotEmpty) {
          _launchPhone(author.phone!);
        }
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.blue600,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(Icons.phone, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  Widget _buildAdsGrid(
    BuildContext context,
    AuthorEntity author,
    bool isFetchingMore,
  ) {
    if (author.ads.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.authorAdsEmpty,
          style: TextStyle(color: context.textSecondary),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.55,
      ),
      itemCount: author.ads.length + (isFetchingMore ? 2 : 0),
      itemBuilder: (context, index) {
        if (index >= author.ads.length) {
          return const ShimmerGridProductCard();
        }
        final item = author.ads[index];
        return ProductCard(
          slug: item.slug,
          title: item.title,
          mainImage: item.mainImage,
          price: item.price,
          finalPrice: item.finalPrice,
          currency: item.currency ?? 'uzs',
          rating: item.rating ?? 0,
          reviewCount: item.reviewCount ?? 0,
        );
      },
    );
  }

  Widget _buildContacts(BuildContext context, AuthorEntity author) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          AppLocalizations.of(context)!.authorContactsTitle,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          context,
          icon: Icons.phone,
          title: AppLocalizations.of(context)!.authorContactPhone,
          content: author.phone ?? AppLocalizations.of(context)!.authorAdsEmpty,
          actionText: AppLocalizations.of(context)!.authorActionCall,
          onTap: author.phone != null && author.phone!.isNotEmpty
              ? () => _launchPhone(author.phone!)
              : null,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          context,
          icon: Icons.access_time_filled,
          title: AppLocalizations.of(context)!.authorContactWorkTime,
          content: AppLocalizations.of(context)!.authorContactWorkTimeContent,
          actionText: AppLocalizations.of(context)!.authorActionCall,
          onTap: author.phone != null && author.phone!.isNotEmpty
              ? () => _launchPhone(author.phone!)
              : null,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          context,
          icon: Icons.location_on,
          title: AppLocalizations.of(context)!.authorContactAddress,
          content: AppLocalizations.of(context)!.authorContactAddressDefault,
          actionText: AppLocalizations.of(context)!.authorActionOpenMaps,
          onTap: () => _launchMaps(
            AppLocalizations.of(context)!.authorContactAddressDefault,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    required String actionText,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: AppColors.blue600, size: 20)]),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onTap,
            child: Row(
              children: [
                Text(
                  actionText,
                  style: TextStyle(
                    color: onTap != null
                        ? AppColors.orange
                        : context.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: onTap != null
                      ? AppColors.orange
                      : context.textSecondary,
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar, this.color);

  final TabBar _tabBar;
  final Color color;

  @override
  double get minExtent => _tabBar.preferredSize.height + 16;
  @override
  double get maxExtent => _tabBar.preferredSize.height + 16;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: _tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
