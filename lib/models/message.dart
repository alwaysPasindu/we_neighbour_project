class Message {
  final String senderId;
  final String text;
  final int timestamp;

  Message({required this.senderId, required this.text, required this.timestamp});

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['sender_id'],
      text: map['text'],
      timestamp: map['timestamp'],
    );
  }
}