class ChatRoom {
  final String id;
  final List<String> participantIds;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String lastMessageSenderId;
  final Map<String, bool> readStatus;

  ChatRoom({
    required this.id,
    required this.participantIds,
    this.lastMessage = '',
    DateTime? lastMessageTime,
    this.lastMessageSenderId = '',
    Map<String, bool>? readStatus,
  }) : 
    lastMessageTime = lastMessageTime ?? DateTime.now(),
    readStatus = readStatus ?? {};

  factory ChatRoom.fromMap(Map<String, dynamic> map, String id) {
    return ChatRoom(
      id: id,
      participantIds: List<String>.from(map['participantIds'] ?? []),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: map['lastMessageTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['lastMessageTime']) 
          : DateTime.now(),
      lastMessageSenderId: map['lastMessageSenderId'] ?? '',
      readStatus: Map<String, bool>.from(map['readStatus'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participantIds': participantIds,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.millisecondsSinceEpoch,
      'lastMessageSenderId': lastMessageSenderId,
      'readStatus': readStatus,
    };
  }
}
