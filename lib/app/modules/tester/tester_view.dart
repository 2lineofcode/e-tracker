import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'tester_controller.dart';

class TesterView extends GetView<TesterController> {
  const TesterView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TesterView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'TesterView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
