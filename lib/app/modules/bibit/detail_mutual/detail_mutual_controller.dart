import 'package:ex/ex.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../helpers/helper_misc.dart';
import '../../../models/bibit_product_detail_allocation_entity.dart';
import '../../../models/bibit_product_detail_aum_entity.dart';
import '../../../models/bibit_product_detail_chart_entity.dart';
import '../../../models/bibit_product_detail_dividend_entity.dart';
import '../../../models/bibit_product_detail_entity.dart';
import '../../../models/bibit_product_detail_factsheets_entity.dart';
import '../../../repository/repo_bibit.dart';
import '../../../routes/app_pages.dart';

class DetailMutualController extends GetxController with StateMixin<BibitProductDetailData> {
  final repo = Get.find<BibitRepository>();

  final symbolSelected = ''.obs;
  final periodSelected = '1Y'.obs;
  final menuSelected = 'Summaries'.obs;
  final uiModeSelected = 'CHART'.obs; // chart or aum

  final isFavorite = false.obs;

  /// data
  final productDetail = BibitProductDetailData().obs;
  final chart = BibitProductDetailChart().obs;
  final aum = BibitProductDetailAum().obs;
  final allocation = BibitProductDetailAllocationData().obs;
  final simulations = <num>[].obs;
  final factsheets = <BibitProductDetailFactsheetsData>[].obs;
  final prospectus = <BibitProductDetailFactsheetsData>[].obs;
  final dividends = <BibitProductDetailDividendData>[].obs;

  @override
  Future<void> onInit() async {
    symbolSelected.value = Get.arguments as String;
    isFavorite.value = await repo.getIsFavorite(symbolSelected.value);
    productDetail.value = await repo.getProductDetail(symbolSelected.value);
    chart.value = await repo.getProductDetailChart(symbolSelected.value, periodSelected.value);
    aum.value = await repo.getProductDetailAum(symbolSelected.value, periodSelected.value);
    allocation.value = await repo.getProductDetailAllocations(symbolSelected.value);
    simulations.value = await repo.getProductDetailSimulation(symbolSelected.value);
    factsheets.value = await repo.getProductDetailFactsheets(symbolSelected.value);
    prospectus.value = await repo.getProductDetailProspectus(symbolSelected.value);
    dividends.value = await repo.getProductDetailDividends(symbolSelected.value);
    change(productDetail.value, status: RxStatus.success());
    super.onInit();
  }

  Future<void> onPeriodChange(String period) async {
    periodSelected.value = period;
    chart.value = await repo.getProductDetailChart(symbolSelected.value, period);
    aum.value = await repo.getProductDetailAum(symbolSelected.value, period);
    update();
  }

  Future<void> onUiModeChange(String period) async {
    uiModeSelected.value = period;
    update();
  }

  void onMenuChange(String item) {
    menuSelected.value = item;
    closeDrawer();
  }

  void goDetailStock(String symbol) {
    Get.toNamed(Routes.DETAIL_STOCK, arguments: symbol);
  }

  Future<void> openFile(BibitProductDetailFactsheetsData item) async {
    try {
      await launchUrlString(item.file ?? '');
    } catch (e) {
      ExSnackbar.danger('doesnt support OS');
    }
  }
}
