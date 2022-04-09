class Chat {
  String? bot;
  String? human;
  int index = 0;

  Chat({this.bot, this.human, required this.index});

  Chat.fromJson(Map<String, dynamic> json, this.index) {
    bot = json['bot'];
    human = json['human'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['bot'] = bot;
    data['human'] = human;
    data['index'] = index;
    return data;
  }
}
