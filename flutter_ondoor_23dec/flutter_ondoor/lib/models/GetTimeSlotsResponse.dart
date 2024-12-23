import 'dart:convert';

class GetTimeSlotResponse {
  int? statusCode;
  bool? success;
  String? message;
  String? statusText;
  List<TimeSlotData>? data;
  String? noOfDayAllowedForCalendar;
  String? timeslotPopupHeading;

  GetTimeSlotResponse(
      {this.success,
      this.message,
      this.data,
      this.noOfDayAllowedForCalendar,
      this.statusCode,
      this.statusText,
      this.timeslotPopupHeading});
  factory GetTimeSlotResponse.fromJson(String str) =>
      GetTimeSlotResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory GetTimeSlotResponse.fromMap(Map<String, dynamic> json) =>
      GetTimeSlotResponse(
          success: json['success'] ?? false,
          message: json['message'] ?? "",
          noOfDayAllowedForCalendar:
              json['no_of_day_allowed_for_calendar'] ?? "",
          timeslotPopupHeading: json['timeslot_popup_heading'] ?? "",
          data: json['data'] == null
              ? []
              : List<TimeSlotData>.from(
                  json["data"]!.map((x) => TimeSlotData.fromMap(x))),
          statusCode: json['statusCode'] ?? 0,
          statusText: json['statusText'] ?? "");

  Map<String, dynamic> toMap() => {
        "success": success,
        "message": message,
        "no_of_day_allowed_for_calendar": noOfDayAllowedForCalendar,
        "timeslot_popup_heading": timeslotPopupHeading,
        "statusText": statusText,
        "statusCode": statusCode
      };
}

class TimeSlotData {
  String? date;
  String? dateText;
  String? selectDateText;
  List<Timeslots>? timeslots;

  TimeSlotData({this.date, this.dateText, this.selectDateText, this.timeslots});
  factory TimeSlotData.fromJson(String str) =>
      TimeSlotData.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory TimeSlotData.fromMap(Map<String, dynamic> json) => TimeSlotData(
        date: json['date'] ?? "",
        dateText: json['date_text'] ?? "",
        selectDateText: json['select_date_text'] ?? "",
        timeslots: json['timeslots'] == null
            ? []
            : List<Timeslots>.from(
                json["timeslots"]!.map((x) => Timeslots.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "date": date,
        "date_text": dateText,
        "select_date_text": selectDateText,
      };
}

class Timeslots {
  String? timeSlot;
  int? status;
  String? timeSlotText;
  String? selectText;

  Timeslots({this.timeSlot, this.status, this.timeSlotText, this.selectText});

  factory Timeslots.fromJson(String str) => Timeslots.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Timeslots.fromMap(Map<String, dynamic> json) => Timeslots(
        timeSlot: json['time_slot'] ?? "",
        status: json['status'] ?? 0,
        timeSlotText: json['time_slot_text'] ?? "",
        selectText: json['select_text'] ?? "",
      );

  Map<String, dynamic> toMap() => {
        "time_slot": timeSlot,
        "status": status,
        "time_slot_text": timeSlotText,
        "select_text": selectText
      };
}
