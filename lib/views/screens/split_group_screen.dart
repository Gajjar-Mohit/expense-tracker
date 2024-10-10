import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker_app/controllers/split_payment_controller.dart';
import 'package:flutter_expense_tracker_app/controllers/home_controller.dart';
import 'package:flutter_expense_tracker_app/views/screens/create_new_split_payment.dart';
import 'package:flutter_expense_tracker_app/views/screens/update_split_payment_screen.dart';
import 'package:get/get.dart';

class SplitGroupScreen extends StatefulWidget {
  @override
  State<SplitGroupScreen> createState() => _SplitGroupScreenState();
}

class _SplitGroupScreenState extends State<SplitGroupScreen> {
  final SplitPaymentController _splitPaymentController =
      Get.put(SplitPaymentController());

  final HomeController _homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Split Group'),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_payment',
        onPressed: () {
          Get.to(() => CreateSplitPaymentScreen());
        },
        child: Icon(Icons.add),
      ),
      body: Obx(() {
        return _splitPaymentController.payments.isEmpty
            ? Center(
                child: Text("No split groups"),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: _splitPaymentController.payments.length,
                itemBuilder: (context, index) {
                  final payment = _splitPaymentController.payments[index];
                  return ListTile(
                    leading: Icon(Icons.payment),
                    title: Text(payment.description),
                    subtitle: Text('Paid by: ${payment.paidBy.join(', ')}'),
                    trailing: Obx(() => Text(
                        '${_homeController.selectedCurrency.symbol}${payment.amount.toStringAsFixed(2)}')),
                    onTap: () {
                      Get.to(() => UpdateSplitPaymentScreen(payment: payment));
                    },
                  );
                },
              );
      }),
    );
  }
}
