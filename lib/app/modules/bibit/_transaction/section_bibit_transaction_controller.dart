import 'package:ex/ex.dart';
import 'package:get/get.dart';

import '../../../models/bibit_cart_entity.dart';
import '../../../models/bibit_history_mutual_entity.dart';
import '../../../models/bibit_history_stock_entity.dart';
import '../../../repository/repo_bibit.dart';

class SectionBibitTransactionController extends GetxController with StateMixin {
  final repo = Get.find<BibitRepository>();

  final selectedCategoryCode = 'mutual-fund'.obs;
  final selectedCategoryName = 'Reksa Dana'.obs;

  final pendingTax = 0.obs;
  final cart = BibitCartData().obs;

  /// history mutual
  final historyMutual = BibitHistoryMutual().obs;
  final historyListMutual = <BibitHistoryMutualDataTransactions>[].obs;
  final nextCursorMutual = ''.obs;

  /// history stock
  final historyStock = BibitHistoryStock().obs;
  final historyListStock = <BibitHistoryStockData>[].obs;
  final nextCursorStock = ''.obs;

  @override
  Future<void> onInit() async {
    change(null, status: RxStatus.loading());
    pendingTax.value = await repo.getBills();
    cart.value = await repo.getCart();
    historyMutual.value = await repo.getHistoryMutual();
    historyListMutual.value = historyMutual.value.data?.transactions ?? [];
    nextCursorMutual.value = historyMutual.value.meta?.cursor?.nextCursor ?? '';

    change(200, status: RxStatus.success());
    super.onInit();
  }

  Future<void> onRefresh() async {
    historyListMutual.clear();
  }

  Future<void> onLoadMore() async {
    if (nextCursorMutual.value.isEmpty) {
      logS('No more data');
      return;
    }
    await repo.getHistoryMutual(cursor: nextCursorMutual.value).then((newHistory) {
      nextCursorMutual.value = newHistory.meta?.cursor?.nextCursor ?? '';
      historyListMutual.addAll(newHistory.data?.transactions ?? []);
      historyListMutual.refresh();
      update();
    });
  }

  Future<void> onCategoryChanged(String s) async {
    selectedCategoryName.value = s;
    switch (s) {
      case 'Reksa Dana':
        selectedCategoryCode.value = 'mutual-fund';
        historyMutual.value = await repo.getHistoryMutual();
        break;
      case 'Saham':
        selectedCategoryCode.value = 'stocks';
        historyStock.value = await repo.getHistoryStock();
        historyListStock.value = historyStock.value.data!;
        break;
      case 'Obligasi':
        selectedCategoryCode.value = 'sbn';
        break;
      case 'Stable Earn':
        selectedCategoryCode.value = 'stable-earn';
        break;
      default:
    }
  }
}
