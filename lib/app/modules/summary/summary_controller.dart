import 'package:get/get.dart';
import 'package:ex/ex.dart';

import '../../models/category_entity.dart';
import '../../routes/app_pages.dart';
import 'summary_repository.dart';

class SummaryController extends GetxController with StateMixin {
  // repo
  final repo = Get.find<SummaryRepository>();

  // calander
  final yearSelected = DateTime.now().toStringEx(format: 'yyyy').obs;
  final monthList = <String>['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'].obs;
  final monthSelected = DateTime.now().toStringEx(format: 'MMMM').obs;

  // category
  final category = <CategoryEntity>[].obs;

  // count
  final count1Month = 0.obs;
  final count1Year = 0.obs;
  final countByCategory = <dynamic>[].obs;

  // flag
  final isShowAllYear = false.obs;

  @override
  Future<void> onInit() async {
    await getCategory();

    await onMonthChange(monthSelected.value);
    await getCount1Year(year: yearSelected.value);
    super.onInit();
  }

  Future<void> onMonthChange(String month) async {
    change(0, status: RxStatus.loading());
    monthSelected.value = month;
    isShowAllYear.value = false;
    getCount1Month(year: yearSelected.value, month: month);
    Get.forceAppUpdate();

    ///
    countByCategory.clear();
    for (var element in category) {
      countByCategory.add({
        'month': month,
        'name': element.name ?? '',
        'total': await repo.getByCategory('${element.name}', '${yearSelected.value}-${month.reformatDate(from: 'MMMM', to: 'MM')}'),
      });
    }
    change(0, status: RxStatus.success());
  }

  Future<void> onShowAllYear() async {
    change(0, status: RxStatus.loading());
    count1Month.value = await repo.getCount1Year('${yearSelected.value}');
    monthSelected.value = '${yearSelected.value}';
    isShowAllYear.value = true;
    Get.forceAppUpdate();

    ///
    countByCategory.clear();
    for (var element in category) {
      countByCategory.add({
        'month': '~',
        'name': element.name ?? '',
        'total': await repo.getByCategory('${element.name}', '${yearSelected.value}'),
      });
    }
    change(0, status: RxStatus.success());
  }

  void onYearPrev() {
    yearSelected.value = (yearSelected.value.toInt()! - 1).toString();
    onMonthChange('Januari');
    getCount1Year(year: yearSelected.value);
  }

  void onYearNext() {
    yearSelected.value = (yearSelected.value.toInt()! + 1).toString();
    onMonthChange('Januari');
    getCount1Year(year: yearSelected.value);
  }

  Future<void> getCategory() async {
    category.value = await repo.getCategory();
  }

  Future<void> getCount1Month({String? year, String? month}) async {
    final monthReformat = month?.reformatDate(from: 'MMMM', to: 'MM');
    count1Month.value = await repo.getCount1Month('$year-$monthReformat');
  }

  Future<void> getCount1Year({required String year}) async {
    count1Year.value = await repo.getCount1Year('$year');
  }

  /// param: category, startDate, endDate
  void goAdvanceFilter(String categoryName) {
    if (isShowAllYear.isFalse) {
      Get.toNamed(Routes.FILTERING, arguments: [
        categoryName,
        '${yearSelected.value}-${monthSelected.value.reformatDate(from: 'MMMM', to: 'MM')}-01',
        '${yearSelected.value}-${monthSelected.value.reformatDate(from: 'MMMM', to: 'MM')}-31',
      ]);
    } else {
      Get.toNamed(Routes.FILTERING, arguments: [
        categoryName,
        '${yearSelected.value}-01-01',
        '${yearSelected.value}-12-31',
      ]);
    }
  }
}
