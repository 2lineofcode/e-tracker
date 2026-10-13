import 'dart:async';

import 'package:ex_kit/ex.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_calculator/flutter_simple_calculator.dart';
import 'package:get/get.dart';
import 'package:overlayment/overlayment.dart';

import '../core/app_color.dart';
import '../models/supa_category_entity.dart';
import 'helper_misc.dart';

mixin HelperOverlay {
  static void openCalculator({
    double initialValue = 0,
    double? height,
    double width = 320,
    Alignment alignment = Alignment.centerRight,
    CalcController? controller,
    dynamic Function(double?, TapDownDetails)? onTappedDisplay,
    void Function(String?, double?, String?)? onChanged,
  }) {
    Overlayment.dismissAll();
    unawaited(
      Overlayment.show(
        OverPanel(
          name: 'calc',
          alignment: alignment,
          height: height,
          width: width,
          child: SimpleCalculator(
            controller: controller,
            autofocus: true,
            hideSurroundingBorder: true,
            value: initialValue,
            onChanged: onChanged,
            onTappedDisplay: onTappedDisplay,
          ),
        ),
        context: Get.context!,
      ),
    );
  }

  static Future<void> openDatePicker({
    required Function(DateTime) callback,
    String title = 'Pilih tanggal',
    String btnOKText = 'Pilih',
    String btnCancelText = 'Batal',
    DateTime? initialDate,
    DateTime? minDate,
    DateTime? maxDate,
  }) async {
    var firstDate = minDate ?? DateTime.now().subtract((365 * 5).days);
    var lastDate = maxDate ?? DateTime.now().add((365 * 5).days);

    // Ensure the range is valid even if the caller swaps the bounds.
    if (lastDate.isBefore(firstDate)) {
      final swap = firstDate;
      firstDate = lastDate;
      lastDate = swap;
    }

    var selectedDate = initialDate ?? DateTime.now();
    if (selectedDate.isBefore(firstDate)) {
      selectedDate = firstDate;
    } else if (selectedDate.isAfter(lastDate)) {
      selectedDate = lastDate;
    }

    await Overlayment.show(
      context: Get.context!,
      OverPanel(
        name: 'date_picker',
        alignment: Alignment.center,
        height: Get.height * 0.7,
        width: Get.context!.isMobile ? Get.width - 48 : 320,
        backgroundSettings: BackgroundSettings(color: AppColor.card.withAlpha(150), blur: isMobileWeb ? null : 1),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), color: AppColor.appbarPrimary),
        animation: OverFadeAnimation(durationMilliseconds: 100, reverseDurationMilliseconds: 100),
        child: StatefulBuilder(
          builder: (context, setState) {
            final theme = Theme.of(context);
            final surface = theme.colorScheme.surface;
            return Material(
              color: surface,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(color: AppColor.card, borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedDate.toStringEx(format: 'EEE, d MMM yyyy'),
                                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
                                ).centered(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: 200.milliseconds,
                        child: CalendarDatePicker(
                          key: const ValueKey('calendar_mode'),
                          initialDate: selectedDate,
                          firstDate: firstDate,
                          lastDate: lastDate,
                          onDateChanged: (value) => setState(() => selectedDate = value),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () async {
                            final result = callback(selectedDate);
                            if (result is Future) {
                              await result;
                            }
                            await Overlayment.dismissLast();
                          },
                          child: Text(
                            btnOKText,
                            style: TextStyle(color: theme.colorScheme.primary),
                          ),
                        ).expand(),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static Future<void> openCategoryPicker({
    String title = 'Pilih kategori',
    String btnOKText = 'Pilih',
    required Function(String) callback,
  }) async {
    final searchController = TextEditingController();
    final searchFocusNode = FocusNode();

    String query = '';

    Future<void> submit(String code) async {
      final result = callback(code);
      if (result is Future) await result;
      await Overlayment.dismissLast();
    }

    await Overlayment.show(
      context: Get.context!,
      OverPanel(
        name: 'category_picker',
        alignment: Alignment.center,
        height: Get.height * 0.6,
        width: 270,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColor.appbarPrimary),
        backgroundSettings: BackgroundSettings(color: AppColor.card.withAlpha(150), blur: isMobileWeb ? null : 1),
        animation: OverScaleAnimation(durationMilliseconds: 100, reverseDurationMilliseconds: 100),
        actions: OverlayActions(onReady: () async => searchFocusNode.requestFocus()),
        child: StatefulBuilder(
          builder: (context, setState) {
            final theme = Theme.of(context);
            final surface = theme.colorScheme.surface;
            final textTheme = theme.textTheme;

            final normalizedQuery = query.trim().toLowerCase();
            final visibleGroups = <MapEntry<ExpenseCategoryGroup, List<ExpenseCategory>>>[];
            for (final group in expenseCategoryGroups) {
              final filteredItems = group.items.where((item) {
                if (normalizedQuery.isEmpty) return true;
                return item.label.toLowerCase().contains(normalizedQuery) || item.groupLabel.toLowerCase().contains(normalizedQuery) || item.code.toLowerCase().contains(normalizedQuery);
              }).toList();
              if (filteredItems.isNotEmpty) {
                visibleGroups.add(MapEntry(group, filteredItems));
              }
            }

            Widget buildCategoryTile(ExpenseCategory item) {
              return InkWell(
                onTap: () => submit(item.code),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: (item.color ?? theme.colorScheme.primary).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          item.icon ?? Icons.circle_outlined,
                          size: 12,
                          color: item.color ?? theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            '${item.label}'.text.size(12).make(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Material(
              color: surface,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          splashRadius: 18,
                          onPressed: () => Overlayment.dismissLast(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: searchController,
                      focusNode: searchFocusNode,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Cari kategori…',
                        prefixIcon: const Icon(Icons.search, size: 18),
                        isDense: true,
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: theme.brightness == Brightness.dark ? 0.6 : 1),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      style: const TextStyle(fontSize: 12),
                      onChanged: (value) => setState(() => query = value),
                    ).h(33),
                    const SizedBox(height: 16),
                    Expanded(
                      child: visibleGroups.isEmpty
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off_rounded, size: 48, color: theme.disabledColor),
                                const SizedBox(height: 12),
                                Text(
                                  'Kategori nggak ditemukan',
                                  style: textTheme.bodyMedium?.copyWith(color: theme.disabledColor),
                                ),
                              ],
                            )
                          : ListView.separated(
                              itemCount: visibleGroups.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 20),
                              itemBuilder: (context, groupIndex) {
                                final entry = visibleGroups[groupIndex];
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.key.label,
                                      style: textTheme.labelLarge?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: theme.colorScheme.secondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ...entry.value.map(
                                      (item) => Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: buildCategoryTile(item),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
