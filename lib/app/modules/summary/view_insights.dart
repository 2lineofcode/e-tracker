import 'package:ex_kit/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:markdown_widget/markdown_widget.dart';

import '../../core/app_color.dart';
import '../../core/const.dart';
import '../../helpers/helpers.dart';
import '../../models/rpc_sum_note_times_entity.dart';
import '../widgets/widget_shimmer_summary.dart';
import 'summary_controller.dart';

class ViewInsights extends GetView<SummaryController> {
  ViewInsights({super.key});

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (state) => VStack(
        [
          HStack(
            [
              'Period: ${controller.monthSelected} ${controller.yearSelected}'
                  .text
                  .bold
                  .make(),
              Spacer(),
              Obx(() {
                if (controller.chatMessages.isNotEmpty) {
                  return 'Clear Chat'.text.make().onTap(() {
                    controller.clearChat();
                  });
                } else {
                  return Container();
                }
              }),
            ],
          ).pOnly(bottom: 16),
          if (controller.rpcSumNoteTimes.isNotEmpty) ...[
            // Chat messages container
            Container(
              decoration: ExDecorator.box(
                borderColor: AppColor.border,
                borderRadius: 4,
              ),
              child: Obx(
                () {
                  // Auto scroll to bottom when new message arrives
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  });

                  return controller.chatMessages.isEmpty
                      ? _buildInsightDashboard()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.all(12),
                          itemCount: controller.chatMessages.length,
                          itemBuilder: (context, index) {
                            final message = controller.chatMessages[index];
                            return _buildChatBubble(
                              message: message['text'] as String,
                              isUser: message['isUser'] as bool,
                            ).pOnly(bottom: 12);
                          },
                        );
                },
              ),
            ).expand(),

