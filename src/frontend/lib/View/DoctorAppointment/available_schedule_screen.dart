import 'package:flutter/material.dart';
import 'package:bouh/theme/base_themes/colors.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:bouh/dto/AvailabilityDto.dart';
import 'package:bouh/services/AvailabilityService.dart';

class AvailableScheduleScreen extends StatefulWidget {
  const AvailableScheduleScreen({super.key});

  @override
  State<AvailableScheduleScreen> createState() =>
      _AvailableScheduleScreenState();
}

class _AvailableScheduleScreenState extends State<AvailableScheduleScreen> {
  DateTime _d(int y, int m, int d) => DateTime(y, m, d);

  //Backend integeration:
  // Replace with real doctorId from your auth later
  final String doctorId = "9TuVEuc6shUgP1uq7bYrYa2BIEE2"; // !!!!!!

  late final AvailabilityService _service = AvailabilityService();

  // schedule loaded from backend (days for current+next month)
  List<AvailabilityDayDto> scheduleDays = [];

  // loading + errors
  bool isLoading = true;
  String? loadError;

  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay = DateTime.now(); //default select today

  bool isEditMode = false;

  // Store slot indexes (0..9) - matches backend offeredSlotIndexes
  final Set<int> offeredIndexesDraft = {};

  final Map<String, Set<int>> draftByDate = {};

  //Fixed slot count
  static const int slotCount = 10;

  // ─────────────────────────────────────────────────────────────
  // Date helpers
  // ─────────────────────────────────────────────────────────────
  String _two(int n) => n.toString().padLeft(2, '0');

  String _iso(DateTime dt) => "${dt.year}-${_two(dt.month)}-${_two(dt.day)}";

  DateTime _startOfMonth(DateTime dt) => DateTime(dt.year, dt.month, 1);

  DateTime _endOfNextMonth(DateTime dt) => DateTime(
    dt.year,
    dt.month + 2,
    0,
  ); //zero here means the "go one day before the first day of this month" which is why +2

  DateTime _maxAllowedDate() {
    final now = DateTime.now();
    final plus2 = DateTime(now.year, now.month + 2, now.day);
    return _d(plus2.year, plus2.month, plus2.day);
  }

  bool _isPastDay(DateTime day) {
    final now = DateTime.now();
    final onlyDateNow = _d(now.year, now.month, now.day);
    final onlyDateDay = _d(day.year, day.month, day.day);
    return onlyDateDay.isBefore(onlyDateNow);
  }

  bool _isBeyondAllowed(DateTime day) {
    final max = _maxAllowedDate();
    final onlyMax = _d(max.year, max.month, max.day);
    final onlyDay = _d(day.year, day.month, day.day);
    return onlyDay.isAfter(onlyMax);
  }

  bool _isEditableDay(DateTime day) =>
      !_isPastDay(day) && !_isBeyondAllowed(day);

