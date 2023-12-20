import 'package:get/get.dart';

import '../../../models/bibit_performance_allocation_entity.dart';
import '../../../models/bibit_performance_chart_entity.dart';
import '../../../models/bibit_performance_entity.dart';
import '../bibit_repository.dart';

class SectionBibitPerformanceController extends GetxController with StateMixin<BibitPerformanceChartData> {
  final repo = Get.find<BibitRepository>();

  final performance = BibitPerformanceData().obs;
  final performanceChart = BibitPerformanceChartData().obs;
  final allocation = <BibitPerformanceAllocationData>[].obs;
  final periodSelected = '1D'.obs;

  @override
  Future<void> onInit() async {
    performance.value = await repo.getPerformance();
    performanceChart.value = await repo.getPerformancePeriod(periodSelected.value);
    allocation.value = await repo.getAllocation();
    change(performanceChart.value, status: RxStatus.success());

    super.onInit();
  }
}
