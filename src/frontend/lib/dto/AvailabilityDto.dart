// GET returns days: [{date, slots:[{index, booked}]}]

class SlotDto {
  final int index;
  final bool booked;

  SlotDto({required this.index, required this.booked});

  factory SlotDto.fromJson(Map<String, dynamic> json) {
    return SlotDto(
      index: (json['index'] as num).toInt(),
      booked: (json['booked'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {"index": index, "booked": booked};
}

class AvailabilityDayDto {
  final String date; // yyyy-MM-dd
  final List<SlotDto> slots; // offered slots only (may be empty)

  AvailabilityDayDto({required this.date, required this.slots});

  factory AvailabilityDayDto.fromJson(Map<String, dynamic> json) {
    final rawSlots = (json['slots'] as List?) ?? [];
    return AvailabilityDayDto(
      date: (json['date'] as String?) ?? "",
      slots: rawSlots
          .map((s) => SlotDto.fromJson(Map<String, dynamic>.from(s)))
          .toList(),
    );
  }
}
