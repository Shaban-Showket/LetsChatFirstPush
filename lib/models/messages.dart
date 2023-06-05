class Message {
  Message({
    required this.fromId,
    required this.read,
    required this.toId,
    required this.message,
    required this.type,
    required this.sent,
  });
  late final String fromId;
  late final String read;
  late final String toId;
  late final String message;
  late final Type type;
  late final String sent;

  Message.fromJson(Map<String, dynamic> json) {
    fromId = json['fromId'].toString();
    read = json['read'].toString();
    toId = json['toId'].toString();
    message = json['message'].toString();
    type = json['type'].toString() == Type.image.name ? Type.image : Type.text;
    sent = json['sent'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['fromId'] = fromId;
    data['read'] = read;
    data['toId'] = toId;
    data['message'] = message;
    data['type'] = type.name;
    data['sent'] = sent;
    return data;
  }
}

enum Type { text, image }