            // Input field with send button
            HStack(
              [
                CupertinoTextField(
                  controller: controller.chatInputController,
                  focusNode: controller.chatInputFocusNode,
                  placeholder: 'Ask me something here..',
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  style: TextStyle(color: Colors.white, fontSize: 13),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColor.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onChanged: (value) => controller.update(),
                  onSubmitted: (value) => controller.sendMessage(),
                ).expand(),
                8.widthBox,
                GetBuilder(
                  init: controller,
                  builder: (controller) => IconButton(
                    onPressed: () => controller.sendMessage(),
                    icon: Icon(
                      Icons.send,
                      size: 16,
                      color: controller.chatInputController.text.isEmpty
                          ? Vx.neutral500
                          : Vx.white,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(90),
                      ),
                    ),
                  ),
                ),
              ],
            ).pOnly(top: 8),
          ] else ...[
            ExUiErrorOrEmpty(
              bgColor: AppColor.emptyStatePrimary,
              title: 'No data to see',
              message: 'You dont have any transaction on this period',
            ).expand(),
          ],
        ],
      ).wFull(context).p12(),
      onLoading: MyShimmerSummary(),
    );
  }

  Widget _buildInsightDashboard() {
    final total = controller.isShowAllYear.isTrue
        ? controller.countOnly1Year.value
        : controller.countOnly1Month.value;
    final daysWithExpense = controller.expenses.length;
    final average = daysWithExpense > 0 ? total / daysWithExpense : 0;
    final topCategory = controller.categorySummaries.isNotEmpty
        ? controller.categorySummaries.first
        : null;
    final topNote = _topNote();
    final previousTotal = _previousMonthTotal();
    final trendDelta = previousTotal == null ? null : total - previousTotal;
    final safeDaily = controller.dayRemaining.value > 0
        ? controller.countRemainingBudget.value / controller.dayRemaining.value
        : 0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(12),
      child: VStack([
        HStack([
          Icon(
            Icons.auto_awesome,
            size: 16,
            color: AppColor.primary,
          ).pOnly(right: 8),
          'Auto Insights'.text.bold.size(14).make().expand(),
          '${controller.isShowAllYear.isTrue ? controller.yearSelected.value : '${controller.monthSelected.value} ${controller.yearSelected.value}'}'
              .text
              .size(11)
              .minFontSize(11)
              .color(AppColor.neutral)
              .make(),
        ]).pOnly(bottom: 12),
        _insightCard(
          icon: Icons.speed_rounded,
          iconColor: controller.countPercentage.value >= 100
              ? AppColor.red
              : AppColor.primary,
          title: 'Budget pace',
          value: controller.countBudget.value > 0
              ? '${controller.countPercentage.value.toStringAsFixed(0)}% used'
              : 'No budget',
          body: controller.countBudget.value > 0
              ? '${controller.countRemainingBudget.value >= 0 ? 'Remaining' : 'Over'} ${controller.countRemainingBudget.value.abs().moneyFormatCompact()}${controller.dayRemaining.value > 0 ? ' · safe ${safeDaily.moneyFormatCompact()}/day' : ''}'
              : 'Set budgets first to unlock pacing.',
          onTapPrompt: controller.countBudget.value > 0
              ? 'kasih rencana spending dari sisa budget periode ini. jawab singkat dan actionable.'
              : null,
        ),
        _insightCard(
          icon: topCategory?.resolvedCategory.icon ?? Icons.category_rounded,
          iconColor: topCategory?.resolvedCategory.color ?? AppColor.blue,
          title: 'Top category',
          value: topCategory == null
              ? 'No category'
              : topCategory.resolvedCategory.label,
          body: topCategory == null
              ? 'Belum ada kategori yang bisa dianalisa.'
              : '${topCategory.total.moneyFormatCompact()} · ${total > 0 ? (topCategory.total / total * 100).toStringAsFixed(0) : 0}% of total spend',
          onTapPrompt: topCategory == null
              ? null
              : 'analisa kategori ${topCategory.resolvedCategory.label}, apakah boros dan gimana cara nguranginnya?',
        ),
        _insightCard(
          icon: Icons.repeat_rounded,
          iconColor: AppColor.orangeLight,
          title: 'Repeated spend',
          value: topNote == null ? 'No repeated note' : topNote.note ?? '-',
          body: topNote == null
              ? 'Belum ada pola note yang berulang.'
              : '${topNote.times}x · ${(topNote.total ?? 0).moneyFormatCompact()} total',
          onTapPrompt: topNote == null
              ? null
              : 'cek pengeluaran berulang "${topNote.note}", ini masih wajar atau bisa dipotong?',
        ),
        _insightCard(
          icon: Icons.local_fire_department_rounded,
          iconColor: AppColor.red,
          title: 'High-spend days',
          value:
              '${controller.highSpender.length} day${controller.highSpender.length == 1 ? '' : 's'}',
          body: controller.highSpender.isEmpty
              ? 'Tidak ada hari yang melewati batas spender.'
              : 'Biggest day: ${controller.highSpender.first.amount?.moneyFormatCompact()} on ${controller.highSpender.first.date?.reformatDate(from: yMd, to: 'dd MMM')}',
          onTapPrompt: controller.highSpender.isEmpty
              ? null
              : 'hari apa aja yang bikin spending tinggi dan apa yang bisa dikurangi?',
        ),
        if (trendDelta != null)
          _insightCard(
            icon: trendDelta >= 0
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            iconColor: trendDelta >= 0 ? AppColor.red : AppColor.green,
            title: 'Vs previous month',
            value: trendDelta >= 0
                ? '+${trendDelta.moneyFormatCompact()}'
                : '-${trendDelta.abs().moneyFormatCompact()}',
            body:
                'Current ${total.moneyFormatCompact()} · previous ${previousTotal!.moneyFormatCompact()}',
            onTapPrompt:
                'bandingin pengeluaran periode ini dengan bulan sebelumnya. bagian mana yang naik/turun?',
          ),
        HStack([
          'Avg active day'.text
              .size(11)
              .minFontSize(11)
              .color(AppColor.neutral)
              .make()
              .expand(),
          '${average.moneyFormatCompact()} · $daysWithExpense active days'.text
              .size(11)
              .minFontSize(11)
              .make(),
        ]).pOnly(top: 4, bottom: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _promptChip(
              'Bikin rencana hemat',
              'buatkan rencana hemat untuk periode ini dari data pengeluaran dan budget. jawab bullet singkat.',
            ),
            _promptChip(
              'Yang bisa dipotong',
              'top pengeluaran apa yang paling realistis dipotong? kasih 3 rekomendasi.',
            ),
            _promptChip(
              'Explain this month',
              'jelasin kondisi finansial periode ini secara singkat, fokus ke risk dan next action.',
            ),
          ],
        ),
      ]),
    );
  }

  Widget _insightCard({
    required IconData icon,
    required Color? iconColor,
    required String title,
    required String value,
    required String body,
    String? onTapPrompt,
  }) {
    return Container(
      width: double.infinity,
      decoration: ExDecorator.box(
        borderColor: AppColor.border,
        borderRadius: 8,
        fillColor: AppColor.box,
      ),
      child: HStack(
        crossAlignment: CrossAxisAlignment.start,
        [
          Icon(icon, size: 16, color: iconColor).pOnly(right: 10, top: 2),
          VStack([
            HStack([
              title.text
                  .size(11)
                  .minFontSize(11)
                  .color(AppColor.neutral)
                  .make()
                  .expand(),
              if (onTapPrompt != null)
                'Ask AI'.text.size(10).minFontSize(10).underline.make(),
            ]),
            value.text.bold
                .size(13)
                .maxLines(1)
                .ellipsis
                .make()
                .pOnly(top: 3, bottom: 3),
            body.text.size(11).minFontSize(11).color(AppColor.neutral).make(),
          ]).expand(),
        ],
      ).p12(),
    ).pOnly(bottom: 10).onInkTap(() async {
      if (onTapPrompt == null) return;
      controller.chatInputController.text = '$onTapPrompt\njawab singkat aja.';
      await 100.milliseconds.delay();
      await controller.sendMessage();
    });
  }

  Widget _promptChip(String label, String prompt) {
    return Container(
      decoration: ExDecorator.box(
        borderRadius: 90,
        borderColor: AppColor.primary,
        fillColor: Colors.transparent,
      ),
      child: label.text.size(11).minFontSize(11).make().pSymmetric(v: 4, h: 10),
    ).onInkTap(() async {
      controller.chatInputController.text = '$prompt\njawab singkat aja.';
      await 100.milliseconds.delay();
      await controller.sendMessage();
    });
  }

  RpcSumNoteTimes? _topNote() {
    if (controller.rpcSumNoteTimes.isEmpty) return null;
    final notes = [...controller.rpcSumNoteTimes]
      ..sort((a, b) => (b.total ?? 0).compareTo(a.total ?? 0));
    return notes.first;
  }

  int? _previousMonthTotal() {
    if (controller.isShowAllYear.isTrue) return null;
    final month = controller.monthSelected.value
        .reformatDate(from: 'MMMM', to: 'MM')
        .toInt();
    if (month == null || month <= 1) return null;
    if (controller.rpcSumAllMonth.length < month - 1) return null;
    return controller.rpcSumAllMonth[month - 2].total ?? 0;
  }

  Widget _buildChatBubble({required String message, required bool isUser}) {
    final isTyping = message == 'Thinking...' && !isUser;

    return Row(
      mainAxisAlignment: isUser
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isUser) ...[
          CircleAvatar(
            radius: 16,
            backgroundColor: Vx.neutral800.withValues(alpha: 0.2),
            child: Icon(Icons.smart_toy, size: 18, color: AppColor.bibit),
          ),
          8.widthBox,
        ],
        Flexible(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isUser ? AppColor.primary : Vx.neutral800,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isUser ? 16 : 4),
                topRight: Radius.circular(isUser ? 4 : 16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: isTyping
                ? HStack([
                    'Thinking...'.text.color(Vx.neutral100).size(12).make(),
                    8.widthBox,
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Vx.neutral100,
                        ),
                      ),
                    ),
                  ])
                : isUser
                ? message.text.color(Colors.white).size(12).make()
                : MarkdownWidget(
                    data: message,
                    shrinkWrap: true,
                    selectable: true,
                    config: MarkdownConfig(
                      configs: [
                        PConfig(
                          textStyle: TextStyle(
                            color: Vx.neutral100,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                        H1Config(
                          style: TextStyle(
                            color: Vx.neutral100,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        H2Config(
                          style: TextStyle(
                            color: Vx.neutral100,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        H3Config(
                          style: TextStyle(
                            color: Vx.neutral100,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        CodeConfig(
                          style: TextStyle(
                            color: Vx.green700,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                        PreConfig(
                          decoration: BoxDecoration(
                            color: Vx.neutral900,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.all(12),
                          textStyle: TextStyle(
                            color: Vx.green700,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                        BlockquoteConfig(
                          sideColor: AppColor.blue,
                          textColor: AppColor.orangeLight,
                        ),
                        LinkConfig(
                          style: TextStyle(
                            color: AppColor.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        if (isUser) ...[
          8.widthBox,
          CircleAvatar(
            radius: 16,
            backgroundColor: Vx.neutral600,
            child: Icon(Icons.person, size: 18, color: Colors.white),
          ),
        ],
      ],
    );
  }
}
