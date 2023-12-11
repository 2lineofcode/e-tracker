import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'detail_mutual_controller.dart';

class DetailMutualView extends GetView<DetailMutualController> {
  const DetailMutualView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DetailMutualView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'DetailMutualView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
