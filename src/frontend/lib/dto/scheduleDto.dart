class TimeSlotDto {
  final int index;
  final bool booked;

  TimeSlotDto({required this.index, required this.booked});

  factory TimeSlotDto.fromJson(Map<String, dynamic> json) {
    return TimeSlotDto(
      index: (json['index'] as num).toInt(),
      booked: json['booked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'index': index, 'booked': booked};
  }
}

class ScheduleDto {
  final String date;
  final List<TimeSlotDto> timeSlots;

  ScheduleDto({required this.date, required this.timeSlots});

  factory ScheduleDto.fromJson(Map<String, dynamic> json) {
    return ScheduleDto(
      date: (json['date'] ?? '').toString(),
      timeSlots:
          (json['timeSlots'] as List?)
              ?.map((e) => TimeSlotDto.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'timeSlots': timeSlots.map((e) => e.toJson()).toList(),
    };
  }
}
