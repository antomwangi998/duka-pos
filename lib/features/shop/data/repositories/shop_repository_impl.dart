import 'package:fpdart/fpdart.dart';
import '../../../../core/data/hive_database.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/shop.dart';
import '../../domain/repositories/shop_repository.dart';
import '../models/shop_model.dart';

class ShopRepositoryImpl implements ShopRepository {
  static const String shopKey = 'shop_details';

  @override
  Future<Either<Failure, Shop>> getShop() async {
    try {
      final box = HiveDatabase.shopBox;
      final shop = box.get(shopKey);
      if (shop != null) {
        return Right(shop);
      } else {
        return const Right(Shop(
          name: 'Baba\'s Duka',
          addressLine1: 'Mama Ngina Street',
          addressLine2: 'Nairobi, Kenya',
          phoneNumber: '+254700000000',
          upiId: '123456', // M-Pesa Till number
          footerText: 'Asante! Karibu tena.',
          kraPin: 'P000000000A',
          vatRate: 0.16,
          lowStockThreshold: 5,
        ));
      }
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateShop(Shop shop) async {
    try {
      final box = HiveDatabase.shopBox;
      final model = ShopModel.fromEntity(shop);
      await box.put(shopKey, model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
