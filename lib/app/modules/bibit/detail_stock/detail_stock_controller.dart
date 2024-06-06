import 'package:ex_kit/ex.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../helpers/helper_misc.dart';
import '../../../models/bibit_product_detail_allocation_entity.dart';
import '../../../models/stockbit_chart_entity.dart';
import '../../../models/stockbit_news_entity.dart';
import '../../../models/stockbit_portpolio_entity.dart';
import '../../../models/stockbit_product_detail_entity.dart';
import '../../../models/stockbit_related_entity.dart';
import '../../../repository/repo_bibit.dart';
import '../../../repository/repo_stockbit.dart';
import '../../../routes/app_pages.dart';

class DetailStockController extends GetxController with StateMixin<StockbitProductDetailData> {
  final repoBibit = Get.find<BibitRepository>();
  final repoStockbit = Get.find<StockbitRepository>();

  final symbolSelected = ''.obs;
  final periodSelected = '1d'.obs;
  final menuSelected = 'Summaries'.obs;
  final uiModeSelected = 'CHART'.obs;

  final isFavorite = false.obs;

  /// data
  final productDetail = StockbitProductDetailData().obs;
  final chart = StockbitChartData().obs;
  final portpolio = StockbitPortpolioData().obs;
  final allocation = BibitProductDetailAllocationData().obs;
  final related = <StockbitRelatedData>[].obs;
  final news = <StockbitNewsData>[].obs;

  @override
  Future<void> onInit() async {
    change(null, status: RxStatus.loading());
    symbolSelected.value = Get.arguments as String;
    isFavorite.value = await repoStockbit.getIsFavorite(symbolSelected.value);
    productDetail.value = await repoStockbit.getProductDetail(symbolSelected.value);
    chart.value = await repoStockbit.getChart(symbol: symbolSelected.value, period: periodSelected.value);
    news.value = await repoStockbit.getNews(symbolSelected.value);
    related.value = await repoStockbit.getRelated(symbolSelected.value);
    change(productDetail.value, status: RxStatus.success());

    try {
      portpolio.value = await repoStockbit.getPortpolio(symbolSelected.value);
      allocation.value = await repoBibit.getProductDetailAllocations(symbolSelected.value);
    } catch (_) {
      logW('Portofolio tidak dapat ditemukan');
    }
    change(productDetail.value, status: RxStatus.success());

    super.onInit();
  }

  Future<void> onRefresh(String symbol) async {
    change(null, status: RxStatus.loading());
    isFavorite.value = await repoStockbit.getIsFavorite(symbol);
    productDetail.value = await repoStockbit.getProductDetail(symbol);
    chart.value = await repoStockbit.getChart(symbol: symbol, period: periodSelected.value);
    news.value = await repoStockbit.getNews(symbol);
    related.value = await repoStockbit.getRelated(symbol);
    change(productDetail.value, status: RxStatus.success());

    try {
      portpolio.value = await repoStockbit.getPortpolio(symbol);
      allocation.value = await repoBibit.getProductDetailAllocations(symbol);
    } catch (_) {
      logW('Portofolio tidak dapat ditemukan');
    }
    change(productDetail.value, status: RxStatus.success());
  }

  void onMenuChange(String item) {
    menuSelected.value = item;
    closeDrawer();
  }

  Future<void> openFile(String url) async {
    try {
      await launchUrlString(url);
    } catch (e) {
      ExSnackbar.danger('doesnt support OS');
    }
  }

  Future<void> onPeriodChange(String period) async {
    periodSelected.value = period;
    chart.value = await repoStockbit.getChart(symbol: symbolSelected.value, period: period);
    update();
  }

  void goDetailStock(String symbol) {
    Get.toNamed(Routes.DETAIL_STOCK, arguments: symbol, preventDuplicates: false);
  }
}
