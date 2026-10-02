import '../navigation/app_router.dart';
import 'mock_data.dart';
import 'models.dart';

/// A tappable follow-up rendered under an assistant message.
///
/// A prompt re-sends [label] as the next question; a link opens [screen]
/// instead, which is how the assistant hands the traveller over to the screen
/// that actually does the work.
class ChatAction {
  const ChatAction.prompt(this.label) : screen = null;

  const ChatAction.link(this.label, this.screen);

  final String label;
  final AppScreen? screen;
}

/// One line of the conversation.
///
/// [fromUser] picks the bubble styling, and [actions] are the follow-ups worth
/// showing — only the most recent assistant message renders them.
class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.fromUser,
    this.actions = const <ChatAction>[],
  });

  final String text;
  final bool fromUser;
  final List<ChatAction> actions;
}

/// The heritage assistant behind the home screen's chat button.
///
/// A stand-in for the real model, in the same spirit as [AuthService]: it takes
/// and returns the types a hosted endpoint would, so swapping the body for an
/// HTTP call is a local change. Until then it answers from the app's own content
/// — the same festivals, sites, gems and guides the other screens render — so
/// nothing it says can drift from what the traveller sees when they tap through.
class ChatService {
  ChatService();

  static final ChatService instance = ChatService();

  /// Delay of the fake round-trip, so the "typing" state is visible.
  static const Duration latency = Duration(milliseconds: 700);

  /// Follow-ups offered on the opening message.
  static const List<ChatAction> starters = <ChatAction>[
    ChatAction.prompt('What is on this month?'),
    ChatAction.prompt('Suggest a 3-day plan'),
    ChatAction.link('Festival calendar', AppScreen.calendar),
    ChatAction.link('Hidden gems', AppScreen.hiddenGems),
  ];

  /// The first thing the assistant says.
  ChatMessage greeting() => const ChatMessage(
        text: 'Namaste! I am your Nepal heritage guide. Ask me about entry '
            'tickets, festivals, hidden gems, local guides or the weather, and '
            'I will point you to the right place in the app.',
        fromUser: false,
        actions: starters,
      );

  /// Answers [question], after the fake round-trip delay.
  Future<ChatMessage> ask(String question) async {
    await Future<void>.delayed(latency);
    return ChatMessage(text: _replyTo(question), fromUser: false, actions: _actionsFor(question));
  }

  String _replyTo(String question) {
    final String q = question.toLowerCase();

    if (_matches(q, <String>['hi', 'hello', 'hey', 'namaste', 'salam'])) {
      return 'Namaste! Good to see you. I can help with tickets, festivals, '
          'hidden gems and guides. What are you planning?';
    }
    if (_matches(q, <String>['thank', 'thanks', 'shukriya'])) {
      return 'You are welcome. Anything else before you head out?';
    }
    if (_matches(q, <String>['ticket', 'book', 'booking', 'entry', 'fee', 'pass', 'qr', 'price'])) {
      return _ticketReply();
    }
    if (_matches(q, <String>['festival', 'dashain', 'tihar', 'indra', 'jatra', 'holi', 'yomari', 'shivaratri', 'month'])) {
      return _festivalReply(q);
    }
    if (_matches(q, <String>['gem', 'trek', 'trail', 'hidden', 'nagarkot', 'shivapuri', 'offbeat', 'off-beat', 'viewpoint'])) {
      return _gemReply();
    }
    if (_matches(q, <String>['temple', 'heritage', 'site', 'pashupati', 'boudha', 'patan', 'stupa', 'durbar', 'unesco'])) {
      return _heritageReply();
    }
    if (_matches(q, <String>['guide', 'tour', 'local', 'photography', 'english'])) {
      return _guideReply();
    }
    if (_matches(q, <String>['weather', 'temperature', 'forecast', 'rain', 'cold', 'hot'])) {
      return _weatherReply();
    }
    if (_matches(q, <String>['plan', 'itinerary', 'day', 'trip', 'visit', 'route'])) {
      return _planReply();
    }
    return _fallbackReply();
  }

  /// True when [question] contains any of [keywords] as a whole word.
  ///
  /// Word-boundary matched so "plan" does not fire on "planning permission",
  /// which matters because several of the intents share prefixes.
  bool _matches(String question, List<String> keywords) {
    for (final String keyword in keywords) {
      if (RegExp('(^|[^a-z])${RegExp.escape(keyword)}([^a-z]|\$)').hasMatch(question)) {
        return true;
      }
    }
    return false;
  }

