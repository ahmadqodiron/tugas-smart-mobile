import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../providers/cart_provider.dart';
import '../utils/constants.dart';
import 'main_navigation.dart';
enum SortOption { newest, priceLow, priceHigh, popularity, rating }
enum ViewMode { grid, list }

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with TickerProviderStateMixin {
  List<Product> _allFavorites = [];
  List<Product> _filteredFavorites = [];
  bool _isLoading = true;
  SortOption _sortOption = SortOption.newest;
  ViewMode _viewMode = ViewMode.grid;
  String _searchQuery = '';
  String? _selectedCategory;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _loadFavorites();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    try {
      final favorites = await ApiService().getFavorites();
      setState(() {
        _allFavorites = favorites;
        _applyFiltersAndSort();
      });
    } catch (e) {
      setState(() => _allFavorites = []);
    }
    setState(() => _isLoading = false);
    _fadeController.forward();
  }

  void _applyFiltersAndSort() {
    List<Product> filtered = List.from(_allFavorites);

    // Apply search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) =>
        product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        product.description.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Apply category filter
    if (_selectedCategory != null) {
      filtered = filtered.where((product) => product.categoryName == _selectedCategory).toList();
    }

    // Apply sorting
    switch (_sortOption) {
      case SortOption.priceLow:
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHigh:
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.popularity:
        // Assuming popularity field, for now sort by id
        filtered.sort((a, b) => b.id.compareTo(a.id));
        break;
      case SortOption.rating:
        // Assuming rating field, for now sort by id
        filtered.sort((a, b) => b.id.compareTo(a.id));
        break;
      case SortOption.newest:
        filtered.sort((a, b) => b.id.compareTo(a.id));
        break;
    }

    setState(() => _filteredFavorites = filtered);
  }

  Future<void> _removeFromFavorites(int productId) async {
    try {
      await ApiService().removeFromFavorites(productId);
      setState(() {
        _allFavorites.removeWhere((product) => product.id == productId);
        _applyFiltersAndSort();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from favorites')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to remove from favorites')),
        );
      }
    }
  }

  Future<void> _addToCart(Product product) async {
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
  }

  void _showFilterSortDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FilterSortBottomSheet(
        currentSort: _sortOption,
        onSortChanged: (sort) {
          setState(() => _sortOption = sort);
          _applyFiltersAndSort();
        },
        selectedCategory: _selectedCategory,
        onCategoryChanged: (category) {
          setState(() => _selectedCategory = category);
          _applyFiltersAndSort();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) => Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
          child: Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredFavorites.isEmpty && _searchQuery.isEmpty
                        ? _buildEmptyState()
                        : _buildFavoritesView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.white,
      shadowColor: AppColors.shadowColor,
      title: const Text(
        'Your Favorites',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.black,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => setState(() => _viewMode = _viewMode == ViewMode.grid ? ViewMode.list : ViewMode.grid),
          icon: Icon(
            _viewMode == ViewMode.grid ? Icons.view_list : Icons.grid_view,
            color: AppColors.primary,
          ),
        ),
        IconButton(
          onPressed: _showFilterSortDialog,
          icon: const Icon(Icons.filter_list, color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.softGray,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) {
          setState(() => _searchQuery = value);
          _applyFiltersAndSort();
        },
        decoration: InputDecoration(
          hintText: 'Search favorites...',
          prefixIcon: const Icon(Icons.search, color: AppColors.navUnselected),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primary.withValues(alpha: 0.1), AppColors.secondary.withValues(alpha: 0.1)],
              ),
            ),
            child: Icon(
              Icons.favorite_border,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Favorites Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Save items you love for quick access',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.premiumGray,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          AnimatedScale(
            scale: 1.0,
            duration: const Duration(milliseconds: 200),
            child: ElevatedButton(
              onPressed: () {
                MainNavigation.of(context)?.setIndex(0);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: AppColors.primary.withValues(alpha: 0.3),
              ),
              child: const Text(
                'Browse Products',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesView() {
    if (_viewMode == ViewMode.grid) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _filteredFavorites.length,
        itemBuilder: (context, index) => _buildProductCard(_filteredFavorites[index]),
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredFavorites.length,
        itemBuilder: (context, index) => _buildProductListItem(_filteredFavorites[index]),
      );
    }
  }

  Widget _buildProductCard(Product product) {
    return Dismissible(
      key: Key('favorite_${product.id}'),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add_shopping_cart, color: AppColors.white),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: AppColors.white),
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          _removeFromFavorites(product.id);
        } else {
          _addToCart(product);
        }
      },
      child: Hero(
        tag: 'product_${product.id}',
        child: Card(
          elevation: 8,
          shadowColor: AppColors.shadowColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: CachedNetworkImage(
                        imageUrl: product.image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        onPressed: () => _removeFromFavorites(product.id),
                        icon: const Icon(
                          Icons.favorite,
                          color: AppColors.primary,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.white.withValues(alpha: 0.9),
                          shape: const CircleBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _addToCart(product),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text(
                          'Add to Cart',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductListItem(Product product) {
    return Dismissible(
      key: Key('favorite_list_${product.id}'),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add_shopping_cart, color: AppColors.white),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: AppColors.white),
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          _removeFromFavorites(product.id);
        } else {
          _addToCart(product);
        }
      },
      child: Hero(
        tag: 'product_list_${product.id}',
        child: Card(
          elevation: 4,
          shadowColor: AppColors.shadowColor,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: product.image,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: AppColors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      onPressed: () => _removeFromFavorites(product.id),
                      icon: const Icon(
                        Icons.favorite,
                        color: AppColors.primary,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _addToCart(product),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      child: const Text(
                        'Add',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterSortBottomSheet extends StatelessWidget {
  final SortOption currentSort;
  final Function(SortOption) onSortChanged;
  final String? selectedCategory;
  final Function(String?) onCategoryChanged;

  const _FilterSortBottomSheet({
    required this.currentSort,
    required this.onSortChanged,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sort By',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: SortOption.values.map((option) {
              return ChoiceChip(
                label: Text(_getSortLabel(option)),
                selected: currentSort == option,
                onSelected: (selected) {
                  if (selected) onSortChanged(option);
                },
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                checkmarkColor: AppColors.primary,
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Text(
            'Category',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: ['All', 'Electronics', 'Clothing', 'Books', 'Home'].map((category) {
              final isSelected = (category == 'All' && selectedCategory == null) ||
                                selectedCategory == category;
              return ChoiceChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  onCategoryChanged(selected ? (category == 'All' ? null : category) : null);
                },
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                checkmarkColor: AppColors.primary,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _getSortLabel(SortOption option) {
    switch (option) {
      case SortOption.newest:
        return 'Newest';
      case SortOption.priceLow:
        return 'Price: Low to High';
      case SortOption.priceHigh:
        return 'Price: High to Low';
      case SortOption.popularity:
        return 'Popularity';
      case SortOption.rating:
        return 'Rating';
    }
  }
}