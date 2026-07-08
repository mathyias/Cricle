class Post {
  final String author;
  final String avatarEmoji;
  final String content;
  int likes;
  int comments;
  bool likedByMe;

  Post({
    required this.author,
    required this.avatarEmoji,
    required this.content,
    required this.likes,
    required this.comments,
    this.likedByMe = false,
  });
}

class Group {
  final String name;
  final String emoji;
  final int members;

  Group({required this.name, required this.emoji, required this.members});
}

class ChatPreview {
  final String name;
  final String emoji;
  final String lastMessage;
  final String time;
  final bool unread;

  ChatPreview({
    required this.name,
    required this.emoji,
    required this.lastMessage,
    required this.time,
    this.unread = false,
  });
}

// Przykładowe dane trzymane w pamięci
List<Post> mockPosts = [
  Post(
    author: 'Ola Nowak',
    avatarEmoji: '🌸',
    content: 'Piękny dzień na spacer po parku! Kto ma ochotę dołączyć jutro rano?',
    likes: 24,
    comments: 5,
  ),
  Post(
    author: 'Kuba Wiśniewski',
    avatarEmoji: '🎮',
    content: 'Właśnie skończyłem nowy projekt w Flutterze - Liquid Glass rządzi!',
    likes: 87,
    comments: 12,
  ),
  Post(
    author: 'Mika Zielińska',
    avatarEmoji: '☕',
    content: 'Poleca ktoś dobrą kawiarnię w centrum? Szukam miejsca do pracy.',
    likes: 15,
    comments: 9,
  ),
];

List<Group> mockGroups = [
  Group(name: 'Podróże', emoji: '✈️', members: 1240),
  Group(name: 'Gaming', emoji: '🎮', members: 3890),
  Group(name: 'Fitness', emoji: '💪', members: 980),
  Group(name: 'Fotografia', emoji: '📷', members: 645),
  Group(name: 'Gotowanie', emoji: '🍳', members: 2110),
  Group(name: 'Muzyka', emoji: '🎵', members: 1755),
];

List<ChatPreview> mockChats = [
  ChatPreview(
    name: 'Ola Nowak',
    emoji: '🌸',
    lastMessage: 'Dobra, do jutra!',
    time: '12:41',
    unread: true,
  ),
  ChatPreview(
    name: 'Kuba Wiśniewski',
    emoji: '🎮',
    lastMessage: 'Widziałeś ten nowy update?',
    time: '11:02',
  ),
  ChatPreview(
    name: 'Grupa: Fitness',
    emoji: '💪',
    lastMessage: 'Mika: Kto idzie jutro na trening?',
    time: 'wczoraj',
    unread: true,
  ),
  ChatPreview(
    name: 'Mika Zielińska',
    emoji: '☕',
    lastMessage: 'Super, dzięki za polecenie!',
    time: 'wczoraj',
  ),
];