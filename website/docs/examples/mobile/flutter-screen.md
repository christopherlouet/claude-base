---
sidebar_position: 1
title: Flutter Screen
description: Flutter screen example with Clean Architecture
---

# Flutter Screen with Clean Architecture

This example shows how to create a professional Flutter screen with Clean Architecture and BLoC.

## Command used

```bash
/dev:dev-flutter "Create a product list screen with pagination"
```

## Generated structure

```
lib/features/products/
├── data/
│   ├── datasources/
│   │   └── product_remote_datasource.dart
│   ├── models/
│   │   └── product_model.dart
│   └── repositories/
│       └── product_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── product.dart
│   ├── repositories/
│   │   └── product_repository.dart
│   └── usecases/
│       └── get_products.dart
└── presentation/
    ├── bloc/
    │   ├── product_bloc.dart
    │   ├── product_event.dart
    │   └── product_state.dart
    ├── pages/
    │   └── product_list_page.dart
    └── widgets/
        ├── product_card.dart
        └── product_list.dart
```

## Screen code

### Domain Layer

#### `domain/entities/product.dart`

```dart
import 'package:equatable/equatable.dart';

/// Product entity - core of the business domain
class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool inStock;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.inStock,
  });

  @override
  List<Object?> get props => [id, name, description, price, imageUrl, category, inStock];
}
```

#### `domain/repositories/product_repository.dart`

```dart
import 'package:dartz/dartz.dart';
import '../entities/product.dart';
import '../../../../core/error/failures.dart';

/// Repository interface - defines the contract
abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts({
    required int page,
    required int limit,
    String? category,
    String? search,
  });

  Future<Either<Failure, Product>> getProductById(String id);
}
```

#### `domain/usecases/get_products.dart`

```dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class GetProducts implements UseCase<List<Product>, GetProductsParams> {
  final ProductRepository repository;

  GetProducts(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(GetProductsParams params) {
    return repository.getProducts(
      page: params.page,
      limit: params.limit,
      category: params.category,
      search: params.search,
    );
  }
}

class GetProductsParams extends Equatable {
  final int page;
  final int limit;
  final String? category;
  final String? search;

  const GetProductsParams({
    required this.page,
    this.limit = 20,
    this.category,
    this.search,
  });

  @override
  List<Object?> get props => [page, limit, category, search];
}
```

### Presentation Layer

#### `presentation/bloc/product_event.dart`

```dart
import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {
  final String? category;
  final String? search;

  const LoadProducts({this.category, this.search});

  @override
  List<Object?> get props => [category, search];
}

class LoadMoreProducts extends ProductEvent {
  const LoadMoreProducts();
}

class RefreshProducts extends ProductEvent {
  const RefreshProducts();
}

class SearchProducts extends ProductEvent {
  final String query;

  const SearchProducts(this.query);

  @override
  List<Object?> get props => [query];
}
```

#### `presentation/bloc/product_state.dart`

```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';

enum ProductStatus { initial, loading, success, failure, loadingMore }

class ProductState extends Equatable {
  final ProductStatus status;
  final List<Product> products;
  final bool hasReachedMax;
  final int currentPage;
  final String? errorMessage;
  final String? category;
  final String? search;

  const ProductState({
    this.status = ProductStatus.initial,
    this.products = const [],
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.errorMessage,
    this.category,
    this.search,
  });

  ProductState copyWith({
    ProductStatus? status,
    List<Product>? products,
    bool? hasReachedMax,
    int? currentPage,
    String? errorMessage,
    String? category,
    String? search,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: errorMessage,
      category: category ?? this.category,
      search: search ?? this.search,
    );
  }

  @override
  List<Object?> get props => [
        status,
        products,
        hasReachedMax,
        currentPage,
        errorMessage,
        category,
        search,
      ];
}
```