  // ─────────────────────────────────────────────────────────────
  // Backend load (current month + next month always)
  // ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    focusedDay = _startOfMonth(DateTime.now());
    selectedDay = DateTime.now();
    _loadScheduleForCurrentWindow();
  }

  Future<void> _loadScheduleForCurrentWindow() async {
    setState(() {
      isLoading = true;
      loadError = null;
    });

    try {
      final now = DateTime.now();
      final fromDate = _startOfMonth(now);
      final toDate = _endOfNextMonth(now);

      final from = _iso(fromDate);
      final to = _iso(toDate);

      final days = await _service.getSchedule(
        doctorId: doctorId,
        from: from,
        to: to,
      );

      scheduleDays = days;
      draftByDate.clear();

      // When schedule loads, update draft selection for the currently selected day
      _syncDraftFromLoadedData();

      setState(() => isLoading = false);
    } catch (e) {
      setState(() {
        isLoading = false;
        loadError = e.toString();
      });
    }
  }

  void _syncDraftFromLoadedData() {
    //The bridge between backend and editable draft
    if (selectedDay == null) return;

    offeredIndexesDraft.clear();
    final day = _getDayDto(selectedDay!);
    if (day == null) return;

    // offered slots are those in day.slots regardless booked status
    for (final s in day.slots) {
      offeredIndexesDraft.add(s.index);
    }
  }

  AvailabilityDayDto? _getDayDto(DateTime day) {
    final date = _iso(day);
    try {
      return scheduleDays.firstWhere((d) => d.date == date);
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Availability for calendar highlight
  // ─────────────────────────────────────────────────────────────
  bool _isAvailable(DateTime day) {
    final dto = _getDayDto(day);
    return dto != null && dto.slots.isNotEmpty;
  }

  // ─────────────────────────────────────────────────────────────
  // Slot UI helpers
  // ─────────────────────────────────────────────────────────────
  bool _isSlotBooked(int index) {
    if (selectedDay == null) return false;
    final dto = _getDayDto(selectedDay!);
    if (dto == null) return false;
    final found = dto.slots.where((s) => s.index == index);
    if (found.isEmpty) return false;
    return found.first.booked;
  }

  // Convert slot index to UI label (4:00 -> 9:00, 30 min)
  String _slotLabel(int index) {
    // start 16:00
    final totalMinutes = index * 30;
    final hour = 16 + (totalMinutes ~/ 60);
    final minute = totalMinutes % 60;
    final nextTotal = totalMinutes + 30;
    final hour2 = 16 + (nextTotal ~/ 60);
    final minute2 = nextTotal % 60;

    String fmt(int h, int m) {
      // show Arabic PM format (مساءً)
      final hh = (h > 12) ? (h - 12) : h;
      final mm = _two(m);
      return "$hh:$mm";
    }

    return "${fmt(hour, minute)} - ${fmt(hour2, minute2)} مساءً";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BColors.lightGrey,
      appBar: AppBar(
        backgroundColor: BColors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'جدولة الأوقات المتاحة',
          style: TextStyle(
            color: BColors.textDarkestBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: BColors.textDarkestBlue),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment:
                              Alignment.centerLeft, // forces left even in RTL
                          child: _circleIconButton(
                            icon: isEditMode ? Icons.close : Icons.edit,
                            iconColor: BColors.textDarkestBlue,
                            onTap: () {
                              if (isEditMode) {
                                _cancelEdit();
                                return;
                              }

                              setState(() {
                                isEditMode = true;

                                // load current day from backend into draft
                                _syncDraftFromLoadedData();

                                // store draft for this day so it doesn't disappear when switching days
                                final key = _iso(selectedDay!);
                                draftByDate[key] = {...offeredIndexesDraft};
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        _calendarCardLikeFriend(),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Row(
                        children: const [
                          Icon(
                            Icons.info_outline,
                            color: Colors.grey,
                            size: 18,
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "الأوقات باللون الرمادي محجوزة ولا يمكن تعديلها.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Loading / error state
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: CircularProgressIndicator(),
                      )
                    else if (loadError != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.black.withOpacity(0.08),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "حدث خطأ أثناء تحميل الجدول:\n$loadError",
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _loadScheduleForCurrentWindow,
                              child: const Text("إعادة المحاولة"),
                            ),
                          ],
                        ),
                      )
                    else
                      _timeSlotsLikeFriend(),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),

            _saveButton(),
          ],
        ),
      ),

      bottomNavigationBar: _bottomNav(),
    );
  }

  Widget _calendarCardLikeFriend() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TableCalendar(
        // Backend note: requires intl date formatting initialization in main.dart.
        locale: 'ar',
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: _maxAllowedDate(),
        focusedDay: focusedDay,
        startingDayOfWeek: StartingDayOfWeek.sunday,
        availableGestures: AvailableGestures.horizontalSwipe,

        selectedDayPredicate: (day) =>
            selectedDay != null && isSameDay(day, selectedDay),

        // Prevent selecting non-editable days when in edit mode
        onDaySelected: (sel, foc) {
          setState(() {
            // 1) if editing, save current day's draft before switching
            if (isEditMode && selectedDay != null) {
              final prevKey = _iso(selectedDay!);
              draftByDate[prevKey] = {...offeredIndexesDraft};
            }

            // 2) switch day
            selectedDay = sel;
            focusedDay = foc;

            // 3) load new day's draft (if exists) else load from backend
            final key = _iso(sel);

            offeredIndexesDraft.clear();

            if (isEditMode) {
              if (draftByDate.containsKey(key)) {
                // restore previously edited draft
                offeredIndexesDraft.addAll(draftByDate[key]!);
              } else {
                // first time visiting this day -> load from backend scheduleDays
                final dayDto = _getDayDto(sel);
                if (dayDto != null) {
                  for (final s in dayDto.slots) {
                    offeredIndexesDraft.add(s.index);
                  }
                }
                draftByDate[key] = {...offeredIndexesDraft};
              }
            } else {
              // not edit mode → normal behavior
              _syncDraftFromLoadedData();
            }
          });
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
          selectedDecoration: const BoxDecoration(
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
            final isDisabled = !_isEditableDay(day);

            if (isDisabled) {
              return Center(
                child: Text(
                  "${day.day}",
                  style: const TextStyle(
                    color: Colors.grey, // grey non-editable day number
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }

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
    );
  }

  Widget _timeSlotsLikeFriend() {
    final day = selectedDay;
    if (day == null) {
      return _emptyCard("اختر يوماً لعرض الأوقات");
    }

    final editable = _isEditableDay(day);
    final canEditNow = isEditMode && editable;

    // We always show all fixed slots (0..9) so doctor can add/remove offered.
    // Booked ones are locked and shown grey.
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - (2 * 12)) / 3;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(slotCount, (i) {
                  final booked = _isSlotBooked(i);
                  final offered = offeredIndexesDraft.contains(i);

                  //If booked, it MUST remain offered
                  final effectiveOffered = booked ? true : offered;

                  final disabledTile = !canEditNow || booked;
                  final selected = effectiveOffered;

                  return SizedBox(
                    width: itemWidth,
                    child: InkWell(
                      onTap: disabledTile
                          ? null
                          : () {
                              setState(() {
                                // toggle offered
                                if (offeredIndexesDraft.contains(i)) {
                                  offeredIndexesDraft.remove(i);
                                } else {
                                  offeredIndexesDraft.add(i);
                                }

                                // store this day's draft so it persists when switching days
                                final key = _iso(selectedDay!);
                                draftByDate[key] = {...offeredIndexesDraft};
                              });
                            },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          // Colors:
                          // - booked -> grey
                          // - offered -> accent
                          // - not offered -> white
                          color: booked
                              ? Colors.grey.shade300
                              : selected
                              ? BColors.accent
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: booked
                                ? Colors.grey.shade400
                                : selected
                                ? Colors.transparent
                                : Colors.black.withOpacity(0.10),
                          ),
                          boxShadow: selected && !booked
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
                          _slotLabel(i), // time label from index
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: booked
                                ? Colors.grey.shade700
                                : selected
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
          ),
        ],
      ),
    );
  }

  Widget _emptyCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: BColors.darkGrey),
      ),
    );
  }

  bool _areSetsEqual(Set<int> a, Set<int> b) {
    if (a.length != b.length) return false;
    for (final value in a) {
      if (!b.contains(value)) return false;
    }
    return true;
  }

  void _cancelEdit() {
    setState(() {
      draftByDate.clear(); // remove all unsaved edits
      _syncDraftFromLoadedData(); // restore from backend
      isEditMode = false;
    });
  }

  Widget _saveButton() {
    final day = selectedDay;
    if (day == null) return const SizedBox.shrink();
    final editable = _isEditableDay(day);
    if (!editable) return const SizedBox.shrink();
    final canSave =
        isEditMode && draftByDate.isNotEmpty && !isLoading && loadError == null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: canSave ? BColors.primary : Colors.grey.shade400,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        // Disabled unless edit mode + editable day
        onPressed: !canSave
            ? null
            : () async {
                final date = _iso(day);

                //  Make sure booked slots remain offered (just in case)
                for (int i = 0; i < slotCount; i++) {
                  if (_isSlotBooked(i)) {
                    offeredIndexesDraft.add(i);
                  }
                }

                // Build request exactly like backend:
                // { "days": [ { "date": "...", "offeredSlotIndexes": [...] } ] }
                final key = _iso(day);
                draftByDate[key] = {...offeredIndexesDraft};

                final payloadDays = draftByDate.entries.map((e) {
                  return {
                    "date": e.key,
                    "offeredSlotIndexes": e.value.toList()..sort(),
                  };
                }).toList();

                try {
                  setState(() => isLoading = true);
                  await _service.updateSchedule(
                    doctorId: doctorId,
                    days: payloadDays,
                  );

                  // Reload schedule from backend to reflect any preserved booked flags
                  await _loadScheduleForCurrentWindow();

                  setState(() {
                    draftByDate.clear();
                    isEditMode = false; // close edit
                  });

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("تم الحفظ بنجاح")),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("فشل الحفظ: $e")));
                  }
                  setState(() => isLoading = false);
                }
              },

        child: const Text(
          'حفظ',
          style: TextStyle(color: BColors.white, fontSize: 16),
        ),
      ),
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFFE9EEF3),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black.withOpacity(0.08)),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }

  // add remaz navbar
  Widget _bottomNav() {
    return BottomNavigationBar(
      currentIndex: 1,
      selectedItemColor: BColors.primary,
      unselectedItemColor: BColors.darkGrey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'المواعيد',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
      ],
    );
  }
}
