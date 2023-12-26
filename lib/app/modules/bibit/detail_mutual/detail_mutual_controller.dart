import 'package:get/get.dart';

import '../../../models/bibit_product_detail_mutual_entity.dart';
import '../bibit_repository.dart';

class DetailMutualController extends GetxController {
  final repo = Get.find<BibitRepository>();

  final symbolSelected = ''.obs;
  final productDetail = BibitProductDetailMutualData().obs;

  @override
  Future<void> onInit() async {
    symbolSelected.value = Get.arguments as String;
    productDetail.value = await repo.getProductDetailMutual(symbolSelected.value);
    super.onInit();
  }
}
