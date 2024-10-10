import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker_app/controllers/split_payment_controller.dart';
import 'package:flutter_expense_tracker_app/controllers/home_controller.dart';
import 'package:get/get.dart';

class UpdateSplitPaymentScreen extends StatefulWidget {
  final SplitPayment payment;

  UpdateSplitPaymentScreen({Key? key, required this.payment}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _UpdateSplitPaymentScreenState createState() =>
      _UpdateSplitPaymentScreenState();
}

class _UpdateSplitPaymentScreenState extends State<UpdateSplitPaymentScreen> {
  final SplitPaymentController _splitPaymentController = Get.find();
  final HomeController _homeController = Get.find();
  late List<bool> isPaidStates;

  @override
  void initState() {
    super.initState();

    isPaidStates = List.from(widget.payment.isPaid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Split Payment'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              await _splitPaymentController
                  .deleteSplitPayment(widget.payment.id);
              Get.back();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.payment.description,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: widget.payment.paidBy.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.payment.paidBy[index],
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${_homeController.selectedCurrency.symbol}${widget.payment.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Checkbox(
                          value: isPaidStates[index],
                          onChanged: (bool? value) async {
                            if (value != null) {
                              setState(() {
                                isPaidStates[index] = value;
                              });

                              var updatedPayment = SplitPayment(
                                id: widget.payment.id,
                                description: widget.payment.description,
                                paidBy: widget.payment.paidBy,
                                amount: widget.payment.amount,
                                isPaid: isPaidStates,
                              );

                              await _splitPaymentController
                                  .updateSplitPayment(updatedPayment);

                              Get.snackbar(
                                'Payment Updated',
                                '${widget.payment.paidBy[index]} payment status updated to ${isPaidStates[index] ? 'Paid' : 'Not Paid'}',
                                snackPosition: SnackPosition.BOTTOM,
                                duration: Duration(seconds: 2),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
