import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'detail_crypto_controller.dart';

class DetailCryptoView extends GetView<DetailCryptoController> {
  const DetailCryptoView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DetailCryptoView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'DetailCryptoView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