#### `presentation/bloc/product_bloc.dart`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_products.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProducts getProducts;

  static const int _pageSize = 20;

  ProductBloc({required this.getProducts}): super(const ProductState()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadMoreProducts>(_onLoadMoreProducts);
    on<RefreshProducts>(_onRefreshProducts);
    on<SearchProducts>(_onSearchProducts);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(
      status: ProductStatus.loading,
      category: event.category,
      search: event.search,
    ));

    final result = await getProducts(GetProductsParams(
      page: 1,
      limit: _pageSize,
      category: event.category,
      search: event.search,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: ProductStatus.failure,
        errorMessage: failure.message,
      )),
      (products) => emit(state.copyWith(
        status: ProductStatus.success,
        products: products,
        currentPage: 1,
        hasReachedMax: products.length < _pageSize,
      )),
    );
  }

  Future<void> _onLoadMoreProducts(
    LoadMoreProducts event,
    Emitter<ProductState> emit,
  ) async {
    if (state.hasReachedMax || state.status == ProductStatus.loadingMore) {
      return;
    }

    emit(state.copyWith(status: ProductStatus.loadingMore));

    final nextPage = state.currentPage + 1;
    final result = await getProducts(GetProductsParams(
      page: nextPage,
      limit: _pageSize,
      category: state.category,
      search: state.search,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: ProductStatus.failure,
        errorMessage: failure.message,
      )),
      (products) => emit(state.copyWith(
        status: ProductStatus.success,
        products: [...state.products, ...products],
        currentPage: nextPage,
        hasReachedMax: products.length < _pageSize,
      )),
    );
  }

  Future<void> _onRefreshProducts(
    RefreshProducts event,
    Emitter<ProductState> emit,
  ) async {
    add(LoadProducts(category: state.category, search: state.search));
  }

  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<ProductState> emit,
  ) async {
    add(LoadProducts(search: event.query.isEmpty ? null: event.query));
  }
}
```

#### `presentation/pages/product_list_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../widgets/product_card.dart';
import '../../../../core/di/injection.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProductBloc>()..add(const LoadProducts()),
      child: const ProductListView(),
    );
  }
}

class ProductListView extends StatefulWidget {
  const ProductListView({super.key});

  @override
  State<ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<ProductBloc>().add(const LoadMoreProducts());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                context.read<ProductBloc>().add(SearchProducts(value));
              },
            ),
          ),
        ),
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          switch (state.status) {
            case ProductStatus.initial:
            case ProductStatus.loading:
              return const Center(child: CircularProgressIndicator());

            case ProductStatus.failure:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.errorMessage ?? 'An error occurred',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProductBloc>().add(const RefreshProducts());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );

            case ProductStatus.success:
            case ProductStatus.loadingMore:
              if (state.products.isEmpty) {
                return const Center(
                  child: Text('No product found'),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ProductBloc>().add(const RefreshProducts());
                },
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: state.hasReachedMax
                      ? state.products.length
                      : state.products.length + 1,
                  itemBuilder: (context, index) {
                    if (index >= state.products.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ProductCard(product: state.products[index]),
                    );
                  },
                ),
              );
          }
        },
      ),
    );
  }
}
```

#### `presentation/widgets/product_card.dart`

```dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            SizedBox(
              width: 120,
              height: 120,
              child: CachedNetworkImage(
                imageUrl: product.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: theme.colorScheme.surfaceVariant,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: theme.colorScheme.surfaceVariant,
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category
                    Text(
                      product.category.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Name
                    Text(
                      product.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Price and stock
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${product.price.toStringAsFixed(2)} €',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _StockBadge(inStock: product.inStock),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  final bool inStock;

  const _StockBadge({required this.inStock});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: inStock ? Colors.green.shade50: Colors.red.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        inStock ? 'In stock': 'Out of stock',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: inStock ? Colors.green.shade700: Colors.red.shade700,
        ),
      ),
    );
  }
}
```

## Key points

| Aspect | Implementation |
|--------|----------------|
| **Clean Architecture** | Domain/Data/Presentation separation |
| **BLoC** | Reactive state management |
| **Pagination** | Infinite scroll with `LoadMoreProducts` |
| **Search** | Debounce in the TextField |
| **Refresh** | Native pull-to-refresh |
| **Images** | Cache with `cached_network_image` |

## Related commands

- `/dev:dev-tdd` - Generate widget and BLoC tests
- `/qa:qa-mobile` - Mobile quality audit
- `/dev:dev-supabase` - Supabase backend

---

:::tip Dependency injection
Use `get_it` for dependency injection:
```dart
// core/di/injection.dart
final getIt = GetIt.instance;

void configureDependencies() {
  getIt.registerFactory(() => ProductBloc(getProducts: getIt()));
  getIt.registerLazySingleton(() => GetProducts(getIt()));
}
```
:::
