import 'package:flutter/cupertino.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, double? totalAmount, String? paymentMethod});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
