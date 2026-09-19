import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:ex_kit/ex.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/app_color.dart';
import '../../helpers/helpers.dart';
import '../widgets/widgets.dart';
import 'tools_controller.dart';
import 'tools_extra.dart';

class ToolsView extends GetView<ToolsController> {
  const ToolsView({super.key});

  List<String> get toolTitles => ['Dana darurat', 'Dana pensiun', ...extraTools.map((tool) => tool.title)];

  @override
  Widget build(BuildContext context) {
    return MyLayout(
      appBarTitle: 'Tools'.text.size(15).bold.make(),
      appBarAction: TextButton.icon(
        onPressed: controller.resetInputs,
        icon: Icon(Icons.restart_alt, size: 18),
        label: Text('Reset semua'),
      ).pOnly(right: 12),
      sideMenuWidth: 220,
      sideMenuContent: ListView(
        children: [
          menuItem('Dana darurat', Icons.savings_outlined, 0),
          menuItem('Dana pensiun', Icons.beach_access_outlined, 1),
          for (var index = 0; index < extraTools.length; index++)
            menuItem(extraTools[index].title, Icons.calculate_outlined, index + 2),
        ],
      ).pOnly(top: 20).expand(),
      bodyContent: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth < 600 ? 12 : 24,
            vertical: 16,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 1080),
              child: Obx(() {
                final selectedTool = controller.selectedTool.value;
                return GetBuilder<ToolsController>(
                  builder: (_) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (context.isMobile) DropdownButtonFormField<int>(
                        key: ValueKey(selectedTool),
                        initialValue: selectedTool,
                        isExpanded: true,
                        decoration: HelperDecoration.input(label: 'Kalkulator'),
                        items: [
                          for (var index = 0; index < toolTitles.length; index++)
                            DropdownMenuItem(value: index, child: Text(toolTitles[index], style: TextStyle(fontSize: 12))),
                        ],
                        onChanged: (value) {
                          if (value != null) controller.selectedTool.value = value;
                        },
                      ).pOnly(bottom: 16),
                      if (selectedTool == 0) emergencyCalculator()
                      else if (selectedTool == 1) retirementCalculator()
                      else extraCalculator(extraTools[selectedTool - 2]),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
      footerContent: context.isMobile
          ? Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                tooltip: 'Kembali',
                onPressed: () => Get.back(),
                icon: Icon(Icons.arrow_back),
              ),
            )
          : SizedBox.shrink(),
    );
  }

