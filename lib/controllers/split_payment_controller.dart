import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker_app/providers/database_provider.dart';
import 'package:get/get.dart';

class SplitPayment {
  final String id;
  final String description;
  final List<String> paidBy;
  final List<bool> isPaid;
  final double amount;

  SplitPayment({
    required this.id,
    required this.description,
    required this.paidBy,
    required this.isPaid,
    required this.amount,
  });

  factory SplitPayment.fromMap(Map<String, dynamic> map) {
    return SplitPayment(
      id: map['id'] as String,
      description: map['description'] as String,
      paidBy:
          (map['paidBy'] is String) ? (map['paidBy'] as String).split(',') : [],
      isPaid: (map['isPaid'] is String)
          ? (map['isPaid'] as String).split(',').map((e) => e == '1').toList()
          : [],
      amount: (map['amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'paidBy': paidBy.join(','),
      'isPaid': isPaid.map((e) => e ? '1' : '0').join(','),
      'amount': amount,
    };
  }
}

class Participant {
  String name;
  TextEditingController nameController;
  TextEditingController amountController;

  Participant({
    required this.name,
    required this.nameController,
    required this.amountController,
  });
}

class SplitPaymentController extends GetxController {
  SplitPaymentController() {
    retrieveSplitPayments();
  }
  var participants = <Participant>[].obs;
  var isEqualSplit = false.obs;
  var totalAmount = 0.0.obs;
  var payments = <SplitPayment>[].obs;
  void toggleSplitType(bool value) {
    isEqualSplit.value = value;
    if (isEqualSplit.value) {
      _updateEqualAmounts();
    } else {
      for (var participant in participants) {
        participant.amountController.text = '';
      }
    }
  }

  void addParticipant() {
    participants.add(Participant(
      name: '',
      nameController: TextEditingController(),
      amountController: TextEditingController(),
    ));
    if (isEqualSplit.value) {
      _updateEqualAmounts();
    }
  }

  void removeParticipant(int index) {
    participants.removeAt(index);
    if (isEqualSplit.value) {
      _updateEqualAmounts();
    }
  }

  void updateTotalAmount(double amount) {
    totalAmount.value = amount;
    if (isEqualSplit.value) {
      _updateEqualAmounts();
    }
  }

  void _updateEqualAmounts() {
    if (participants.isEmpty || totalAmount.value == 0) return;

    double equalShare = totalAmount.value / participants.length;

    for (var participant in participants) {
      participant.amountController.text = equalShare.toStringAsFixed(2);
    }
  }

  Future<void> submitSplitPayment(String description, double total) async {
    if (isEqualSplit.value) {
      double amountPerParticipant = total / participants.length;
      for (var p in participants) {
        p.amountController.text = amountPerParticipant.toStringAsFixed(2);
      }
    } else {
      double totalEnteredAmount = participants.fold(0.0, (sum, p) {
        return sum + (double.tryParse(p.amountController.text) ?? 0.0);
      });

      if (totalEnteredAmount != total) {
        Get.snackbar(
          'Error',
          'The total amount entered does not match the total amount',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    var allParticipants =
        participants.map((p) => p.nameController.text).toList();

    var payment = SplitPayment(
      id: DateTime.now().toString(),
      description: description,
      paidBy: allParticipants,
      isPaid: List.filled(allParticipants.length, false),
      amount: total,
    );

    await DatabaseProvider.insertSplitPayment(payment);

    participants.clear();
    await retrieveSplitPayments();
  }

  Future<void> retrieveSplitPayments() async {
    payments.value = await DatabaseProvider.querySplitPayments();
  }

  Future<void> updateSplitPayment(SplitPayment updatedPayment) async {
    await DatabaseProvider.updateSplitPayment(updatedPayment);
    await retrieveSplitPayments();
  }

  Future<void> deleteSplitPayment(String id) async {
    await DatabaseProvider.deleteSplitPayment(id);
    await retrieveSplitPayments();
  }
}
