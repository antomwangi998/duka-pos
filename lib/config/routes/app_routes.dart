import 'package:go_router/go_router.dart';
import '../../features/billing/presentation/pages/home_page.dart';
import '../../features/product/presentation/pages/product_list_page.dart';
import '../../features/product/presentation/pages/add_product_page.dart';
import '../../features/product/presentation/pages/edit_product_page.dart';
import '../../features/shop/presentation/pages/shop_details_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/billing/presentation/pages/scanner_page.dart';
import '../../features/billing/presentation/pages/checkout_page.dart';
import '../../features/product/domain/entities/product.dart';
import '../../features/sales/presentation/pages/sales_report_page.dart';
import '../../features/customer/domain/entities/customer.dart';
import '../../features/customer/presentation/pages/customers_list_page.dart';
import '../../features/customer/presentation/pages/add_customer_page.dart';
import '../../features/customer/presentation/pages/customer_detail_page.dart';
import '../../features/expense/presentation/pages/expense_list_page.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
          path: 'scanner',
          builder: (context, state) => const ScannerPage(),
        ),
        GoRoute(
          path: 'checkout',
          builder: (context, state) => const CheckoutPage(),
        ),
      ],
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/products',
      builder: (context, state) => const ProductListPage(),
      routes: [
        GoRoute(
          path: 'add',
          builder: (context, state) => const AddProductPage(),
        ),
        GoRoute(
          path: 'edit/:id',
          builder: (context, state) {
            final product = state.extra as Product?;
            if (product == null) {
              // If we land here without extra (e.g. deep link), go back to products for now.
              return const ProductListPage();
            }
            return EditProductPage(product: product);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/shop',
      builder: (context, state) => const ShopDetailsPage(),
    ),
    GoRoute(
      path: '/reports',
      builder: (context, state) => const SalesReportPage(),
    ),
    GoRoute(
      path: '/customers',
      builder: (context, state) => const CustomersListPage(),
      routes: [
        GoRoute(
          path: 'add',
          builder: (context, state) {
            final returnOnSave = state.extra == true;
            return AddCustomerPage(returnOnSave: returnOnSave);
          },
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final customer = state.extra as Customer?;
            if (customer == null) {
              // Deep link without extra data - fall back to the list.
              return const CustomersListPage();
            }
            return CustomerDetailPage(customer: customer);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/expenses',
      builder: (context, state) => const ExpenseListPage(),
    ),
  ],
);
