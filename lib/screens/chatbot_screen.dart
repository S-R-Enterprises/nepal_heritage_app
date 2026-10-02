import 'package:flutter/material.dart';

import '../data/chat_service.dart';
import '../navigation/app_router.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/app_status_bar.dart';

/// The AI heritage assistant.
///
/// Opened from the chat button on the home screen. The conversation lives in
/// this screen's state rather than in [ChatService], so leaving and coming back
/// to the screen starts a fresh thread — the service itself is stateless and
/// only turns a question into an answer.
class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key, this.chat});

  /// Injected in tests; production runs on [ChatService.instance].
  final ChatService? chat;

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final ScrollController _scroll = ScrollController();
  final TextEditingController _input = TextEditingController();
  final FocusNode _inputFocus = FocusNode();

  late final ChatService _chat = widget.chat ?? ChatService.instance;
  late final List<ChatMessage> _messages = <ChatMessage>[_chat.greeting()];

  /// True between sending a question and the answer arriving, which is when the
  /// typing indicator shows and the composer is locked.
  bool _typing = false;

  /// Cached so the send button can rebuild itself without reading the
  /// controller during build.
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _input.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _input.removeListener(_onInputChanged);
    _scroll.dispose();
    _input.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    final bool canSend = _input.text.trim().isNotEmpty && !_typing;
    if (canSend != _canSend) {
      setState(() => _canSend = canSend);
    }
  }

  void _send([String? text]) {
    final String question = (text ?? _input.text).trim();
    if (question.isEmpty || _typing) {
      return;
    }
    setState(() {
      _messages.add(ChatMessage(text: question, fromUser: true));
      _typing = true;
      _canSend = false;
    });
    _input.clear();
    _ask(question);
  }

  Future<void> _ask(String question) async {
    final ChatMessage reply = await _chat.ask(question);
    if (!mounted) {
      return;
    }
    setState(() {
      _messages.add(reply);
      _typing = false;
    });
    _scrollToBottom();
  }

  /// Follows the composer down once the new turn has been laid out.
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) {
        return;
      }
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  void _handleAction(ChatAction action) {
    final AppScreen? target = action.screen;
    if (target == null) {
      _send(action.label);
      return;
    }
    // Chained onto this screen's frame so the router is not mutated mid-build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AppRouterScope.of(context).go(target);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: <Widget>[
          _Header(onBack: () => AppRouterScope.back(context)),
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
              children: <Widget>[
                for (final ChatMessage message in _messages) ...<Widget>[
                  _Bubble(
                    message: message,
                    onAction: _handleAction,
                  ),
                  const SizedBox(height: 12),
                ],
                if (_typing) ...<Widget>[
                  const _TypingBubble(),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
          _Composer(
            controller: _input,
            focusNode: _inputFocus,
            canSend: _canSend,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.forest,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 16, 14),
          child: Column(
            children: <Widget>[
              const AppStatusBar(light: true),
              const SizedBox(height: 4),
              Row(
                children: <Widget>[
                  Material(
                    color: AppColors.white.withValues(alpha: 0.16),
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: onBack,
                      child: const SizedBox(
                        width: 38,
                        height: 38,
                        child: Center(
                          child: AppIconView(
                            AppIcon.chevronLeft,
                            size: 19,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.gold,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: AppIconView(
                        AppIcon.chat,
                        size: 19,
                        color: AppColors.charcoal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'Nepal Assistant',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppFonts.serif,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                        SizedBox(height: 2),
                        Row(
                          children: <Widget>[
                            _OnlineDot(),
                            SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                'AI heritage guide',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: AppFonts.body,
                                  fontSize: 11.5,
                                  color: Color(0xB3FFFFFF),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const AppIconView(
                    AppIcon.sparkle,
                    size: 20,
                    color: AppColors.gold,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The small green presence dot next to the assistant's title.
class _OnlineDot extends StatefulWidget {
  const _OnlineDot();

  @override
  State<_OnlineDot> createState() => _OnlineDotState();
}

class _OnlineDotState extends State<_OnlineDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.35, end: 1).animate(_controller),
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(color: AppColors.moss, shape: BoxShape.circle),
      ),
    );
  }
}

// ── Messages ──────────────────────────────────────────────────────────────────

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.onAction});

  final ChatMessage message;
  final ValueChanged<ChatAction> onAction;

  @override
  Widget build(BuildContext context) {
    final bool mine = message.fromUser;

    return Column(
      crossAxisAlignment:
          mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment:
              mine ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            if (!mine) ...<Widget>[
              const _AssistantAvatar(),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * 0.76,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: mine ? AppColors.forest : AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(AppRadii.lg),
                    topRight: const Radius.circular(AppRadii.lg),
                    bottomLeft: Radius.circular(mine ? AppRadii.lg : 5),
                    bottomRight: Radius.circular(mine ? 5 : AppRadii.lg),
                  ),
                  boxShadow: AppShadows.soft,
                ),
                child: Text(
                  message.text,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 14,
                    height: 1.55,
                    color: mine ? AppColors.white : AppColors.charcoal,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (message.actions.isNotEmpty) ...<Widget>[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final ChatAction action in message.actions)
                  _ActionChip(action: action, onTap: () => onAction(action)),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _AssistantAvatar extends StatelessWidget {
  const _AssistantAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.18),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
      ),
      child: const Center(
        child: AppIconView(AppIcon.sparkle, size: 14, color: AppColors.gold),
      ),
    );
  }
}

/// Outlined follow-up pill under an assistant message. Links and prompts look
/// the same — the label is what tells the traveller which one it is.
class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.action, required this.onTap});

  final ChatAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: action.label,
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.pill),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.6)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  action.label,
                  style: const TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.forest,
                  ),
                ),
                const SizedBox(width: 5),
                AppIconView(
                  action.screen == null ? AppIcon.send : AppIcon.arrowRight,
                  size: 12,
                  color: AppColors.gold,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Three dots pulsing in sequence, shown while the answer is in flight.
class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        const _AssistantAvatar(),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppRadii.lg),
              topRight: Radius.circular(AppRadii.lg),
              bottomRight: Radius.circular(AppRadii.lg),
              bottomLeft: Radius.circular(5),
            ),
            boxShadow: AppShadows.soft,
          ),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, _) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (int i = 0; i < 3; i++)
                    Opacity(
                      // Each dot runs the same cycle offset by a third of it, so
                      // the pulse travels left to right and loops.
                      opacity: 0.3 +
                          0.7 *
                              ((_controller.value + i * 0.18) % 1.0) *
                              (1 - ((_controller.value + i * 0.18) % 1.0)),
                      child: Container(
                        width: 6,
                        height: 6,
                        margin: EdgeInsets.only(right: i == 2 ? 0 : 5),
                        decoration: const BoxDecoration(
                          color: AppColors.muted,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Composer ──────────────────────────────────────────────────────────────────

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.focusNode,
    required this.canSend,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool canSend;
  final ValueChanged<String> onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.parchment)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  textInputAction: TextInputAction.send,
                  minLines: 1,
                  maxLines: 4,
                  cursorColor: AppColors.forest,
                  onSubmitted: onSend,
                  style: const TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 14,
                    color: AppColors.charcoal,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ask about temples, festivals, gems\u2026',
                    hintStyle: const TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 13.5,
                      color: AppColors.muted,
                    ),
                    filled: true,
                    fillColor: AppColors.cream,
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: _border(AppColors.fieldBorder),
                    enabledBorder: _border(AppColors.fieldBorder),
                    focusedBorder: _border(AppColors.forest, width: 1.6),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _SendButton(enabled: canSend, onTap: () => onSend(controller.text)),
            ],
          ),
        ),
      ),
    );
  }

  static OutlineInputBorder _border(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        borderSide: BorderSide(color: color, width: width),
      );
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: 'Send message',
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: enabled ? 1 : 0.4,
        child: Material(
          color: AppColors.forest,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled ? onTap : null,
            child: const SizedBox(
              width: 46,
              height: 46,
              child: Center(
                child: AppIconView(AppIcon.send, size: 18, color: AppColors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}