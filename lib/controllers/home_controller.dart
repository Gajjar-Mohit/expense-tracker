import 'package:flutter_expense_tracker_app/models/currency.dart';
import 'package:flutter_expense_tracker_app/models/transaction.dart';
import 'package:flutter_expense_tracker_app/providers/database_provider.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

class HomeController extends GetxController {
  final Rx<double> totalIncome = 0.0.obs;
  final Rx<double> totalExpense = 0.0.obs;
  final Rx<double> totalBalance = 0.0.obs;
  var cashBalance = 0.0.obs;
  var accountBalance = 0.0.obs;
  final Rx<double> _totalForSelectedDate = 0.0.obs;

  final Rx<Currency> _selectedCurrency =
      Currency(currency: 'INR', symbol: 'Rs').obs;
  final Rx<DateTime> _selectedDate = DateTime.now().obs;
  final Rx<List<TransactionModel>> _myTransactions =
      Rx<List<TransactionModel>>([]);
  final _box = GetStorage();

  List<TransactionModel> get myTransactions => _myTransactions.value;
  double get totalForSelectedDate => _totalForSelectedDate.value;
  DateTime get selectedDate => _selectedDate.value;
  Currency get selectedCurrency => _selectedCurrency.value;

  Currency get _loadCurrencyFromStorage {
    final result = _box.read('currency');
    if (result == null) {
      return Currency(currency: 'INR', symbol: 'Rs');
    }
    final Currency formatCurrency = Currency(
      currency: result.toString().split('|')[0],
      symbol: result.toString().split('|')[1],
    );

    return formatCurrency;
  }

  @override
  void onInit() {
    super.onInit();
    _selectedCurrency.value = _loadCurrencyFromStorage;
    getTransactions();
  }

  Future<void> updateSelectedCurrency(Currency currency) async {
    _selectedCurrency.value = currency;
    final String formatCurrency = '${currency.currency}|${currency.symbol}';
    await _box.write('currency', formatCurrency);
  }

  Future<void> getTransactions() async {
    final List<TransactionModel> transactionsFromDB = [];
    List<Map<String, dynamic>> transactions =
        await DatabaseProvider.queryTransaction();
    transactionsFromDB.assignAll(transactions.reversed
        .map((data) => TransactionModel().fromJson(data))
        .toList());
    _myTransactions.value = transactionsFromDB;
    getTotalAmountForPickedDate(transactionsFromDB);
    tracker(transactionsFromDB);
  }

  Future<int> deleteTransaction(String id) async {
    final deletedRows = await DatabaseProvider.deleteTransaction(id);
    if (deletedRows > 0) {
      getTransactions();
    }
    return deletedRows;
  }

  Future<int> updateTransaction(TransactionModel transactionModel) async {
    final updatedRows =
        await DatabaseProvider.updateTransaction(transactionModel);
    if (updatedRows > 0) {
      getTransactions();
    }
    return updatedRows;
  }

  void updateSelectedDate(DateTime date) {
    _selectedDate.value = date;
    getTransactions();
  }

  void getTotalAmountForPickedDate(List<TransactionModel> tm) {
    if (tm.isEmpty) {
      return;
    }
    double total = 0;
    for (TransactionModel transactionModel in tm) {
      if (transactionModel.date == DateFormat.yMd().format(selectedDate)) {
        if (transactionModel.type == 'Income') {
          total += double.parse(transactionModel.amount!);
        } else {
          total -= double.parse(transactionModel.amount!);
        }
      }
    }
    _totalForSelectedDate.value = total;
  }

  void tracker(List<TransactionModel> tm) {
    cashBalance.value = 0;
    accountBalance.value = 0;
    totalIncome.value = 0;
    totalExpense.value = 0;

    if (tm.isEmpty) {
      return;
    }

    double expense = 0;
    double income = 0;

    for (TransactionModel transactionModel in tm) {
      final double transactionAmount = double.parse(transactionModel.amount!);

      if (transactionModel.type == 'Income') {
        if (transactionModel.mode == 'Cash') {
          cashBalance.value += transactionAmount;
        } else if (transactionModel.mode == 'Account balance') {
          accountBalance.value += transactionAmount;
        }
        income += transactionAmount;
      } else {
        if (transactionModel.mode == 'Cash') {
          cashBalance.value -= transactionAmount;
        } else if (transactionModel.mode == 'Account') {
          accountBalance.value -= transactionAmount;
        }
        expense += transactionAmount;
      }
    }

    totalIncome.value = income;
    totalExpense.value = expense;
    totalBalance.value = totalIncome.value - totalExpense.value;
  }

  void resetBalances() {
    cashBalance.value = 0.0;
    accountBalance.value = 0.0;
  }
}
