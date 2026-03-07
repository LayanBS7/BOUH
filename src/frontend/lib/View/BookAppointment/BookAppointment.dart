import 'package:bouh/View/BookAppointment/ApointmentDetails.dart';
import 'package:flutter/material.dart';
import 'package:bouh/theme/base_themes/colors.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:bouh/services/scheduleService.dart';
import 'package:bouh/services/childrenService.dart';
import 'package:bouh/dto/scheduleDto.dart';
import 'package:bouh/dto/childDto.dart';
import 'package:bouh/authentication/AuthSession.dart';

class BookingView extends StatefulWidget {
  final String doctorId;

  const BookingView({super.key, required this.doctorId});

  @override
  State<BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<BookingView> {
  final ChildrenService _childrenService = ChildrenService();

  List<ChildDto> children = [];
  String? selectedChildId;

  DateTime d(int y, int m, int d) => DateTime(y, m, d);

  late DateTime focusedDay;
  DateTime? selectedDay;

  int selectedTimeIndex = -1;

  bool isLoadingSchedule = false;
  bool isLoadingChildren = false;

  String? scheduleError;
  String? childrenError;

  ScheduleDto? selectedSchedule;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    focusedDay = DateTime(now.year, now.month, now.day);
    selectedDay = DateTime(now.year, now.month, now.day);
    _loadChildren();
    _loadScheduleForSelectedDay();
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  String _iso(DateTime dt) => "${dt.year}-${_two(dt.month)}-${_two(dt.day)}";

  Future<void> _loadChildren() async {
    setState(() {
      isLoadingChildren = true;
      childrenError = null;
    });

    try {
      final caregiverId = AuthSession.instance.userId;

      if (caregiverId == null || caregiverId.isEmpty) {
        throw Exception("No caregiverId found in session.");
      }

      final result = await _childrenService.getChildren(caregiverId);

      setState(() {
        children = result;
        if (children.isNotEmpty) {
          selectedChildId = children.first.childId;
        }
        isLoadingChildren = false;
      });

      print("Loaded children count = ${children.length}");
    } catch (e) {
      setState(() {
        childrenError = e.toString();
        isLoadingChildren = false;
      });
    }
  }

  Future<void> _loadScheduleForSelectedDay() async {
    if (selectedDay == null) return;

    setState(() {
      isLoadingSchedule = true;
      scheduleError = null;
      selectedSchedule = null;
      selectedTimeIndex = -1;
    });

    try {
      final date = _iso(selectedDay!);

      print("BookingView doctorId = ${widget.doctorId}");
      print("BookingView selected date = $date");

      final schedule = await ScheduleService.getDoctorScheduleByDate(
        doctorId: widget.doctorId,
        date: date,
      );

      setState(() {
        selectedSchedule = schedule;
        isLoadingSchedule = false;
      });
    } catch (e) {
      setState(() {
        scheduleError = e.toString();
        isLoadingSchedule = false;
      });
    }
  }

  String _slotLabel(int index) {
    final totalMinutes = index * 30;
    final hour = 16 + (totalMinutes ~/ 60);
    final minute = totalMinutes % 60;

    final nextTotal = totalMinutes + 30;
    final hour2 = 16 + (nextTotal ~/ 60);
    final minute2 = nextTotal % 60;

    String fmt(int h, int m) {
      final hh = h > 12 ? h - 12 : h;
      return "$hh:${m.toString().padLeft(2, '0')}";
    }

    return "${fmt(hour, minute)} - ${fmt(hour2, minute2)} مساءً";
  }

  bool _isAvailable(DateTime day) {
    if (selectedDay == null) return false;

    return isSameDay(day, selectedDay) &&
        selectedSchedule != null &&
        selectedSchedule!.timeSlots.isNotEmpty;
  }

  List<TimeSlotDto> get availableTimeSlots {
    if (selectedSchedule == null) return [];
    return selectedSchedule!.timeSlots
        .where((slot) => slot.booked == false)
        .toList();
  }

  ChildDto? get selectedChild {
    if (selectedChildId == null) return null;
    try {
      return children.firstWhere((c) => c.childId == selectedChildId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            "الطفل",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.black.withOpacity(0.75),
            ),
          ),
        ),
        const SizedBox(height: 10),

        Align(
          alignment: Alignment.centerRight,
          child: Container(
            height: 44,
            width: 160,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.88),
              border: Border.all(color: Colors.black.withOpacity(0.10)),
            ),
            child: isLoadingChildren
                ? const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : childrenError != null
                ? Center(
                    child: Text(
                      "خطأ",
                      style: TextStyle(
                        color: Colors.red.shade400,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : children.isEmpty
                ? const Center(
                    child: Text(
                      "لا يوجد أطفال",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      dropdownColor: Colors.white,
                      value: selectedChildId,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: children
                          .map(
                            (child) => DropdownMenuItem(
                              value: child.childId,
                              child: Text(
                                child.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => selectedChildId = v);
                      },
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 20),

        Align(
          alignment: Alignment.centerRight,
          child: Text(
            "تواريخ الحجز المتاحة",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: BColors.textBlack,
            ),
          ),
        ),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(9.24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 14,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: TableCalendar(
            locale: 'ar',
            firstDay: DateTime.utc(2026, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: focusedDay,
            startingDayOfWeek: StartingDayOfWeek.sunday,
            availableGestures: AvailableGestures.horizontalSwipe,
            selectedDayPredicate: (day) =>
                selectedDay != null && isSameDay(day, selectedDay),
            onDaySelected: (sel, foc) {
              setState(() {
                selectedDay = sel;
                focusedDay = foc;
              });
              _loadScheduleForSelectedDay();
            },
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronIcon: const Icon(Icons.chevron_left),
              rightChevronIcon: const Icon(Icons.chevron_right),
              titleTextStyle: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.black.withOpacity(0.75),
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.black.withOpacity(0.55),
              ),
              weekendStyle: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.black.withOpacity(0.55),
              ),
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              isTodayHighlighted: false,
              selectedDecoration: BoxDecoration(
                color: BColors.accent,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              defaultTextStyle: TextStyle(
                color: Colors.black.withOpacity(0.75),
                fontWeight: FontWeight.w700,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, _) {
                if (_isAvailable(day)) {
                  return Center(
                    child: Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade500,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        "${day.day}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
        ),

        const SizedBox(height: 18),

        Align(
          alignment: Alignment.centerRight,
          child: Text(
            "الأوقات المتاحة",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.black.withOpacity(0.75),
            ),
          ),
        ),
        const SizedBox(height: 10),

        if (isLoadingSchedule)
          const CircularProgressIndicator()
        else if (scheduleError != null)
          Text(scheduleError!, style: const TextStyle(color: Colors.red))
        else if (availableTimeSlots.isNotEmpty)
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - (2 * 12)) / 3;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(availableTimeSlots.length, (i) {
                  final selected = i == selectedTimeIndex;
                  final slot = availableTimeSlots[i];

                  return SizedBox(
                    width: itemWidth,
                    child: InkWell(
                      onTap: () => setState(() => selectedTimeIndex = i),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected ? BColors.accent : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected
                                ? Colors.transparent
                                : Colors.black.withOpacity(0.10),
                          ),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 8),
                                  ),
                                ]
                              : [],
                        ),
                        child: Text(
                          _slotLabel(slot.index),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? Colors.white
                                : Colors.black.withOpacity(0.75),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          )
        else
          const Text("لا توجد أوقات متاحة لهذا اليوم"),

        const SizedBox(height: 18),

        SizedBox(
          width: 220,
          height: 52,
          child: ElevatedButton(
            onPressed: selectedTimeIndex == -1 || selectedChild == null
                ? null
                : () {
                    final selectedSlot = availableTimeSlots[selectedTimeIndex];

                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (_) => AppointmentDetailsView(
                          doctorName: "الطبيبة",
                          timeRange: _slotLabel(selectedSlot.index),
                          dateText: _iso(selectedDay!),
                          childName: selectedChild!.name,
                          price: 130,
                          total: 149.5,
                          caregiverId: AuthSession.instance.userId ?? "",
                          doctorId: widget.doctorId,
                          childId: selectedChild!.childId,
                          timeSlotId: selectedSlot.index.toString(),
                        ),
                      ),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: BColors.accent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(54.52),
              ),
            ),
            child: const Text(
              "حجز",
              style: TextStyle(
                fontSize: 20.44,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
