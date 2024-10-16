import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker_app/constants/categories.dart';
import 'package:flutter_expense_tracker_app/constants/colors.dart';
import 'package:flutter_expense_tracker_app/controllers/add_transaction_controller.dart';
import 'package:flutter_expense_tracker_app/controllers/theme_controller.dart';
import 'package:flutter_expense_tracker_app/models/transaction.dart';
import 'package:flutter_expense_tracker_app/providers/database_provider.dart';
import 'package:flutter_expense_tracker_app/views/widgets/input_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AddTransactionScreen extends StatelessWidget {
  AddTransactionScreen({Key? key}) : super(key: key);

  final AddTransactionController _addTransactionController =
      Get.put(AddTransactionController());

  final _themeController = Get.find<ThemeController>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  final List<String> _transactionTypes = ['Income', 'Expense'];

  final DateTime now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: _appBar(),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 8.h,
              ),
              InputField(
                hint: 'Enter transaction name',
                label: 'Transaction Name',
                controller: _nameController,
              ),
              InputField(
                hint: 'Enter transaction amount',
                label: 'Transaction Amount',
                controller: _amountController,
              ),
              Row(
                children: [
                  Expanded(
                    child: InputField(
                      hint: _addTransactionController.selectedDate.isNotEmpty
                          ? _addTransactionController.selectedDate
                          : DateFormat.yMd().format(now),
                      label: 'Date',
                      widget: IconButton(
                        onPressed: () => _getDateFromUser(context),
                        icon: Icon(
                          Icons.calendar_month_outlined,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 12.w,
                  ),
                  Expanded(
                    child: InputField(
                      hint: _addTransactionController.selectedTime.isNotEmpty
                          ? _addTransactionController.selectedTime
                          : DateFormat('hh:mm a').format(now),
                      label: 'Time',
                      widget: IconButton(
                        onPressed: () => _getTimeFromUser(context),
                        icon: Icon(
                          Icons.access_time_rounded,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              InputField(
                hint: _addTransactionController.selectedCategory.isNotEmpty
                    ? _addTransactionController.selectedCategory
                    : categories[0],
                label: 'Category',
                widget: IconButton(
                    onPressed: () => _showDialog(context, true),
                    icon: Icon(
                      Icons.keyboard_arrow_down_sharp,
                    )),
              ),
              InputField(
                hint: _addTransactionController.selectedMode.isNotEmpty
                    ? _addTransactionController.selectedMode
                    : cashModes[0],
                isAmount: true,
                label: 'Mode',
                widget: IconButton(
                    onPressed: () => _showDialog(context, false),
                    icon: Icon(
                      Icons.keyboard_arrow_down_sharp,
                    )),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          onPressed: () => _addTransaction(),
          child: Icon(
            Icons.add,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
    });
  }

  _addTransaction() async {
    if (_nameController.text.isEmpty || _amountController.text.isEmpty) {
      Get.snackbar(
        'Required',
        'All fields are requried',
        backgroundColor:
            Get.isDarkMode ? Color(0xFF212121) : Colors.grey.shade100,
        colorText: pinkClr,
      );
    } else {
      final TransactionModel transactionModel = TransactionModel(
        id: DateTime.now().toString(),
        type: _addTransactionController.transactionType.isNotEmpty
            ? _addTransactionController.transactionType
            : _transactionTypes[0],
        image: _addTransactionController.selectedImage,
        name: _nameController.text,
        amount: _amountController.text,
        date: _addTransactionController.selectedDate.isNotEmpty
            ? _addTransactionController.selectedDate
            : DateFormat.yMd().format(now),
        time: _addTransactionController.selectedTime.isNotEmpty
            ? _addTransactionController.selectedTime
            : DateFormat('hh:mm a').format(now),
        category: _addTransactionController.selectedCategory.isNotEmpty
            ? _addTransactionController.selectedCategory
            : categories[0],
        mode: _addTransactionController.selectedMode.isNotEmpty
            ? _addTransactionController.selectedMode
            : cashModes[0],
      );
      await DatabaseProvider.insertTransaction(transactionModel);
      Get.back();
    }
  }

  _showOptionsDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) => SimpleDialog(
              children: [
                SimpleDialogOption(
                  onPressed: () async {
                    final image = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                    );
                    if (image != null) {
                      _addTransactionController.updateSelectedImage(image.path);
                    }
                  },
                  child: Row(children: [
                    Icon(Icons.image),
                    Padding(
                      padding: EdgeInsets.all(7),
                      child: Text(
                        'Galley',
                        style: TextStyle(
                          fontSize: 20.sp,
                        ),
                      ),
                    )
                  ]),
                ),
                SimpleDialogOption(
                  onPressed: () async {
                    final image = await ImagePicker().pickImage(
                      source: ImageSource.camera,
                    );
                    if (image != null) {
                      _addTransactionController.updateSelectedImage(image.path);
                    }
                  },
                  child: Row(children: [
                    Icon(Icons.camera),
                    Padding(
                      padding: EdgeInsets.all(7),
                      child: Text(
                        'Camera',
                        style: TextStyle(
                          fontSize: 20.sp,
                        ),
                      ),
                    )
                  ]),
                ),
                SimpleDialogOption(
                  onPressed: () => Get.back(),
                  child: Row(children: [
                    Icon(Icons.cancel),
                    Padding(
                      padding: EdgeInsets.all(7),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 20.sp,
                        ),
                      ),
                    )
                  ]),
                ),
              ],
            ));
  }

  _showDialog(BuildContext context, bool isCategories) {
    Get.defaultDialog(
      title: isCategories ? 'Select Category' : 'Select Mode',
      content: SizedBox(
        width: MediaQuery.of(context).size.width * .7,
        height: isCategories
            ? MediaQuery.of(context).size.height * .4
            : MediaQuery.of(context).size.height * .12,
        child: ListView.builder(
          itemCount: isCategories ? categories.length : cashModes.length,
          itemBuilder: (context, i) {
            final data = isCategories ? categories[i] : cashModes[i];
            return ListTile(
              onTap: () {
                isCategories
                    ? _addTransactionController.updateSelectedCategory(data)
                    : _addTransactionController.updateSelectedMode(data);
                Get.back();
              },
              title: Text(data),
            );
          },
        ),
      ),
    );
  }

  _getTimeFromUser(
    BuildContext context,
  ) async {
    String? formatedTime;
    await showTimePicker(
      initialEntryMode: TimePickerEntryMode.input,
      context: context,
      initialTime: TimeOfDay(
        hour: DateTime.now().hour,
        minute: DateTime.now().minute,
      ),
    ).then((value) => formatedTime = value!.format(context));

    _addTransactionController.updateSelectedTime(formatedTime!);
  }

  _getDateFromUser(BuildContext context) async {
    DateTime? pickerDate = await showDatePicker(
        context: context,
        firstDate: DateTime(2012),
        initialDate: DateTime.now(),
        lastDate: DateTime(2122));

    if (pickerDate != null) {
      _addTransactionController
          .updateSelectedDate(DateFormat.yMd().format(pickerDate));
    }
  }

  _appBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      title: Text(
        'Add Transaction',
        style: TextStyle(color: _themeController.color),
      ),
      leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: _themeController.color)),
      actions: [
        Row(
          children: [
            Text(
              _addTransactionController.transactionType.isEmpty
                  ? _transactionTypes[0]
                  : _addTransactionController.transactionType,
              style: TextStyle(
                fontSize: 14.sp,
                color: _themeController.color,
              ),
            ),
            DropdownButton(
              items: _transactionTypes
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(
                        item,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                _addTransactionController
                    .changeTransactionType((val as String));
              },
            )

            // itemHeight: 30.h,
            // dropdownPadding: EdgeInsets.all(4),
            // dropdownWidth: 105.w,
          ],
        ),
      ],
    );
  }
}
