import 'package:ex_kit/ex.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/app_color.dart';
import '../../helpers/helpers.dart';
import '../widgets/widget_shimmer_summary.dart';
import 'summary_controller.dart';

class ViewNoteTimes extends GetView<SummaryController> {
  const ViewNoteTimes({super.key});

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (state) {
        final items = controller.rpcSumNoteTimes;
        final occurrences = items.fold<int>(
          0,
          (sum, item) => sum + (item.times ?? 0),
        );
        final total = items.fold<int>(
          0,
          (sum, item) => sum + (item.total ?? 0),
        );
        final maxTimes = items.fold<int>(
          1,
          (max, item) => (item.times ?? 0) > max ? item.times! : max,
        );

        return VStack(
          [
            (controller.isShowAllYear.isTrue
                    ? '${controller.yearSelected}'
                    : '${controller.monthSelected} ${controller.yearSelected}')
                .text
                .bold
                .make()
                .pOnly(bottom: 12),
            if (items.isNotEmpty) ...[
              Container(
                decoration: ExDecorator.box(
                  borderRadius: 8,
                  borderColor: AppColor.border,
                  fillColor: AppColor.card,
                ),
                child: HStack([
                  Container(
                    decoration: BoxDecoration(
                      color: AppColor.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notes_rounded,
                      size: 13,
                      color: AppColor.textOnBackground,
                    ).centered(),
                  ).wh(26, 26).pOnly(right: 8),
                  '${items.length} note'.text.size(10).make(),
                  ' · '.text.size(10).color(AppColor.neutral).make(),
                  '$occurrences entri'.text.size(10).make(),
                  Spacer(),
                  total.moneyFormat().text.size(11).bold.make(),
                ]).pSymmetric(h: 12, v: 10),
              ).pOnly(bottom: 12),
              Container(
                decoration: ExDecorator.box(
                  borderRadius: 8,
                  borderColor: AppColor.border,
                  fillColor: AppColor.box,
                ),
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: items.length,
                  separatorBuilder: (context, index) =>
                      Divider(height: 1, color: AppColor.border),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _noteRow(
                      index: index,
                      note: item.note ?? '-',
                      times: item.times ?? 0,
                      total: item.total ?? 0,
                      maxTimes: maxTimes,
                    );
                  },
                ),
              ).expand(),
            ] else ...[
              ExUiErrorOrEmpty(
                bgColor: AppColor.emptyStatePrimary,
                title: 'Belum ada data',
                message: '',
              ).expand(),
            ],
          ],
        ).p12();
      },
      onLoading: MyShimmerSummary(),
    );
  }

  Widget _noteRow({
    required int index,
    required String note,
    required int times,
    required int total,
    required int maxTimes,
  }) {
    final progress = maxTimes > 0 ? times / maxTimes : 0.0;
    final isTop = index < 3;

    return VStack([
      HStack([
        Container(
          decoration: BoxDecoration(
            color: isTop
                ? AppColor.primary
                : AppColor.primary.withAlpha(35),
            shape: BoxShape.circle,
          ),
          child: '${index + 1}'.text
              .size(9)
              .bold
              .color(
                isTop
                    ? AppColor.textOnBackground
                    : AppColor.textReverse,
              )
              .makeCentered(),
        ).wh(26, 26).pOnly(right: 10),
        note.text.bold.size(11).maxLines(1).ellipsis.make().expand(),
        '${times}x'.text
            .size(9)
            .minFontSize(9)
            .color(AppColor.textOnBackground)
            .make()
            .pSymmetric(h: 6, v: 2)
            .color(AppColor.primary)
            .cornerRadius(90)
            .pOnly(left: 8),
        total.moneyFormat().text
            .size(11)
            .bold
            .make()
            .pOnly(left: 12),
        IconButton(
          tooltip: 'Salin',
          visualDensity: VisualDensity.compact,
          style: IconButton.styleFrom(
            minimumSize: Size(28, 28),
            maximumSize: Size(28, 28),
            padding: EdgeInsets.zero,
          ),
          icon: Icon(Icons.copy_rounded, size: 14, color: AppColor.neutral),
          onPressed: () => _copyNote(note),
        ),
      ]),
      ClipRRect(
        borderRadius: BorderRadius.circular(90),
        child: LinearProgressIndicator(
          value: progress.clamp(0, 1).toDouble(),
          minHeight: 3,
          color: AppColor.textOnBackground.withAlpha(180),
          backgroundColor: AppColor.border.withAlpha(90),
        ),
      ).pOnly(left: 36),
    ]).pSymmetric(h: 10, v: 7).onInkTap(() => _copyNote(note));
  }

  Future<void> _copyNote(String note) async {
    await Clipboard.setData(ClipboardData(text: note));
    await HelperToast.info('"$note" disalin');
  }
}
