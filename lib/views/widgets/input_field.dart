import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker_app/constants/theme.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InputField extends StatelessWidget {
  final String label;
  final String hint;
  final bool? isAmount;
  final TextEditingController? controller;
  final Widget? widget;
  final TextInputType? keyboardType;
  final bool enabled; 
  final void Function(String)? onChanged; 

  InputField({
    Key? key,
    required this.hint,
    required this.label,
    this.isAmount = false,
    this.controller,
    this.widget,
    this.keyboardType,
    this.enabled = true, 
    this.onChanged, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 14.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Themes().labelStyle,
          ),
          Container(
            height: 48.h,
            margin: EdgeInsets.only(
              top: 6.h,
            ),
            padding: EdgeInsets.only(
              left: 14.w,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
                width: 1.w,
              ),
              borderRadius: BorderRadius.circular(
                10.r,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    keyboardType: keyboardType ??
                        (isAmount! ? TextInputType.number : TextInputType.text),
                    readOnly: widget == null ? false : true,
                    enabled: enabled, 
                    autofocus: false,
                    cursorColor: Get.isDarkMode
                        ? Colors.grey.shade100
                        : Colors.grey.shade700,
                    controller: controller,
                    style: Themes().labelStyle,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: hint,
                      hintStyle: Themes().labelStyle,
                    ),
                    onChanged: onChanged, 
                  ),
                ),
                widget == null
                    ? Container()
                    : Container(
                        child: widget,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
