import 'package:ex_kit/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:markdown_widget/markdown_widget.dart';

import '../../core/app_color.dart';
import '../../helpers/helpers.dart';
import '../../models/rpc_sum_note_times_entity.dart';
import '../widgets/widget_shimmer_summary.dart';
import 'agent_controller.dart';
import 'summary_controller.dart';

class ViewInsights extends GetView<SummaryController> {
  const ViewInsights({super.key});

  AgentController get agent => Get.find<AgentController>();

  static const _slashOptions = [
    _ComposerOption('/expense', Icons.payments_outlined),
    _ComposerOption('/note', Icons.note_add_outlined),
    _ComposerOption('/goal', Icons.flag_outlined),
    _ComposerOption('/budget', Icons.account_balance_wallet_outlined),
    _ComposerOption('/import', Icons.upload_file_outlined),
    _ComposerOption('/memory', Icons.memory_rounded),
    _ComposerOption('/web', Icons.public_rounded),
    _ComposerOption('/clear', Icons.delete_sweep_outlined),
  ];
  static const _mentionOptions = [
    _ComposerOption('@expenses', Icons.receipt_long_outlined),
    _ComposerOption('@budgets', Icons.account_balance_wallet_outlined),
    _ComposerOption('@profile', Icons.person_outline_rounded),
    _ComposerOption('@goals', Icons.flag_outlined),
    _ComposerOption('@recurring', Icons.repeat_rounded),
    _ComposerOption('@assets', Icons.savings_outlined),
    _ComposerOption('@notes', Icons.notes_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (state) => Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: ExDecorator.box(
                borderColor: AppColor.border,
                borderRadius: 12,
                fillColor: AppColor.box,
              ),
              child: Obx(() {
                final hasChat = agent.chatMessages.isNotEmpty;
                final isRunning = agent.isAIAnalysisRunning.value;
                return Column(
                  children: [
                    if (hasChat) _buildChatActions(isRunning),
                    if (!hasChat)
                      _buildPeriodDecision().pOnly(
                        left: 14,
                        right: 14,
                        top: 14,
                      ),
                    Expanded(
                      child: hasChat
                          ? Stack(
                              children: [
                                ListView.separated(
                                  controller:
                                      agent.chatScrollController,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  itemCount: agent.chatMessages.length,
                                  separatorBuilder: (context, index) =>
                                      14.heightBox,
                                  itemBuilder: (context, index) {
                                    final message =
                                        agent.chatMessages[index];
                                    final isUser = message['isUser'] as bool;
                                    final text = message['text'] as String;
                                    final isLoading =
                                        message['isLoading'] == true;
                                    final attachments =
                                        (message['attachments']
                                                    as List<dynamic>?)
                                                ?.whereType<Map>()
                                                .map(
                                                  (item) =>
                                                      Map<String, dynamic>.from(
                                                    item,
                                                  ),
                                                )
                                                .toList() ??
                                            [];
                                    return _buildChatBubble(
                                      messageIndex: index,
                                      message: text,
                                      isUser: isUser,
                                      isLoading: isLoading,
                                      attachments: attachments,
                                      isStreaming: agent
                                              .isAIAnalysisRunning.isTrue &&
                                          index ==
                                              agent.chatMessages.length -
                                                  1 &&
                                          !isUser &&
                                          !isLoading,
                                    );
                                  },
                                ),
                                if (agent.showBackToEnd.isTrue)
                                  IconButton(
                                    onPressed: agent.scrollChatToEnd,
                                    icon: Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColor.primary),
                                  ).positioned(bottom: 12, right: 0, left: 0),
                              ],
                            )
                          : _buildInsightDashboard(),
                    ),
                  ],
                );
              }),
            ),
          ),
          10.heightBox,
          _buildComposer(),
        ],
      ).p12(),
      onLoading: MyShimmerSummary(),
    );
  }

  Widget _buildChatActions(bool isRunning) {
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            label: 'Lihat JSON',
            button: true,
            child: IconButton(
              onPressed: _showChatJson,
              icon: Icon(Icons.data_object_rounded, size: 18),
              style: IconButton.styleFrom(
                minimumSize: Size(36, 32),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
          Semantics(
            label: isRunning
                ? 'Tunggu ditdhewAI selesai'
                : 'Hapus percakapan',
            button: true,
            child: IconButton(
              onPressed: isRunning ? null : agent.clearChat,
              icon: Icon(Icons.delete_outline_rounded, size: 18),
              style: IconButton.styleFrom(
                minimumSize: Size(36, 32),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ).pOnly(right: 4),
    ).pOnly(top: 2);
  }

  Widget _buildComposer() {
    return GetBuilder<AgentController>(
      builder: (agent) {
        final isRunning = agent.isAIAnalysisRunning.isTrue;
        final isLoadingFile = agent.isChatAttachmentLoading.isTrue;
        final options = _composerOptions(agent.chatInputController.text);
        final canSend =
            (agent.chatInputController.text.trim().isNotEmpty ||
                agent.chatAttachments.isNotEmpty) &&
            !isLoadingFile &&
            !isRunning;

        return Container(
          width: double.infinity,
          decoration: ExDecorator.box(
            borderColor: isRunning ? AppColor.primary : AppColor.border,
            borderRadius: 12,
            fillColor: AppColor.textFieldPrimary,
          ),
          child: VStack([
            if (agent.editingChatMessageIndex != null)
              HStack([
                Icon(
                  Icons.edit_outlined,
                  size: 14,
                  color: AppColor.primary,
                ),
                7.widthBox,
                'Edit pesan'.text.size(11).make().expand(),
                Semantics(
                  label: 'Batal edit',
                  button: true,
                  child: IconButton(
                    onPressed: agent.cancelEditingChatMessage,
                    icon: Icon(Icons.close_rounded, size: 15),
                    style: IconButton.styleFrom(
                      minimumSize: Size(28, 28),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              ]).pOnly(left: 12, right: 6, top: 6),
            if (options.isNotEmpty)
              _buildComposerSuggestions(options).pOnly(
                left: 8,
                right: 8,
                top: 8,
              ),
            if (agent.chatAttachments.isNotEmpty)
              _buildPendingAttachments().pOnly(
                left: 8,
                right: 8,
                top: 8,
              ),
            HStack([
              Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: isRunning ? AppColor.primary : AppColor.neutral,
              ).pOnly(left: 12),
              CallbackShortcuts(
                bindings: {
                  SingleActivator(
                    LogicalKeyboardKey.enter,
                    meta: true,
                  ): () {
                    if (canSend) agent.sendMessage();
                  },
                },
                child: CupertinoTextField(
                  controller: agent.chatInputController,
                  focusNode: agent.chatInputFocusNode,
                  placeholder: isRunning
                      ? 'ditdhewAI lagi bekerja...'
                      : 'Tanya ditdhewAI...',
                  placeholderStyle: TextStyle(
                    color: AppColor.neutral,
                    fontSize: 12,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  style: TextStyle(
                    color: Get.theme.textTheme.bodyMedium?.color,
                    fontSize: 13,
                  ),
                  decoration: BoxDecoration(color: Colors.transparent),
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  onChanged: (value) => agent.update(),
                ),
              ).expand(),
              IconButton(
                tooltip: 'Lampirkan file',
                onPressed: isRunning || isLoadingFile
                    ? null
                    : agent.pickChatAttachment,
                icon: isLoadingFile
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.attach_file_rounded, size: 18),
                color: AppColor.neutral,
              ),
              Tooltip(
                message: isRunning ? 'Menunggu ditdhewAI' : 'Kirim pesan',
                child: IconButton(
                  onPressed: canSend ? agent.sendMessage : null,
                  icon: isRunning
                      ? SizedBox(
                          width: 17,
                          height: 17,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColor.textOnBackground,
                          ),
                        )
                      : Icon(Icons.arrow_upward_rounded, size: 18),
                  color: AppColor.textOnBackground,
                  disabledColor: AppColor.neutral,
                  style: IconButton.styleFrom(
                    backgroundColor: canSend || isRunning
                        ? AppColor.primary
                        : AppColor.border,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ).pOnly(right: 6),
            ]),
          ]),
        );
      },
    );
  }

  List<_ComposerOption> _composerOptions(String value) {
    final input = value.trimLeft().toLowerCase();
    if (input.startsWith('/') && !input.contains(RegExp(r'\s'))) {
      return _slashOptions
          .where((option) => option.value.startsWith(input))
          .toList();
    }

    final match = RegExp(r'(?:^|\s)@([a-z_]*)$').firstMatch(input);
    if (match == null) return [];
    final query = '@${match.group(1)}';
    return _mentionOptions
        .where((option) => option.value.startsWith(query))
        .toList();
  }

  Widget _buildComposerSuggestions(List<_ComposerOption> options) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (context, index) => 6.widthBox,
        itemBuilder: (context, index) {
          final option = options[index];
          return Container(
            decoration: ExDecorator.box(
              borderColor: AppColor.border,
              borderRadius: 8,
              fillColor: AppColor.card,
            ),
            child: HStack([
              Icon(option.icon, size: 13, color: AppColor.primary),
              5.widthBox,
              option.value.text.size(10).minFontSize(10).make(),
            ]).pSymmetric(h: 9),
          ).onInkTap(() => _applyComposerOption(option.value));
        },
      ),
    );
  }

  void _applyComposerOption(String option) {
    final text = agent.chatInputController.text;
    final next = option == '/import'
        ? AgentController.importExpenseTemplate
        : option.startsWith('/')
        ? '$option '
        : '${text.substring(0, text.lastIndexOf('@'))}$option ';
    agent.chatInputController.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
    agent.update();
    agent.chatInputFocusNode.requestFocus();
  }

  Widget _buildPendingAttachments() {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: agent.chatAttachments.length,
        separatorBuilder: (context, index) => 6.widthBox,
        itemBuilder: (context, index) {
          final attachment = agent.chatAttachments[index];
          return Container(
            decoration: ExDecorator.box(
              borderColor: AppColor.primary,
              borderRadius: 8,
              fillColor: AppColor.primary.withAlpha(30),
            ),
            child: HStack([
              Icon(
                Icons.insert_drive_file_outlined,
                size: 13,
                color: AppColor.primary,
              ),
              5.widthBox,
              _attachmentName(attachment['name'])
                  .text
                  .size(10)
                  .maxLines(1)
                  .ellipsis
                  .make(),
              3.widthBox,
              InkWell(
                onTap: () => agent.removeChatAttachment(index),
                child: Icon(Icons.close_rounded, size: 14),
              ),
            ]).pSymmetric(h: 8),
          );
        },
      ),
    );
  }

  String _attachmentName(dynamic value) {
    final name = '$value';
    return name.length > 30 ? '${name.substring(0, 29)}…' : name;
  }

  String _selectedPeriod() {
    if (controller.isShowAllYear.isTrue) {
      return controller.yearSelected.value;
    }
    return '${controller.monthSelected.value} ${controller.yearSelected.value}';
  }

  void _showChatJson() {
    Get.dialog(
      AlertDialog(
        title: Text('JSON sesi', style: TextStyle(fontSize: 16)),
        content: SizedBox(
          width: 720,
          height: 480,
          child: SingleChildScrollView(
            child: VxJson.list(agent.agentSessionJson),
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodDecision() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.primary.withAlpha(110),
            AppColor.primary.withAlpha(25),
          ],
        ),
        border: Border.all(color: AppColor.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: HStack([
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.insights_rounded,
            size: 19,
            color: AppColor.textOnBackground,
          ),
        ).pOnly(right: 10),
        VStack([
          HStack([
            controller.periodDecisionTitle.text.bold
                .size(13)
                .color(AppColor.textOnBackground)
                .make()
                .expand(),
            _selectedPeriod().text
                .size(9)
                .minFontSize(9)
                .color(AppColor.textOnBackground.withAlpha(180))
                .make(),
          ]),
          (controller.selectedPeriodTotal <= 0
                  ? 'Coba periode lain.'
                  : controller.periodDecisionBody.split('.').first)
              .text
              .size(10)
              .minFontSize(10)
              .color(AppColor.textOnBackground.withAlpha(190))
              .maxLines(1)
              .ellipsis
              .make()
              .pOnly(top: 3),
        ]).expand(),
      ]).p12(),
    );
  }

  Widget _buildInsightDashboard() {
    final topCategory = controller.categorySummaries.isNotEmpty
        ? controller.categorySummaries.first
        : null;
    final topNote = _topNote();
    final previousTotal = controller.previousPeriodTotalValue;
    final trendDelta = controller.periodTrendDelta;
    final trendPercentage = controller.periodTrendPercentage;
    final trendPercentageLabel = trendPercentage == null
        ? ''
        : ' (${trendPercentage > 0 ? '+' : ''}${trendPercentage.toStringAsFixed(0)}%)';
    final remainingBudget =
        '${controller.countRemainingBudget.value >= 0 ? 'Sisa' : 'Lebih'} ${controller.countRemainingBudget.value.abs().moneyFormatCompact()}';
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: VStack([
        if (controller.isShowAllYear.isFalse)
          _insightCard(
            icon: Icons.speed_rounded,
            iconColor: controller.budgetPacePercentage >= 100
                ? AppColor.red
                : AppColor.primary,
            title: controller.isCurrentSelectedMonth
                ? 'Budget'
                : 'Budget terpakai',
            value: controller.countBudget.value > 0
                ? '${controller.budgetPacePercentage.toStringAsFixed(0)}% · $remainingBudget'
                : 'Belum ada budget',
            onTapPrompt: controller.countBudget.value > 0
                ? 'kasih rencana spending dari sisa budget. jawab singkat dan actionable.'
                : null,
          ),
        _insightCard(
          icon: topCategory?.resolvedCategory.icon ?? Icons.category_rounded,
          iconColor: topCategory?.resolvedCategory.color ?? AppColor.blue,
          title: 'Kategori terbesar',
          value: topCategory == null
              ? 'Belum ada kategori'
              : '${topCategory.resolvedCategory.label} · ${topCategory.total.moneyFormatCompact()}',
          onTapPrompt: topCategory == null
              ? null
              : 'analisa kategori ${topCategory.resolvedCategory.label}, apakah boros dan gimana cara nguranginnya?',
        ),
        _insightCard(
          icon: Icons.repeat_rounded,
          iconColor: AppColor.orangeLight,
          title: 'Berulang',
          value: topNote == null
              ? 'Belum ada'
              : '${topNote.note ?? '-'} · ${topNote.times}x · ${(topNote.total ?? 0).moneyFormatCompact()}',
          onTapPrompt: topNote == null
              ? null
              : 'cek pengeluaran berulang "${topNote.note}", ini masih wajar atau bisa dipotong?',
        ),
        _insightCard(
          icon: Icons.local_fire_department_rounded,
          iconColor: AppColor.red,
          title: 'Pengeluaran tinggi',
          value: controller.highSpender.isEmpty
              ? 'Belum ada'
              : '${controller.highSpender.length} hari · puncak ${controller.highSpender.first.amount?.moneyFormatCompact()}',
          onTapPrompt: controller.highSpender.isEmpty
              ? null
              : 'hari apa aja yang bikin spending tinggi dan apa yang bisa dikurangi?',
        ),
        if (previousTotal != null && trendDelta != null)
          _insightCard(
            icon: trendDelta > 0
                ? Icons.trending_up_rounded
                : trendDelta < 0
                ? Icons.trending_down_rounded
                : Icons.trending_flat_rounded,
            iconColor: trendDelta > 0
                ? AppColor.red
                : trendDelta < 0
                ? AppColor.green
                : AppColor.neutral,
            title: 'dibanding ${controller.previousPeriodLabel}',
            value:
                '${trendDelta > 0 ? '+' : trendDelta < 0 ? '-' : ''}${trendDelta.abs().moneyFormatCompact()}$trendPercentageLabel',
            onTapPrompt:
                'bandingin pengeluaran periode ini dengan periode sebelumnya secara comparable. bagian mana yang naik atau turun?',
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _promptChip(
              'Rencana hemat',
              'buat rencana hemat yang realistis dari pola pengeluaran dan budget, lengkap dengan target nominal yang bisa dipangkas.',
            ),
            _promptChip(
              'Cari pengeluaran bocor',
              'identifikasi pengeluaran yang paling boros atau tidak konsisten, lalu kasih 3 prioritas yang bisa dikurangi.',
            ),
            _promptChip(
              'Bandingkan periode',
              'bandingkan pengeluaran dengan periode sebelumnya: total, kategori utama, dan perubahan terbesar.',
            ),
            _promptChip(
              'Atur sisa budget',
              'kalau periode masih berjalan, bagi sisa budget menjadi batas harian dan prioritas kategori sampai akhir periode.',
            ),
            _promptChip(
              'Ringkas kondisi',
              'ringkas kondisi finansial periode ini: apa yang aman, risiko utama, dan satu tindakan berikutnya.',
            ),
          ],
        ).pOnly(top: 4),
      ]),
    );
  }

  Widget _insightCard({
    required IconData icon,
    required Color? iconColor,
    required String title,
    required String value,
    String? onTapPrompt,
  }) {
    final card = Container(
      width: double.infinity,
      decoration: ExDecorator.box(
        borderColor: AppColor.border,
        borderRadius: 8,
        fillColor: AppColor.box,
      ),
      child: HStack(
        [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconColor?.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 15, color: iconColor),
          ).pOnly(right: 10),
          VStack([
            title.text
                .size(9)
                .minFontSize(9)
                .color(AppColor.neutral)
                .make(),
            value.text
                .size(12)
                .maxLines(1)
                .ellipsis
                .make()
                .pOnly(top: 2),
          ]).expand(),
          if (onTapPrompt != null)
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColor.neutral,
            ),
        ],
      ).pSymmetric(h: 10, v: 8),
    ).pOnly(bottom: 8);
    if (onTapPrompt == null) return card;
    return card.onInkTap(() => _sendInsightPrompt(onTapPrompt));
  }

  Widget _promptChip(String label, String prompt) {
    return Container(
      decoration: ExDecorator.box(
        borderRadius: 90,
        borderColor: AppColor.primary,
        fillColor: Colors.transparent,
      ),
      child: label.text.size(11).minFontSize(11).make().pSymmetric(v: 4, h: 10),
    ).onInkTap(() => _sendInsightPrompt(prompt));
  }

  Future<void> _sendInsightPrompt(String prompt) async {
    agent.chatInputController.text =
        'Untuk dashboard periode ini, $prompt\njawab singkat aja.';
    await 100.milliseconds.delay();
    await agent.sendMessage();
  }

  RpcSumNoteTimes? _topNote() {
    final notes = controller.rpcSumNoteTimes
        .where((note) => (note.times ?? 0) > 1)
        .toList()
      ..sort((a, b) => (b.total ?? 0).compareTo(a.total ?? 0));
    if (notes.isEmpty) return null;
    return notes.first;
  }

  Widget _buildChatBubble({
    required int messageIndex,
    required String message,
    required bool isUser,
    required bool isLoading,
    required List<Map<String, dynamic>> attachments,
    required bool isStreaming,
  }) {
    final markdownColor = isUser ? Colors.white : Vx.neutral100;
    final body = isLoading
        ? HStack([
            message.text.color(Vx.neutral100).size(12).make().expand(),
            8.widthBox,
            SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColor.bibit,
              ),
            ),
          ])
        : isStreaming
        ? '$message ▍'.text
              .color(Vx.neutral100)
              .size(12)
              .heightRelaxed
              .make()
        : MarkdownBlock(
            data: message,
            selectable: true,
            config: MarkdownConfig(
              configs: [
                PConfig(
                  textStyle: TextStyle(
                    color: markdownColor,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                H1Config(
                  style: TextStyle(
                    color: markdownColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                H2Config(
                  style: TextStyle(
                    color: markdownColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                H3Config(
                  style: TextStyle(
                    color: markdownColor,
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
                TableConfig(
                  border: TableBorder.all(
                    color: Vx.neutral700,
                    width: 0.8,
                  ),
                  headerRowDecoration: BoxDecoration(
                    color: AppColor.primary.withValues(alpha: 0.22),
                  ),
                  headPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  bodyPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  wrapper: (table) => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: table,
                  ),
                ),
                LinkConfig(
                  style: TextStyle(
                    color: AppColor.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          );

    return LayoutBuilder(
      builder: (context, constraints) {
        final bubbleWidth = constraints.maxWidth
            .clamp(0.0, isUser ? 520.0 : 720.0)
            .toDouble();
        return Row(
          mainAxisAlignment: isUser
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: bubbleWidth),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: isUser ? AppColor.primary : Vx.neutral800,
                  border: Border.all(
                    color: isUser ? AppColor.primary : Vx.neutral700,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isUser ? 14 : 4),
                    topRight: Radius.circular(isUser ? 4 : 14),
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                ),
                child: VStack([
                  if (isUser && attachments.isNotEmpty) ...[
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: attachments.map((attachment) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(18),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: HStack([
                            Icon(
                              Icons.insert_drive_file_outlined,
                              size: 12,
                              color: Colors.white,
                            ),
                            5.widthBox,
                            _attachmentName(attachment['name'])
                                .text
                                .size(9)
                                .color(Colors.white)
                                .maxLines(1)
                                .ellipsis
                                .make(),
                          ]).pSymmetric(h: 7, v: 5),
                        );
                      }).toList(),
                    ),
                    8.heightBox,
                  ],
                  body,
                  if (!isLoading && !isStreaming) ...[
                    4.heightBox,
                    Align(
                      alignment: Alignment.centerRight,
                      child: HStack([
                        Semantics(
                          label: 'Salin pesan',
                          button: true,
                          child: SizedBox(
                            width: 26,
                            height: 26,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: message),
                                );
                              },
                              icon: Icon(
                                Icons.copy_rounded,
                                size: 14,
                                color: isUser
                                    ? Colors.white70
                                    : Vx.neutral400,
                              ),
                            ),
                          ),
                        ),
                        if (isUser)
                          Semantics(
                            label: 'Edit pesan',
                            button: true,
                            child: SizedBox(
                              width: 26,
                              height: 26,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () => agent
                                    .startEditingChatMessage(messageIndex),
                                icon: Icon(
                                  Icons.edit_outlined,
                                  size: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ),
                      ]),
                    ),
                  ],
                ]),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ComposerOption {
  final String value;
  final IconData icon;

  const _ComposerOption(this.value, this.icon);
}
