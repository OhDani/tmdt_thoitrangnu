// lib/modules/user/screens/home_page.dart

import 'package:fe/modules/user/providers/notification_provider.dart';
import 'package:fe/modules/user/screens/notifications_page.dart';
import 'package:fe/modules/user/screens/product_detail_page.dart.dart';
import 'package:fe/modules/user/widgets/home/product_grid.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_color.dart';
import '../constants/app_text_styles.dart';
import '../providers/home_provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/cart_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/home/home_app_bar.dart';
import '../widgets/home/featured_product_card.dart';
import '../widgets/home/category_chips.dart';
import 'cart_page.dart';
import 'image_search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      context.read<WishlistProvider>().fetchWishlist();
      context.read<CartProvider>().fetchCart();
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final provider = context.read<HomeProvider>();
    await provider.refresh();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final authProvider = context.watch<AuthProvider>();
    final userName = authProvider.user?.name ?? 'Khách';
    final avatarUrl = authProvider.user?.avatar;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<HomeProvider>(
          builder: (context, provider, _) {
            return RefreshIndicator(
              onRefresh: () async {
                await _loadData();
                await context.read<CartProvider>().fetchCart();
                await context.read<NotificationProvider>().fetchNotifications();
              },
              color: AppColors.primary,
              child: CustomScrollView(
                slivers: [
                  // SỬA: Custom App Bar với CartProvider
                  SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Expanded(
                          child: Consumer<CartProvider>(
                            builder: (context, cartProvider, _) {
                              return Consumer<NotificationProvider>(
                                builder: (context, notificationProvider, _) {
                                  return HomeAppBar(
                                    userName: userName,
                                    avatarUrl: avatarUrl,
                                    cartCount: cartProvider.itemCount,
                                    notificationCount:
                                        notificationProvider.unreadCount,
                                    onCartTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const CartPage(),
                                        ),
                                      );
                                    },
                                    onNotificationTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const NotificationsPage(),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: _buildSearchBar(provider),
                    ),
                  ),

                  // Featured Section
                  if (!provider.isLoading &&
                      provider.featuredProducts.isNotEmpty)
                    _buildFeaturedSection(provider),

                  // Categories
                  if (provider.categories.isNotEmpty)
                    _buildCategoriesSection(provider),

                  // Products Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                provider.selectedCategorySlug != null
                                    ? 'Sản phẩm lọc'
                                    : 'Tất cả sản phẩm',
                                style: AppTextStyles.h2,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${provider.products.length} sản phẩm',
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                          if (provider.selectedCategorySlug != null ||
                              provider.searchQuery.isNotEmpty)
                            TextButton.icon(
                              onPressed: () {
                                provider.clearFilters();
                                _searchController.clear();
                              },
                              icon: const Icon(
                                Icons.clear,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              label: const Text(
                                'Xóa bộ lọc',
                                style: TextStyle(color: AppColors.primary),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Products Grid
                  if (provider.isLoading)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  else if (provider.error != null)
                    _buildErrorState(provider)
                  else if (provider.products.isEmpty)
                    _buildEmptyState()
                  else
                    _buildProductsGrid(provider),

                  // Bottom Padding
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar(HomeProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.textHint, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: provider.search,
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm sản phẩm...',
                hintStyle: TextStyle(color: AppColors.textHint),
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 15),
            ),
          ),
          // Nút tìm kiếm bằng hình ảnh AI
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ImageSearchPage(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.camera_enhance_outlined,
                color: AppColors.primary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection(HomeProvider provider) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Text('✨ Sản phẩm nổi bật', style: AppTextStyles.h2),
          ),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: provider.featuredProducts.length,
              itemBuilder: (context, index) {
                final product = provider.featuredProducts[index];
                return FeaturedProductCard(
                  product: product,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductDetailPage(product: product),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(HomeProvider provider) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Text('Danh mục', style: AppTextStyles.h2),
          ),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: provider.categories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CategoryChip(
                      label: 'Tất cả',
                      isSelected: provider.selectedCategorySlug == null,
                      onTap: () => provider.filterByCategory(null),
                    ),
                  );
                }

                final category = provider.categories[index - 1];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CategoryChip(
                    label: category.name,
                    isSelected: provider.selectedCategorySlug == category.slug,
                    onTap: () => provider.filterByCategory(category.slug),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid(HomeProvider provider) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final product = provider.products[index];
          return ProductCard(
            product: product,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailPage(product: product),
                ),
              );
            },
          );
        }, childCount: provider.products.length),
      ),
    );
  }

  Widget _buildErrorState(HomeProvider provider) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            const Text('Có lỗi xảy ra', style: AppTextStyles.h2),
            const SizedBox(height: 8),
            Text(
              provider.error!,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 80,
              color: AppColors.textHint.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy sản phẩm',
              style: AppTextStyles.h2.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Thử tìm kiếm với từ khóa khác',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
