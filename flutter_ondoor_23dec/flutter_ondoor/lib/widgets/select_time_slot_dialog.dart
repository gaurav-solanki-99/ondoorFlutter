import 'package:flutter/material.dart';
import 'package:ondoor/models/GetTimeSlotsResponse.dart';
import 'package:ondoor/utils/Extension.dart';
import 'package:ondoor/utils/SizeConfig.dart';
import 'package:ondoor/utils/colors.dart';
import 'package:ondoor/widgets/AppWidgets.dart';

class SelectTimeSlotDialog extends StatefulWidget {
  GetTimeSlotResponse getTimeSlotResponse;
  SelectTimeSlotDialog({super.key, required this.getTimeSlotResponse});

  @override
  State<SelectTimeSlotDialog> createState() => _SelectTimeSlotDialogState();
}

class _SelectTimeSlotDialogState extends State<SelectTimeSlotDialog> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorName.ColorBagroundPrimary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: widget.getTimeSlotResponse.data != null
          ? widget.getTimeSlotResponse.data!.length <= 5
              ? viewforShortListLength()
              : viewForLongListLength()
          : SizedBox.shrink(),
    );
  }

  Widget viewforShortListLength() {
    return Wrap(
      children: [
        Container(
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: 5),
          decoration: const BoxDecoration(
            color: ColorName.ColorPrimary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: Row(
            children: [
              Text(
                widget.getTimeSlotResponse.timeslotPopupHeading ?? "",
                style: Appwidgets()
                    .commonTextStyle(ColorName.ColorBagroundPrimary),
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.close,
                  color: ColorName.ColorBagroundPrimary,
                ),
              ),
            ],
          ),
        ),
        // Wrapping ListView in a Flexible widget to handle different list lengths
        Container(
          child: SingleChildScrollView(
            child: Column(
              children: [
                for (var timeSlotData in widget.getTimeSlotResponse.data!)
                  Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 40,
                        padding: EdgeInsets.only(left: 10),
                        alignment: Alignment.centerLeft,
                        color: ColorName.ColorPrimary.withOpacity(.05),
                        child: Text(
                          timeSlotData.dateText ?? "",
                          style: Appwidgets()
                              .commonTextStyle(ColorName.ColorPrimary),
                        ),
                      ),
                      // ListView.builder to display timeslots
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: timeSlotData.timeslots!.length,
                        physics:
                            const NeverScrollableScrollPhysics(), // Disable inner scrolling
                        itemBuilder: (context, innerIndex) {
                          var timeSLotDateTime =
                              timeSlotData.timeslots![innerIndex];
                          return Container(
                            width: Sizeconfig.getWidth(context),
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.access_time_rounded,
                                      color: ColorName.ColorPrimary,
                                    ),
                                    10.toSpace, // Adjust spacing here
                                    Text(
                                      timeSLotDateTime.timeSlotText ?? "",
                                      style: Appwidgets()
                                          .commonTextStyle(
                                              timeSLotDateTime.status == 0
                                                  ? ColorName.textlight
                                                  : ColorName.black)
                                          .copyWith(
                                            fontSize: 15,
                                            decorationColor:
                                                ColorName.textlight,
                                            decoration:
                                                timeSLotDateTime.status == 0
                                                    ? TextDecoration.lineThrough
                                                    : TextDecoration.none,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ],
                                ),

                                10.toSpace, // Adjust spacing here
                                timeSLotDateTime.status == 0
                                    ? const SizedBox.shrink()
                                    : GestureDetector(
                                        onTap: () {
                                          var selectedDates = {
                                            "selected_Date_Text":
                                                timeSlotData.selectDateText,
                                            "selected_date": timeSlotData.date,
                                            "selected_Time":
                                                timeSLotDateTime.timeSlotText
                                          };
                                          // print(
                                          //     "SELECTED DATE >>  ${selectedDates}");
                                          Navigator.pop(context, selectedDates);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 2),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              border: Border.all(
                                                color: ColorName.ColorPrimary,
                                              )),
                                          child: Text(
                                              timeSLotDateTime.selectText ?? "",
                                              style: Appwidgets()
                                                  .commonTextStyle(
                                                      ColorName.ColorPrimary)
                                                  .copyWith(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                        ),
                                      ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget viewForLongListLength() {
    return Column(
      children: [
        Container(
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: 5),
          decoration: const BoxDecoration(
            color: ColorName.ColorPrimary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: Row(
            children: [
              Text(
                widget.getTimeSlotResponse.timeslotPopupHeading ?? "",
                style: Appwidgets()
                    .commonTextStyle(ColorName.ColorBagroundPrimary),
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.close,
                  color: ColorName.ColorBagroundPrimary,
                ),
              ),
            ],
          ),
        ),
        // Wrapping ListView in a Flexible widget to handle different list lengths
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              children: [
                for (var timeSlotData in widget.getTimeSlotResponse.data!)
                  Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 40,
                        padding: EdgeInsets.only(left: 10),
                        alignment: Alignment.centerLeft,
                        color: ColorName.ColorPrimary.withOpacity(.05),
                        child: Text(
                          timeSlotData.dateText ?? "",
                          style: Appwidgets()
                              .commonTextStyle(ColorName.ColorPrimary),
                        ),
                      ),
                      // ListView.builder to display timeslots
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: timeSlotData.timeslots!.length,
                        physics:
                            NeverScrollableScrollPhysics(), // Disable inner scrolling
                        itemBuilder: (context, innerIndex) {
                          var timeSLotDateTime =
                              timeSlotData.timeslots![innerIndex];
                          return Container(
                            width: Sizeconfig.getWidth(context),
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.access_time_rounded,
                                      color: ColorName.ColorPrimary,
                                    ),
                                    10.toSpace, // Adjust spacing here
                                    Text(
                                      timeSLotDateTime.timeSlotText ?? "",
                                      style: Appwidgets()
                                          .commonTextStyle(
                                              timeSLotDateTime.status == 0
                                                  ? ColorName.textlight
                                                  : ColorName.black)
                                          .copyWith(
                                            fontSize: 15,
                                            decorationColor:
                                                ColorName.textlight,
                                            decoration:
                                                timeSLotDateTime.status == 0
                                                    ? TextDecoration.lineThrough
                                                    : TextDecoration.none,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ],
                                ),

                                10.toSpace, // Adjust spacing here
                                timeSLotDateTime.status == 0
                                    ? const SizedBox.shrink()
                                    : GestureDetector(
                                        onTap: () {
                                          var selectedDates = {
                                            "selected_Date_Text":
                                                timeSlotData.selectDateText,
                                            "selected_date": timeSlotData.date,
                                            "selected_Time":
                                                timeSLotDateTime.timeSlotText
                                          };
                                          Navigator.pop(context, selectedDates);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 2),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              border: Border.all(
                                                color: ColorName.ColorPrimary,
                                              )),
                                          child: Text(
                                              timeSLotDateTime.selectText ?? "",
                                              style: Appwidgets()
                                                  .commonTextStyle(
                                                      ColorName.ColorPrimary)
                                                  .copyWith(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                        ),
                                      ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
