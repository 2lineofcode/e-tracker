import 'package:get/get.dart';

import '../../../repository/repo_bibit.dart';
import 'detail_mutual_controller.dart';

class DetailMutualBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BibitRepository>(() => BibitRepository());
    Get.lazyPut<DetailMutualController>(() => DetailMutualController());
  }
}
