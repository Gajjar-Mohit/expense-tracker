import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker_app/constants/colors.dart';
import 'package:flutter_expense_tracker_app/constants/theme.dart';
import 'package:flutter_expense_tracker_app/controllers/split_payment_controller.dart';
import 'package:flutter_expense_tracker_app/controllers/theme_controller.dart';
import 'package:flutter_expense_tracker_app/views/widgets/input_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CreateSplitPaymentScreen extends StatelessWidget {
  CreateSplitPaymentScreen({Key? key}) : super(key: key);

  final SplitPaymentController _splitPaymentController =
      Get.put(SplitPaymentController());

  final _themeController = Get.find<ThemeController>();

  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: _appBar(),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InputField(
                hint: 'Enter description',
                label: 'Description',
                controller: _descriptionController,
              ),
              InputField(
                hint: 'Enter total amount',
                label: 'Total Amount',
                controller: TextEditingController(
                    text: _splitPaymentController.totalAmount.value
                        .toStringAsFixed(2)),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    _splitPaymentController
                        .updateTotalAmount(double.parse(value));
                  } else {
                    _splitPaymentController.updateTotalAmount(0.0);
                  }
                },
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Text('Split equally'),
                  Obx(() => Switch(
                        value: _splitPaymentController.isEqualSplit.value,
                        onChanged: (value) {
                          _splitPaymentController.toggleSplitType(value);
                        },
                      )),
                ],
              ),
              SizedBox(height: 12.h),
              Text('Participants', style: Themes().labelStyle),
              SizedBox(height: 8.h),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _splitPaymentController.participants.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: InputField(
                          hint: 'Enter name',
                          label: 'Name',
                          controller: _splitPaymentController
                              .participants[index].nameController,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Obx(() => InputField(
                              hint: 'Enter amount',
                              label: 'Amount',
                              controller: _splitPaymentController
                                  .participants[index].amountController,
                              enabled:
                                  !_splitPaymentController.isEqualSplit.value,
                            )),
                      ),
                      IconButton(
                        onPressed: () =>
                            _splitPaymentController.removeParticipant(index),
                        icon: Icon(Icons.remove_circle, color: Colors.red),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 12.h),
              TextButton(
                onPressed: () => _splitPaymentController.addParticipant(),
                child: Text('Add Participant'),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          onPressed: () => _submitSplitPayment(),
          child: Icon(Icons.check),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
    });
  }

  _submitSplitPayment() {
    if (_splitPaymentController.totalAmount.value <= 0) {
      Get.snackbar(
        'Required',
        'Total amount is required',
        backgroundColor:
            Get.isDarkMode ? Color(0xFF212121) : Colors.grey.shade100,
        colorText: pinkClr,
      );
    } else {
      _splitPaymentController.submitSplitPayment(
        _descriptionController.text,
        _splitPaymentController.totalAmount.value,
      );
      Get.back();
    }
  }

  _appBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      title: Text(
        'Split Payment',
        style: TextStyle(color: _themeController.color),
      ),
      leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: _themeController.color)),
    );
  }
}
