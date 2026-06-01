import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:deaf_hearing_app/core/theme/app_colors.dart';
import 'package:deaf_hearing_app/core/widgets/glass_container.dart';
import 'package:deaf_hearing_app/features/conversation/domain/entities/message.dart';
import 'package:deaf_hearing_app/features/conversation/presentation/bloc/conversation_bloc.dart';
import 'package:deaf_hearing_app/features/conversation/presentation/bloc/conversation_state.dart';

class ChatTimelineComponent extends StatefulWidget {
  const ChatTimelineComponent({super.key});

  @override
  State<ChatTimelineComponent> createState() => _ChatTimelineComponentState();
}

class _ChatTimelineComponentState extends State<ChatTimelineComponent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConversationCubit, ConversationState>(
      builder: (context, state) {
        return Expanded(
          child: ShaderMask(
            shaderCallback: (rect) {
              return const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black,
                  Colors.black,
                  Colors.black,
                ],
                stops: [0.0, 0.08, 0.95, 1.0],
              ).createShader(rect);
            },
            blendMode: BlendMode.dstIn,
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
              itemCount: state.messages.length + (state.isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (state.isTyping && index == 0) {
                  return _buildTypingIndicator();
                }

                final messageIndex = state.isTyping ? index - 1 : index;
                final message = state.messages[messageIndex];
                return _buildMessageItem(message);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GlassContainer(
            borderRadius: 16,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            backgroundColor: AppColors.glassBackground.withOpacity(0.08),
            borderColor: AppColors.glassBorder.withOpacity(0.1),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'AI workspace translating...',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(Message message) {
    switch (message.type) {
      case MessageType.text:
        return _buildTextMessage(message);
      case MessageType.voice:
        return _buildVoiceMessage(message);
      case MessageType.translation:
        return _buildTranslationMessage(message);
      case MessageType.aiState:
        return _buildAiStateMessage(message);
    }
  }

  Widget _buildTextMessage(Message message) {
    final isMe = message.sender == MessageSender.user;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) _buildAvatar(message.sender),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 20),
                ),
                gradient: isMe
                    ? const LinearGradient(
                        colors: [AppColors.primary, Color(0xFF6D28D9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isMe ? null : AppColors.bubbleDeaf,
                border: Border.all(
                  color: isMe
                      ? Colors.white.withOpacity(0.2)
                      : AppColors.darkGlassBorder,
                  width: 1,
                ),
                boxShadow: isMe
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                message.content['text'],
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (isMe) _buildAvatar(message.sender),
        ],
      ),
    );
  }

  Widget _buildVoiceMessage(Message message) {
    final isMe = message.sender == MessageSender.user;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) _buildAvatar(message.sender),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              width: 250,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.bubbleDeaf,
                border: Border.all(color: AppColors.darkGlassBorder, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Voice Recording',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '0:03 • 96% accuracy',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (message.translation != null) ...[
                    const SizedBox(height: 10),
                    const Divider(color: Colors.white10, height: 1),
                    const SizedBox(height: 8),
                    Text(
                      '"${message.translation!.text}"',
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (isMe) _buildAvatar(message.sender),
        ],
      ),
    );
  }

  Widget _buildTranslationMessage(Message message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildAvatar(message.sender),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(
                  0xFF132822,
                ), // Soft emerald glow card background
                border: Border.all(
                  color: AppColors.stateGreen.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.sign_language_rounded,
                        color: AppColors.stateGreen,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'SIGN TRANSLATION READY',
                        style: TextStyle(
                          color: AppColors.stateGreen,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message.translation?.text ?? message.content['text'],
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.query_stats_rounded,
                        color: AppColors.textSecondary,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Confidence: ${(message.translation?.confidence ?? 0.91 * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiStateMessage(Message message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white.withOpacity(0.02),
            border: Border.all(
              color: Colors.white.withOpacity(0.04),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  message.content['text'],
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(MessageSender sender) {
    IconData icon;
    Color color;

    switch (sender) {
      case MessageSender.user:
        icon = Icons.hearing_rounded;
        color = AppColors.primary;
        break;
      case MessageSender.other:
        icon = Icons.sign_language_rounded;
        color = AppColors.secondary;
        break;
      case MessageSender.system:
        icon = Icons.memory_rounded;
        color = AppColors.stateGreen;
        break;
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.2),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: Icon(icon, color: color, size: 14),
    );
  }
}