  List<ChatAction> _actionsFor(String question) {
    final String q = question.toLowerCase();
    if (_matches(q, <String>['ticket', 'book', 'booking', 'entry', 'fee', 'pass', 'qr', 'price'])) {
      return const <ChatAction>[ChatAction.link('Open QR Wallet', AppScreen.qrWallet)];
    }
    if (_matches(q, <String>['festival', 'dashain', 'tihar', 'indra', 'jatra', 'holi', 'yomari', 'shivaratri', 'month'])) {
      return const <ChatAction>[ChatAction.link('See the calendar', AppScreen.calendar)];
    }
    if (_matches(q, <String>['gem', 'trek', 'trail', 'hidden', 'nagarkot', 'shivapuri', 'offbeat', 'off-beat', 'viewpoint'])) {
      return const <ChatAction>[ChatAction.link('Browse gems', AppScreen.hiddenGems)];
    }
    if (_matches(q, <String>['temple', 'heritage', 'site', 'pashupati', 'boudha', 'patan', 'stupa', 'durbar', 'unesco'])) {
      return const <ChatAction>[ChatAction.link('View the site', AppScreen.heritageDetail)];
    }
    if (_matches(q, <String>['guide', 'tour', 'local', 'photography', 'english'])) {
      return const <ChatAction>[ChatAction.link('See guides', AppScreen.guideProfile)];
    }
    if (_matches(q, <String>['plan', 'itinerary', 'day', 'trip', 'visit', 'route'])) {
      return const <ChatAction>[
        ChatAction.prompt('What is on this month?'),
        ChatAction.link('My tickets', AppScreen.qrWallet),
      ];
    }
    return const <ChatAction>[
      ChatAction.prompt('Suggest a 3-day plan'),
      ChatAction.prompt('Where can I buy an entry ticket?'),
    ];
  }

  String _ticketReply() {
    final String lines = MockData.heritageSites
        .map((HeritageSite s) => '• ${s.name} — ${s.entryFee}')
        .join('\n');
    return 'Entry is booked in the app, and the ticket lands in your QR wallet '
        'straight after payment.\n\n$lines\n\nOne adult is NPR '
        '${MockData.adultPrice} and a child NPR ${MockData.childPrice}.';
  }

  String _festivalReply(String question) {
    final Festival featured = MockData.featuredFestival;
    final String upcoming = MockData.festivals
        .take(3)
        .map((Festival f) => '${f.name} (${f.date})')
        .join(', ');

    // A named festival gets its own entry rather than the month's shortlist.
    for (final Festival festival in MockData.festivals) {
      if (question.contains(festival.name.toLowerCase().split(' ').first)) {
        return '${festival.name} runs ${festival.date}. '
            '${festival.description}\n\nThe calendar screen shows the days it '
            'covers, so tickets and guides can be lined up around it.';
      }
    }
    return '${featured.name} is next — ${featured.date}, at Kathmandu Durbar '
        'Square. After that: $upcoming.\n\nFestival days are the busiest of '
        'the year, so book tickets and a guide a few weeks ahead.';
  }

  String _gemReply() {
    final String lines = MockData.gems
        .take(3)
        .map((HiddenGem g) => '• ${g.name} — ${g.category}, ${g.distance} away, rated ${g.rating}')
        .join('\n');
    return 'The gem list is verified by locals, not by us, so every spot is '
        'still a secret.\n\n$lines';
  }

  String _heritageReply() {
    final String lines = MockData.heritageSites
        .map((HeritageSite s) => '• ${s.name} — ${s.location}, rated ${s.rating}')
        .join('\n');
    return 'Four of the valley sites are open to visitors with a ticket:\n\n$lines\n\n'
        'Pashupatinath is the one to start with — go early, before the '
        'pilgrims and the coaches.';
  }

  String _guideReply() {
    final String lines = MockData.guides
        .map((Guide g) => '• ${g.name} — ${g.specialty}, ${g.price}, rated ${g.rating}')
        .join('\n');
    return 'A licensed local guide turns a temple visit into a story. These '
        'three are available this week:\n\n$lines\n\nBook half a day for one '
        'site, or a full day to cover the valley.';
  }

  String _weatherReply() {
    final WeatherDay today = MockData.today;
    final String outlook = MockData.forecast
        .map((WeatherDay d) => '${d.label} ${d.temp}')
        .join('  ·  ');
    return 'Right now in ${today.place} it is ${today.temp} and ${today.condition.toLowerCase()}.\n\n'
        '$outlook\n\nOctober mornings in the valley are cool enough for a coat '
        'and clear enough for the Shivapuri sunrise walk.';
  }

  String _planReply() =>
      'A comfortable three days in the valley:\n\n'
      'Day 1 — Pashupatinath in the morning, then the Boudhanath Stupa at '
      'sunset.\n'
      'Day 2 — Patan Durbar Square with a local guide, and the hidden gem '
      'list on the way back.\n'
      'Day 3 — Shivapuri Peak Trail at first light, or Nagarkot if the '
      'forecast is clear.\n\nTell me which festivals fall inside your dates and '
      'I will work them around the plan.';

  String _fallbackReply() =>
      'I do not have a confident answer for that one yet. I do know our '
      'festivals, entry tickets, hidden gems, guides and the forecast — '
      'try one of these.';
}