  Widget menuItem(String title, IconData icon, int index) {
    return Builder(builder: (context) => Obx(() => Material(
      type: MaterialType.transparency,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        selected: controller.selectedTool.value == index,
        selectedTileColor: AppColor.sideMenuSelected,
        selectedColor: AppColor.textReverse,
        leading: Icon(icon, size: 18),
        title: title.text.size(12).make(),
        onTap: () {
          controller.selectedTool.value = index;
          if (Scaffold.of(context).isDrawerOpen) Scaffold.of(context).closeDrawer();
        },
    )).pSymmetric(h: 10).pOnly(bottom: 4)));
  }

  Widget emergencyCalculator() {
    final result = controller.emergencyResult;
    final form = Form(
      key: controller.emergencyForm,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          field('Pengeluaran pokok per bulan', controller.emergencyExpense, money: true),
          field('Target perlindungan', controller.coverageMonths, max: 120, unit: 'bulan'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [3, 6, 9, 12].map((months) => ChoiceChip(
              label: Text('$months bulan'),
              selected: controller.coverageMonths.text == '$months',
              onSelected: (_) {
                controller.coverageMonths.text = '$months';
                controller.clearResult(false);
              },
            )).toList(),
          ).pOnly(bottom: 20),
          field('Dana darurat saat ini', controller.emergencySaved, money: true, min: 0),
          field('Tabungan per bulan', controller.monthlySaving, money: true, min: 0, last: true),
          FilledButton.icon(
            onPressed: () => calculate(false),
            icon: Icon(Icons.calculate_outlined, size: 18),
            label: Text('Hitung dana darurat'),
          ).h(44),
        ],
      ),
    );
    return calculatorLayout(
      card('Dana darurat', form),
      result == null ? emptyResult() : card('Ringkasan', Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          resultRow('Target dana darurat', result['target']!.moneyFormat(), prominent: true),
          progress(result['progress']!.toDouble()),
          resultRow('Perlindungan saat ini', '${result['coverage']!.toStringAsFixed(1)} bulan'),
          resultRow('Kekurangan dana', result['remaining']!.moneyFormat()),
          resultRow('Waktu menabung', result['months'] == 0
              ? 'Target tercapai'
              : result['months'] == null ? 'Belum ada setoran' : savingDuration(result['months']!.toInt())),
          'Dengan pengeluaran dan setoran tetap, tanpa imbal hasil.'
              .text.size(11).color(AppColor.neutral).make(),
        ],
      )),
    );
  }

  Widget retirementCalculator() {
    final result = controller.retirementResult;
    final form = Form(
      key: controller.retirementForm,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          inputPair(
            field('Usia saat ini', controller.currentAge, max: 100, unit: 'tahun', retirement: true),
            field('Usia pensiun', controller.retirementAge, max: 100, unit: 'tahun', retirement: true),
          ),
          field('Lama masa pensiun', controller.retirementYears, max: 100, unit: 'tahun', retirement: true),
          field('Pengeluaran bulanan (nilai saat ini)', controller.retirementExpense, money: true, retirement: true),
          field('Dana pensiun saat ini', controller.retirementSaved, money: true, min: 0, retirement: true),
          Divider(height: 24, color: AppColor.border),
          'Asumsi tahunan'.text.size(12).bold.make().pOnly(bottom: 16),
          field('Inflasi', controller.inflation, min: 0, max: 20, decimal: true, unit: '%', retirement: true),
          inputPair(
            field('Return sebelum pensiun', controller.growthReturn, min: -20, max: 20, decimal: true, unit: '%', retirement: true),
            field('Return saat pensiun', controller.retirementReturn, min: -20, max: 20, decimal: true, unit: '%', retirement: true, last: true),
          ),
          'Return nominal bersih setelah biaya/pajak, belum dikurangi inflasi. Nilai awal hanya asumsi simulasi.'
              .text.size(11).color(AppColor.neutral).make().pOnly(bottom: 16),
          FilledButton.icon(
            onPressed: () => calculate(true),
            icon: Icon(Icons.calculate_outlined, size: 18),
            label: Text('Hitung dana pensiun'),
          ).h(44),
        ],
      ),
    );
    return calculatorLayout(
      card('Dana pensiun', form),
      result == null ? emptyResult() : card('Ringkasan', Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          resultRow('Target dana saat mulai pensiun', result['target']!.moneyFormat(), prominent: true),
          progress(result['progress']!.toDouble()),
          resultRow('Pengeluaran bulanan saat mulai pensiun', result['expense']!.moneyFormat()),
          resultRow('Proyeksi dana saat ini ke usia pensiun', result['projectedSaved']!.moneyFormat()),
          resultRow('Kekurangan dana saat pensiun', result['remaining']!.moneyFormat()),
          Divider(height: 20, color: AppColor.border),
          resultRow('Setoran bulanan mulai sekarang', result['monthlySaving'] == null
              ? 'Perlu dana langsung'
              : result['monthlySaving'] == 0 ? 'Target sudah tercukupi' : result['monthlySaving']!.moneyFormat(), prominent: true),
          'Setoran tetap di akhir bulan; pengeluaran di awal bulan dan naik tiap tahun. Hasil mengikuti asumsi, bukan jaminan.'
              .text.size(11).color(AppColor.neutral).make(),
        ],
      )),
    );
  }

  Widget extraCalculator(ExtraTool tool) {
    final result = controller.extraResults[tool.id];
    return calculatorLayout(
      card(tool.title, Form(
        key: controller.extraForms[tool.id],
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final input in tool.inputs)
              field(
                input.label,
                controller.extraInputs['${tool.id}.${input.key}']!,
                money: input.unit == 'money',
                decimal: input.unit == '%',
                min: input.min,
                max: input.max,
                unit: input.unit == 'money' ? null : input.unit,
                extraTool: tool,
                last: input == tool.inputs.last,
              ),
            tool.note.text.size(11).color(AppColor.neutral).make().pOnly(bottom: 16),
            FilledButton.icon(
              onPressed: () => calculateExtra(tool),
              icon: Icon(Icons.calculate_outlined, size: 18),
              label: Text('Hitung'),
            ).h(44),
          ],
        ),
      )),
      result == null ? emptyResult() : card('Ringkasan', Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final output in result)
            resultRow(output.label, formatOutput(output), prominent: output == result.first),
        ],
      )),
    );
  }

  String formatOutput(ToolOutput output) {
    final value = output.value;
    if (value is! num) return '$value';
    if (output.unit == 'money') return value.moneyFormat();
    if (output.unit == '%') return '${value.toStringAsFixed(1)}%';
    if (output.unit == 'bulan') return savingDuration(value.toInt());
    return '${value.toStringAsFixed(0)} ${output.unit}';
  }

  void calculateExtra(ExtraTool tool) {
    controller.calculateExtra(tool);
    if (!controller.extraResults.containsKey(tool.id)) return;
    showResult();
  }

  Widget calculatorLayout(Widget form, Widget result) {
    final resultPanel = KeyedSubtree(key: controller.resultKey, child: result);
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 780) {
        return Column(children: [form, SizedBox(height: 20), resultPanel]);
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: form),
          SizedBox(width: 20),
          Expanded(flex: 2, child: resultPanel),
        ],
      );
    });
  }

  void calculate(bool retirement) {
    if (retirement) {
      controller.calculateRetirement();
    } else {
      controller.calculateEmergency();
    }
    if ((retirement ? controller.retirementResult : controller.emergencyResult) == null) return;
    showResult();
  }

  void showResult() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = controller.resultKey.currentContext;
      if (context == null || !context.mounted || !context.isMobile) return;
      Scrollable.ensureVisible(context, duration: Duration(milliseconds: 250));
    });
  }

  Widget inputPair(Widget first, Widget second) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 400) return Column(children: [first, second]);
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Expanded(child: first), SizedBox(width: 16), Expanded(child: second)],
      );
    });
  }

  Widget emptyResult() => card('Ringkasan', Padding(
    padding: EdgeInsets.symmetric(vertical: 24),
    child: Column(
      children: [
        Icon(Icons.calculate_outlined, color: AppColor.neutral, size: 32),
        SizedBox(height: 12),
        Text('Isi data lalu hitung simulasi', style: TextStyle(color: AppColor.neutral, fontSize: 12)),
      ],
    ),
  ));

  Widget progress(double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        '${(value * 100).toStringAsFixed(0)}% target tercukupi'
            .text.size(11).color(AppColor.neutral).make(),
        SizedBox(height: 8),
        LinearProgressIndicator(
          value: value,
          minHeight: 6,
          borderRadius: BorderRadius.circular(6),
          color: value >= 1 ? AppColor.green : AppColor.primary,
          backgroundColor: AppColor.border,
          semanticsLabel: 'Target tercukupi',
          semanticsValue: '${(value * 100).toStringAsFixed(0)}%',
        ),
      ],
    ).pOnly(bottom: 20);
  }

  String savingDuration(int months) {
    if (months < 12) return '$months bulan';
    final remainder = months % 12;
    return '${months ~/ 12} tahun${remainder == 0 ? '' : ' $remainder bulan'}';
  }

  Widget card(String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: ExDecorator.box(
        fillColor: AppColor.box,
        borderColor: AppColor.border,
        borderRadius: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title.text.size(15).bold.make().pOnly(bottom: 20),
          child,
        ],
      ),
    );
  }

  Widget field(
    String label,
    TextEditingController input, {
    bool money = false,
    bool decimal = false,
    bool retirement = false,
    bool last = false,
    ExtraTool? extraTool,
    String? unit,
    num min = 1,
    num max = 999999999999,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label.text.size(12).bold.make().pOnly(bottom: 8),
        Semantics(label: label, child: TextFormField(
          key: ObjectKey(input),
          controller: input,
          style: TextStyle(fontSize: 12),
          keyboardType: TextInputType.numberWithOptions(decimal: decimal, signed: min < 0),
          decoration: HelperDecoration.input(
            hint: money ? 'Rp.0' : '0',
            suffix: unit == null ? null : Text(unit, style: TextStyle(fontSize: 11, color: AppColor.neutral)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          inputFormatters: money
              ? [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12),
                  CurrencyTextInputFormatter(NumberFormat.simpleCurrency(
                    locale: 'id_ID', name: 'Rp.', decimalDigits: 0,
                  )),
                ]
              : [
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    final pattern = decimal
                        ? (min < 0 ? r'^-?\d{0,3}([.,]\d{0,2})?$' : r'^\d{0,3}([.,]\d{0,2})?$')
                        : r'^\d{0,5}$';
                    return RegExp(pattern).hasMatch(newValue.text) ? newValue : oldValue;
                  }),
                ],
          validator: (text) {
            final value = money
                ? (text ?? '').moneyUnformat()
                : num.tryParse((text ?? '').replaceAll(',', '.'));
            if (value == null || !value.isFinite) return 'Isi angka yang valid';
            if (!money && !decimal && value != value.truncateToDouble()) return 'Isi bilangan bulat';
            if (value < min) return min < 0 ? 'Minimal $min' : min == 0 ? 'Tidak boleh negatif' : 'Harus lebih dari 0';
            if (value > max) return money ? 'Maksimal ${max.moneyFormat()}' : 'Maksimal $max';
            if (input == controller.retirementAge && value < (int.tryParse(controller.currentAge.text) ?? 0)) {
              return 'Tidak boleh kurang dari usia saat ini';
            }
            return null;
          },
          textInputAction: last ? TextInputAction.done : TextInputAction.next,
          onFieldSubmitted: last ? (_) => extraTool == null ? calculate(retirement) : calculateExtra(extraTool) : null,
          onChanged: (_) => extraTool == null ? controller.clearResult(retirement) : controller.clearExtraResult(extraTool.id),
        )),
      ],
    ).pOnly(bottom: 16);
  }

  Widget resultRow(String label, String value, {bool prominent = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label.text.size(11).color(AppColor.neutral).make(),
        SelectableText(value, style: TextStyle(
          fontSize: prominent ? 24 : 16,
          fontWeight: FontWeight.bold,
          color: prominent ? AppColor.blue : AppColor.textReverse,
        )),
      ],
    ).pOnly(bottom: 12);
  }
}
