import 'dart:convert';

class TimeSlotResponse {
  List<TimeSlotDatum>? data;
  String? dateText;
  String? selectDateText;
  bool? success;

  TimeSlotResponse({
    this.data,
    this.dateText,
    this.selectDateText,
    this.success,
  });

  factory TimeSlotResponse.fromRawJson(String str) =>
      TimeSlotResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TimeSlotResponse.fromJson(Map<String, dynamic> json) =>
      TimeSlotResponse(
        data: json["data"] == null
            ? []
            : List<TimeSlotDatum>.from(
                json["data"]!.map((x) => TimeSlotDatum.fromJson(x))),
        dateText: json["date_text"],
        selectDateText: json["select_date_text"],
        success: json["success"],
      );

  Map<String, dynamic> toJson() => {
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "date_text": dateText,
        "select_date_text": selectDateText,
        "success": success,
      };
}

class TimeSlotDatum {
  String? timeSlot;
  String? timeSlotText;

  TimeSlotDatum({
    this.timeSlot,
    this.timeSlotText,
  });

  factory TimeSlotDatum.fromRawJson(String str) =>
      TimeSlotDatum.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TimeSlotDatum.fromJson(Map<String, dynamic> json) => TimeSlotDatum(
        timeSlot: json["time_slot"],
        timeSlotText: json["time_slot_text"],
      );

  Map<String, dynamic> toJson() => {
        "time_slot": timeSlot,
        "time_slot_text": timeSlotText,
      };
}
