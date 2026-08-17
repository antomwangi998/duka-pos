import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_bloc.dart';
import '../../../shop/presentation/bloc/shop_bloc.dart';

/// Shows a dismissable warning banner when any product stock falls
/// at or below the shop's configured lowStockThreshold.
class LowStockBanner extends StatefulWidget {
  const LowStockBanner({super.key});

  @override
  State<LowStockBanner> createState() => _LowStockBannerState();
}

class _LowStockBannerState extends State<LowStockBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    return BlocBuilder<ShopBloc, ShopState>(
      builder: (context, shopState) {
        final threshold = shopState is ShopLoaded
            ? shopState.shop.lowStockThreshold
            : 5;

        return BlocBuilder<ProductBloc, ProductState>(
          builder: (context, productState) {
            if (productState.status != ProductStatus.loaded) {
              return const SizedBox.shrink();
            }

            final lowItems = productState.products
                .where((p) => p.stock <= threshold)
                .toList();

            if (lowItems.isEmpty) return const SizedBox.shrink();

            final names = lowItems.take(3).map((p) => p.name).join(', ');
            final extra = lowItems.length > 3
                ? ' +${lowItems.length - 3} more'
                : '';

            return Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Low stock: $names$extra',
                      style: TextStyle(
                          fontSize: 12, color: Colors.orange.shade800),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    color: Colors.orange.shade600,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => setState(() => _dismissed = true),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
