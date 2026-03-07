import 'package:flutter/material.dart';
import 'package:bouh/View/homePage/doctorHomePage.dart';
import 'package:bouh/View/DoctorAppointment/upAppointments.dart';
import 'package:bouh/View/DoctorAppointment/prevAppointments.dart';
import 'package:bouh/View/Profile/DoctorProfile.dart';

/// Shell that holds the doctor bottom nav index and switches between
/// home (0), appointments (1), and profile (2).
class DoctorNavbar extends StatefulWidget {
  const DoctorNavbar({super.key});

  @override
  State<DoctorNavbar> createState() => _DoctorNavbarState();
}

class _DoctorNavbarState extends State<DoctorNavbar> {
  int _currentIndex = 0;

  // Key to access doctor homepage state for refresh on re-tap.
  final GlobalKey<DoctorHomePageState> _homeKey = GlobalKey();

  void _onTap(int index) {
    if (index == _currentIndex) return; // already on this tab
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final stackIndex = _currentIndex.clamp(0, 2);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: IndexedStack(
        index: stackIndex,
        children: [
          DoctorHomePage(key: _homeKey, currentIndex: _currentIndex, onTap: _onTap),
          _DoctorAppointmentsTabContent(
            currentIndex: _currentIndex,
            onTap: _onTap,
          ),
          DoctorProfileView(currentIndex: _currentIndex, onTap: _onTap),
        ],
      ),
    );
  }
}

/// Holds upcoming (القادمة) and previous (السابقة) doctor appointments.
class _DoctorAppointmentsTabContent extends StatefulWidget {
  const _DoctorAppointmentsTabContent({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  State<_DoctorAppointmentsTabContent> createState() =>
      _DoctorAppointmentsTabContentState();
}

class _DoctorAppointmentsTabContentState
    extends State<_DoctorAppointmentsTabContent> {
  /// 0 = Upcoming (القادمة), 1 = Previous (السابقة).
  int _subIndex = 0;

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: _subIndex,
      children: [
        AppointmentsScreen(
          currentIndex: widget.currentIndex,
          onTap: widget.onTap,
          onSwitchToPrevious: () => setState(() => _subIndex = 1),
        ),
        PrevAppointmentsScreen(
          currentIndex: widget.currentIndex,
          onTap: widget.onTap,
          onSwitchToUpcoming: () => setState(() => _subIndex = 0),
        ),
      ],
    );
  }
}
