import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'detail_stock_controller.dart';

class DetailStockView extends GetView<DetailStockController> {
  const DetailStockView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DetailStockView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'DetailStockView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
