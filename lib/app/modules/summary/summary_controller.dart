import 'package:ex/ex.dart';
import 'package:get/get.dart';

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
  final countOnly1Month = 0.obs;
  final countOnly1Year = 0.obs;
  final countByCategory = <dynamic>[].obs;
  final countByMonth = <int>[].obs;

  // flag
  final isShowAllYear = false.obs;

  @override
  Future<void> onInit() async {
    await getCategory();

    await onMonthChange(monthSelected.value);
    await getCountOnly1Year(yearSelected.value);
    await getCountAllMonth(yearSelected.value);
    super.onInit();
  }

  Future<void> onMonthChange(String month) async {
    change(0, status: RxStatus.loading());
    monthSelected.value = month;
    isShowAllYear.value = false;
    await getCountOnly1Month(year: yearSelected.value, month: month);

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
    countOnly1Month.value = await repo.getCountOnly1Year('${yearSelected.value}');
    monthSelected.value = '${yearSelected.value}';
    isShowAllYear.value = true;

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

  Future<void> onYearPrev() async {
    yearSelected.value = (yearSelected.value.toInt()! - 1).toString();
    await onMonthChange('Januari');
    await getCountOnly1Year(yearSelected.value);
    await getCountAllMonth(yearSelected.value);
  }

  Future<void> onYearNext() async {
    yearSelected.value = (yearSelected.value.toInt()! + 1).toString();
    await onMonthChange('Januari');
    await getCountOnly1Year(yearSelected.value);
    await getCountAllMonth(yearSelected.value);
  }

  Future<void> getCategory() async {
    category.value = await repo.getCategory();
  }

  Future<void> getCountOnly1Month({String? year, String? month}) async {
    final monthReformat = month?.reformatDate(from: 'MMMM', to: 'MM');
    countOnly1Month.value = await repo.getCountOnly1Month('$year-$monthReformat');
  }

  Future<void> getCountAllMonth(String year) async {
    countByMonth.clear();
    for (var i = 0; i < 12; i++) {
      var x = i + 1;
      var m = x.toString().reformatDate(from: 'M', to: 'MM');
      var sum = await repo.getCountOnly1Month('$year-$m');
      countByMonth.add(sum);
    }
  }

  Future<void> getCountOnly1Year(String year) async {
    countOnly1Year.value = await repo.getCountOnly1Year('$year');
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
