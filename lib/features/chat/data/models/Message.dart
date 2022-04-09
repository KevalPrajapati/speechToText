class Message {
  late String message;
  late bool isBot;
  Message({
    required this.message,
    required this.isBot,
  });
  Map<String, dynamic> toJson() => {
        'message': message,
        'isBot': isBot,
      };
  Message.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    isBot = json['isBot'];
  }
}
