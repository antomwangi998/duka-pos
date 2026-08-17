import 'package:equatable/equatable.dart';

class Shop extends Equatable {
  final String name;
  final String addressLine1;
  final String addressLine2;
  final String phoneNumber;
  final String upiId;        // kept for compatibility; used as M-Pesa Till/Paybill
  final String footerText;
  final String kraPin;       // KRA PIN for VAT receipts
  final double vatRate;      // VAT rate as decimal e.g. 0.16 = 16%
  final int lowStockThreshold; // alert when stock <= this value

  const Shop({
    this.name = '',
    this.addressLine1 = '',
    this.addressLine2 = '',
    this.phoneNumber = '',
    this.upiId = '',
    this.footerText = '',
    this.kraPin = '',
    this.vatRate = 0.16,
    this.lowStockThreshold = 5,
  });

  Shop copyWith({
    String? name,
    String? addressLine1,
    String? addressLine2,
    String? phoneNumber,
    String? upiId,
    String? footerText,
    String? kraPin,
    double? vatRate,
    int? lowStockThreshold,
  }) {
    return Shop(
      name: name ?? this.name,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      upiId: upiId ?? this.upiId,
      footerText: footerText ?? this.footerText,
      kraPin: kraPin ?? this.kraPin,
      vatRate: vatRate ?? this.vatRate,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
    );
  }

  @override
  List<Object?> get props => [
        name, addressLine1, addressLine2, phoneNumber,
        upiId, footerText, kraPin, vatRate, lowStockThreshold,
      ];
}
