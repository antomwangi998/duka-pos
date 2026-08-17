import 'package:hive/hive.dart';
import '../../domain/entities/shop.dart';

part 'shop_model.g.dart';

@HiveType(typeId: 1)
class ShopModel extends Shop {
  @override
  @HiveField(0)
  final String name;
  @override
  @HiveField(1)
  final String addressLine1;
  @override
  @HiveField(2)
  final String addressLine2;
  @override
  @HiveField(3)
  final String phoneNumber;
  @override
  @HiveField(4)
  final String upiId;
  @override
  @HiveField(5)
  final String footerText;
  @override
  @HiveField(6)
  final String kraPin;
  @override
  @HiveField(7)
  final double vatRate;
  @override
  @HiveField(8)
  final int lowStockThreshold;

  const ShopModel({
    required this.name,
    required this.addressLine1,
    required this.addressLine2,
    required this.phoneNumber,
    required this.upiId,
    required this.footerText,
    this.kraPin = '',
    this.vatRate = 0.16,
    this.lowStockThreshold = 5,
  }) : super(
          name: name,
          addressLine1: addressLine1,
          addressLine2: addressLine2,
          phoneNumber: phoneNumber,
          upiId: upiId,
          footerText: footerText,
          kraPin: kraPin,
          vatRate: vatRate,
          lowStockThreshold: lowStockThreshold,
        );

  factory ShopModel.fromEntity(Shop shop) {
    return ShopModel(
      name: shop.name,
      addressLine1: shop.addressLine1,
      addressLine2: shop.addressLine2,
      phoneNumber: shop.phoneNumber,
      upiId: shop.upiId,
      footerText: shop.footerText,
      kraPin: shop.kraPin,
      vatRate: shop.vatRate,
      lowStockThreshold: shop.lowStockThreshold,
    );
  }

  Shop toEntity() => this;
}
