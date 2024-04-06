class Message {
  final String devid;
  final String msj;
  final DateTime date;

  Message(this.devid, this.msj, this.date);

  Message.fromJson(Map<dynamic, dynamic> json)
      : date = DateTime.parse(json['date'] as String),
        msj = json['msj'] as String,
        devid = json['devid'] as String;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'date': date.toString(),
        'msj': msj,
        'devid': devid,
      };
}
