import 'package:ex_kit/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:markdown_widget/markdown_widget.dart';

import '../../core/app_color.dart';
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
              'Period: ${controller.monthSelected} ${controller.yearSelected}'.text.bold.make(),
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
              decoration: ExDecorator.box(borderColor: AppColor.border, borderRadius: 4),
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
                      ? Center(
                          child: VStack(
                            [
                              Icon(Icons.chat_bubble_outline, size: 48),
                              12.heightBox,
                              'Start a conversation'.text.size(16).make(),
                              8.heightBox,
                              'Ask me anything about your expenses'.text.neutral400.size(12).make(),
                            ],
                            crossAlignment: CrossAxisAlignment.center,
                          ),
                        )
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
                    icon: Icon(Icons.send, size: 16, color: controller.chatInputController.text.isEmpty ? Vx.neutral500 : Vx.white),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColor.fabPrimary,
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

  Widget _buildChatBubble({required String message, required bool isUser}) {
    final isTyping = message == 'Typing...' && !isUser;

    return Row(
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
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
                    'Typing...'.text.color(Vx.neutral100).size(12).make(),
                    8.widthBox,
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Vx.neutral100)),
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
                            color: Vx.green300,
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
                            color: Vx.green300,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                        BlockquoteConfig(
                          sideColor: AppColor.blue,
                        ),
                        ListConfig(
                          marker: (isOrdered, depth, index) {
                            if (isOrdered) {
                              return Text(
                                '${index + 1}. ',
                                style: TextStyle(color: Vx.neutral100),
                              );
                            }
                            return Text(
                              '• ',
                              style: TextStyle(color: AppColor.blue, fontSize: 16),
                            );
                          },
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
