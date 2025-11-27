import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:card_swiper/card_swiper.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../providers/cart_provider.dart';
import '../utils/constants.dart';
import 'main_navigation.dart';
import 'product_detail_screen.dart';
import 'scan_screen.dart';
import 'add_product_screen.dart';
import 'transaction_history_screen.dart';
import 'category_products_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final products = await ApiService().getProducts();
      setState(() {
        _products = products;
      });
    } catch (e) {
      // Handle error
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 250, 85, 85),
              Color.fromARGB(255, 255, 212, 212),
              Color.fromARGB(255, 255, 255, 255),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    // Promo Banner
                     Container(
                       height: 120,
                       margin: const EdgeInsets.symmetric(horizontal: 16),
                       decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(16),
                         boxShadow: [
                           BoxShadow(
                             color: const Color(0xFF8B0000).withValues(alpha: 0.3),
                             blurRadius: 8,
                             offset: const Offset(0, 4),
                           ),
                         ],
                       ),
                       child: Stack(
                         children: [
                           // Nasi Goreng Image as background
                           ClipRRect(
                             borderRadius: BorderRadius.circular(16),
                             child: CachedNetworkImage(
                               imageUrl: 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=400',
                               fit: BoxFit.cover,
                               width: double.infinity,
                               height: double.infinity,
                               placeholder: (context, url) => Container(
                                 color: Colors.white.withValues(alpha: 0.8),
                                 child: const Center(
                                   child: CircularProgressIndicator(
                                     color: Color(0xFF8B0000),
                                     strokeWidth: 2,
                                   ),
                                 ),
                               ),
                               errorWidget: (context, url, error) => Container(
                                 color: Colors.white.withValues(alpha: 0.8),
                                 child: const Icon(
                                   Icons.restaurant,
                                   color: Color(0xFF8B0000),
                                   size: 40,
                                 ),
                               ),
                             ),
                           ),
                           // Overlay with dark background for text readability
                           Container(
                             decoration: BoxDecoration(
                               borderRadius: BorderRadius.circular(16),
                               gradient: LinearGradient(
                                 colors: [
                                   Colors.black.withValues(alpha: 0.5),
                                   Colors.transparent,
                                 ],
                                 begin: Alignment.bottomCenter,
                                 end: Alignment.topCenter,
                               ),
                             ),
                           ),
                           // Text Content
                           Center(
                             child: Text(
                               'Diskon 50%',
                               style: TextStyle(
                                 fontSize: 24,
                                 fontWeight: FontWeight.bold,
                                 color: Colors.white,
                                 shadows: [
                                   Shadow(
                                     blurRadius: 4,
                                     color: Colors.black.withValues(alpha: 0.5),
                                     offset: const Offset(0, 2),
                                   ),
                                 ],
                               ),
                             ),
                           ),
                         ],
                       ),
                     ),
                    const SizedBox(height: 20),
                    _buildQuickAccessButtons(),
                    const SizedBox(height: 20),
                     // Categories
                     Container(
                       margin: const EdgeInsets.symmetric(horizontal: 16),
                       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                       decoration: BoxDecoration(
                         gradient: const LinearGradient(
                           colors: [
                             Color(0xFF8B0000),
                             Color(0xFFB22222),
                           ],
                           begin: Alignment.centerLeft,
                           end: Alignment.centerRight,
                         ),
                         borderRadius: BorderRadius.circular(12),
                         boxShadow: [
                           BoxShadow(
                             color: const Color(0xFF8B0000).withValues(alpha: 0.3),
                             blurRadius: 8,
                             offset: const Offset(0, 4),
                           ),
                         ],
                       ),
                       child: const Center(
                         child: Text(
                           'Kategori Produk',
                           style: TextStyle(
                             fontSize: 18,
                             fontWeight: FontWeight.bold,
                             color: Colors.white,
                           ),
                         ),
                       ),
                     ),
                     const SizedBox(height: 16),
                     _buildCategoryGrid(),
                     const SizedBox(height: 20),
                     _buildFeaturedFoodSection(),
                     const SizedBox(height: 20),
                     _buildRecommendedProducts(),
                     const SizedBox(height: 20),
                     _buildCategoryProductCarousel(),
                     const SizedBox(height: 20),

                     // Products Grid
                     Container(
                       margin: const EdgeInsets.symmetric(horizontal: 16),
                       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                       decoration: BoxDecoration(
                         gradient: const LinearGradient(
                           colors: [
                             Color(0xFF8B0000),
                             Color(0xFFB22222),
                           ],
                           begin: Alignment.centerLeft,
                           end: Alignment.centerRight,
                         ),
                         borderRadius: BorderRadius.circular(12),
                         boxShadow: [
                           BoxShadow(
                             color: const Color(0xFF8B0000).withValues(alpha: 0.3),
                             blurRadius: 8,
                             offset: const Offset(0, 4),
                           ),
                         ],
                       ),
                       child: const Center(
                         child: Text(
                           'Semua Produk',
                           style: TextStyle(
                             fontSize: 18,
                             fontWeight: FontWeight.bold,
                             color: Colors.white,
                           ),
                         ),
                       ),
                     ),
                     const SizedBox(height: 16),
                     GridView.builder(
                       shrinkWrap: true,
                       physics: const NeverScrollableScrollPhysics(),
                       padding: const EdgeInsets.symmetric(horizontal: 16),
                       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                         crossAxisCount: 2,
                         childAspectRatio: 0.8,
                         crossAxisSpacing: 12,
                         mainAxisSpacing: 12,
                       ),
                       itemCount: _products.length,
                       itemBuilder: (context, index) {
                         final product = _products[index];
                         return GestureDetector(
                           onTap: () {
                             Navigator.push(
                               context,
                               MaterialPageRoute(
                                 builder: (_) => ProductDetailScreen(product: product),
                               ),
                             );
                           },
                           child: _buildProductCard(product),
                         );
                       },
                     ),
                     const SizedBox(height: 20),
                   ],
                 ),
               ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Kasir Pintar',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: AppColors.black),
            onPressed: () {
              MainNavigation.of(context)?.setIndex(2); // Cart index
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildQuickButton(Icons.qr_code_scanner, 'Scan Barcode', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScanScreen()),
            );
          }),
          _buildQuickButton(Icons.add, 'Tambah Produk', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddProductScreen()),
            );
          }),
          _buildQuickButton(Icons.history, 'Riwayat Transaksi', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TransactionHistoryScreen()),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuickButton(IconData icon, String label, VoidCallback onPressed) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.black,
            elevation: 2,
            shadowColor: AppColors.black.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = [
      {'name': 'Makanan', 'icon': Icons.restaurant},
      {'name': 'Minuman', 'icon': Icons.local_drink},
      {'name': 'paket', 'icon': Icons.shopping_basket},
      {'name': 'Lainnya', 'icon': Icons.category},
    ];

    return Container(
      height: 90,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((category) {
            return Container(
              width: 75,
              margin: const EdgeInsets.only(right: 12),
              child: _buildCategoryCard(category['name'] as String, category['icon'] as IconData),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String name, IconData icon) {
    // Map category names to IDs
    int getCategoryId(String categoryName) {
      switch (categoryName) {
        case 'Makanan':
          return 1;
        case 'Minuman':
          return 2;
        case 'Sembako':
          return 3;
        case 'Lainnya':
          return 4;
        default:
          return 0;
      }
    }

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF8F9FA),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          final categoryId = getCategoryId(name);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CategoryProductsScreen(
                categoryId: categoryId,
                categoryName: name,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getCategoryColor(name).withValues(alpha: 0.1),
                _getCategoryColor(name).withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getCategoryColor(name),
                      _getCategoryColor(name).withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _getCategoryColor(name).withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, size: 24, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3436),
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedFoodSection() {
    // Hardcoded 5 featured food products
    final foodProducts = _getFeaturedFoodProducts();

    if (foodProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF8B0000),
                Color(0xFFB22222),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B0000).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'Produk Terpopuler',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: foodProducts.length,
            itemBuilder: (context, index) {
              final product = foodProducts[index];
              return _buildFeaturedFoodCard(product);
            },
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String categoryName) {
    switch (categoryName) {
      case 'Makanan':
        return const Color(0xFF8B0000);
      case 'Minuman':
        return const Color(0xFFB22222);
      case 'Sembako':
        return const Color(0xFFDC143C);
      case 'Lainnya':
        return const Color(0xFFFF4500);
      default:
        return const Color(0xFF8B0000);
    }
  }

  List<Product> _getFeaturedFoodProducts() {
    return [
      Product(
        id: 1,
        name: 'Nasi Goreng Spesial',
        image: 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=400',
        price: 25000,
        description: 'Nasi goreng dengan telur, ayam, dan sayuran segar',
        categoryId: 1,
        categoryName: 'Makanan',
      ),
      Product(
        id: 2,
        name: 'Ayam Bakar Madu',
        image: 'https://images.unsplash.com/photo-1598103442097-8b74394b95c6?w=400',
        price: 35000,
        description: 'Ayam bakar dengan saus madu dan rempah-rempah',
        categoryId: 1,
        categoryName: 'Makanan',
      ),
      Product(
        id: 3,
        name: 'Es Teh Manis',
        image: 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=400',
        price: 5000,
        description: 'Es teh manis segar dengan lemon',
        categoryId: 2,
        categoryName: 'Minuman',
      ),
      Product(
        id: 4,
        name: 'Jus Jeruk',
        image: 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=400',
        price: 10000,
        description: 'Jus jeruk segar tanpa gula tambahan',
        categoryId: 2,
        categoryName: 'Minuman',
      ),
      Product(
        id: 5,
        name: 'Kopi Hitam',
        image: 'https://images.unsplash.com/photo-1497935586351-b67a49e012bf?w=400',
        price: 8000,
        description: 'Kopi hitam robusta premium',
        categoryId: 2,
        categoryName: 'Minuman',
      ),
    ];
  }

  Widget _buildFeaturedFoodCard(Product product) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 3,
        shadowColor: AppColors.shadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(product: product),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: CachedNetworkImage(
                    imageUrl: product.image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) => Container(
                      color: AppColors.softGray,
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.softGray,
                      child: const Icon(
                        Icons.image_not_supported,
                        color: AppColors.premiumGray,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${product.price.toInt()}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedProducts() {
    // Filter products for food (1), drinks (2), and groceries (3) categories
    final recommendedProducts = _products.where((product) {
      return product.categoryId == 1 || product.categoryId == 2 || product.categoryId == 3;
    }).toList();

    // If no recommended products, use all products
    final displayProducts = recommendedProducts.isNotEmpty ? recommendedProducts : _products;

    if (displayProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF8B0000),
                Color(0xFFB22222),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B0000).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'Rekomendasi Produk',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: Swiper(
            itemBuilder: (BuildContext context, int index) {
              final product = displayProducts[index];
              return _buildProductImageCard(product);
            },
            itemCount: displayProducts.length,
            autoplay: true,
            autoplayDelay: 3000,
            duration: 800,
            curve: Curves.fastOutSlowIn,
            viewportFraction: 0.4,
            scale: 0.9,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryProductCarousel() {
    // Show first 10 products as category carousel
    final categoryProducts = _products.take(10).toList();

    if (categoryProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF8B0000),
                Color(0xFFB22222),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B0000).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'Produk Populer',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: Swiper(
            itemBuilder: (BuildContext context, int index) {
              final product = categoryProducts[index];
              return _buildCategoryProductCard(product);
            },
            itemCount: categoryProducts.length,
            autoplay: false, // Manual scrolling for better UX
            duration: 600,
            curve: Curves.easeInOut,
            viewportFraction: 0.3,
            scale: 0.85,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: Card(
          elevation: 4,
          shadowColor: AppColors.shadowColor.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: product.image,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (context, url) => Container(
                color: AppColors.softGray,
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.softGray,
                child: const Icon(
                  Icons.image_not_supported,
                  color: AppColors.premiumGray,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildProductImageCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        width: 120,
        height: 120,
        margin: const EdgeInsets.only(right: 12),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: product.image,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.softGray,
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.softGray,
                child: const Icon(
                  Icons.image_not_supported,
                  color: AppColors.premiumGray,
                  size: 32,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildProductCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF8F9FA),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: CachedNetworkImage(
                  imageUrl: product.image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                    color: const Color(0xFFF8F9FA),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: const Color(0xFFF8F9FA),
                    child: const Icon(Icons.error, color: Color(0xFFADB5BD)),
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFFFFF),
                  Color(0xFFF8F9FA),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF2D3436),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF8B0000),
                        Color(0xFFB22222),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Rp ${product.price.toInt()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF8B0000),
                        Color(0xFFB22222),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B0000).withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await context.read<CartProvider>().addToCart(product, 1);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Added to cart')),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to add to cart')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Add to Cart',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}