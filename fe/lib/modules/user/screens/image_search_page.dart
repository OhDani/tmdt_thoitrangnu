// lib/modules/user/screens/image_search_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../constants/app_color.dart';
import '../constants/app_text_styles.dart';
import '../providers/image_search_provider.dart';
import '../widgets/home/product_grid.dart';
import 'product_detail_page.dart.dart';

class ImageSearchPage extends StatefulWidget {
  const ImageSearchPage({Key? key}) : super(key: key);

  @override
  State<ImageSearchPage> createState() => _ImageSearchPageState();
}

class _ImageSearchPageState extends State<ImageSearchPage>
    with SingleTickerProviderStateMixin {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    // Clear kết quả khi thoát trang
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) return;
      context.read<ImageSearchProvider>().clearResults();
    });
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (picked != null && mounted) {
        setState(() => _selectedImage = File(picked.path));
        context.read<ImageSearchProvider>().searchByImage(File(picked.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể chọn ảnh: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text('Chọn nguồn ảnh', style: AppTextStyles.h2),
              const SizedBox(height: 12),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      color: AppColors.primary),
                ),
                title: const Text('Chụp ảnh mới',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Chụp trang phục bạn muốn tìm kiếm'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library_rounded,
                      color: Colors.purple),
                ),
                title: const Text('Thư viện ảnh',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Chọn ảnh từ điện thoại'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Text(
              'Tìm kiếm bằng AI',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Consumer<ImageSearchProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ---- Hint banner ----
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.12),
                        AppColors.accent.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.tips_and_updates_outlined,
                          color: AppColors.primary, size: 22),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Chụp hoặc chọn ảnh trang phục, AI sẽ gợi ý sản phẩm tương tự từ cửa hàng',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ---- Vùng chọn ảnh ----
                GestureDetector(
                  onTap: _showImageSourceSheet,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _selectedImage == null ? _pulseAnimation.value : 1.0,
                        child: child,
                      );
                    },
                    child: Container(
                      height: 230,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _selectedImage != null
                              ? AppColors.primary
                              : AppColors.primary.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _selectedImage != null
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                                // Overlay khi đang loading
                                if (provider.isLoading)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: const Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 3,
                                          ),
                                          SizedBox(height: 12),
                                          Text(
                                            'AI đang phân tích...',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 72,
                                  color: AppColors.primary.withOpacity(0.5),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'Chạm để chọn ảnh',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Hỗ trợ: váy, áo, quần, đầm,...',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // ---- Nút chọn lại ----
                if (_selectedImage != null && !provider.isLoading)
                  OutlinedButton.icon(
                    onPressed: _showImageSourceSheet,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Chọn ảnh khác'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),

                // ---- Error ----
                if (provider.error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline,
                            color: AppColors.error, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            provider.error!,
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // ---- AI Analysis box ----
                if (provider.analysis != null && !provider.isLoading) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.1),
                          AppColors.primary.withOpacity(0.04),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.auto_awesome,
                                color: AppColors.primary, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Nhận xét của AI',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.analysis!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // ---- Kết quả sản phẩm ----
                if (provider.results.isNotEmpty && !provider.isLoading) ...[
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.style_outlined,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Gợi ý sản phẩm tương tự',
                        style: AppTextStyles.h2,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${provider.results.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: provider.results.length,
                    itemBuilder: (context, index) {
                      final product = provider.results[index];
                      return ProductCard(
                        product: product,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailPage(product: product),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],

                // ---- Empty results (sau khi search xong) ----
                if (!provider.isLoading &&
                    provider.error == null &&
                    provider.analysis != null &&
                    provider.results.isEmpty) ...[
                  const SizedBox(height: 32),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: AppColors.textHint.withOpacity(0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Chưa tìm thấy sản phẩm phù hợp',
                          style: AppTextStyles.h2
                              .copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Thử chụp ảnh rõ hơn hoặc chọn ảnh khác',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}
