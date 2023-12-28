import 'package:get/get.dart';

import '../../../models/bibit_allocation_summary_entity.dart';
import '../../../models/bibit_portpolio_entity.dart';
import '../../../repository/repo_bibit.dart';
import '../_home/section_bibit_home_controller.dart';

class SectionBibitPorfolioController extends GetxController with StateMixin<BibitAllocationSummaryData> {
  final repo = Get.find<BibitRepository>();
  final _home = Get.find<SectionBibitHomeController>();

  final summary = BibitAllocationSummaryData().obs;
  final portpolio = <BibitPortpolioDataResult>[].obs;

  @override
  Future<void> onInit() async {
    change(BibitAllocationSummaryData(), status: RxStatus.loading());
    summary.value = await repo.getAllocationSummary();
    portpolio.value = _home.portpolio.value.result ?? [];

    change(summary.value, status: RxStatus.success());

    portpolio.removeAt(0);
    portpolio.removeLast();

    super.onInit();
  }
}
