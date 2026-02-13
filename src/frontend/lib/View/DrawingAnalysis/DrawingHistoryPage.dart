import 'package:flutter/material.dart';
import 'package:bouh/theme/base_themes/colors.dart';
import 'package:bouh/theme/base_themes/radius.dart';
import 'package:bouh/theme/base_themes/typography.dart';
import 'package:bouh/View/DrawingAnalysis/AnalysisResultsPage.dart';

//DRAWING HISTORY PAGE
//Shows previously analyzed drawings for the selected child.
//BACKEND PHASE:
//Replace mock [DrawingHistoryItem] list with API response (child id).
//Use real image paths/URLs in [DrawingHistoryItem.imagePath].


//One past drawing entry (mock until backend)(a model class, remove later)
class DrawingHistoryItem {
  final String id;
  final String dateText; //'15/2/2024'
  final String? imagePath; //null = show placeholder

  const DrawingHistoryItem({
    required this.id,
    required this.dateText,
    this.imagePath,
  });
}

class DrawingHistoryPage extends StatefulWidget {
  final String? selectedChildName;

  const DrawingHistoryPage({
    super.key,
    this.selectedChildName,
  });

  @override
  State<DrawingHistoryPage> createState() => _DrawingHistoryPageState();
}

class _DrawingHistoryPageState extends State<DrawingHistoryPage> {
  final GlobalKey _dropdownKey = GlobalKey();
  static const double _menuWidth = 280;

  String? _selectedChild;

  //Child names for dropdown
  final List<String> _childrenNames = [
    'ليان',
    'بسام',
    'خزامى',
  ];

  //Mock history: most recent first. BACKEND: fetch by _selectedChild.
  List<DrawingHistoryItem> get _drawings => [
        const DrawingHistoryItem(id: '1', dateText: '15/2/2024'),
        const DrawingHistoryItem(id: '2', dateText: '10/2/2024'),
        const DrawingHistoryItem(id: '3', dateText: '5/2/2024'),
      ];

  @override
  void initState() {
    super.initState();
    // User must select a child from the dropdown (no pre-selection).
  }

  //Main build
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BColors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              _buildBackButton(context),

              const SizedBox(height: 32),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      //Child selection dropdown
                      _buildChildDropdown(),

                      const SizedBox(height: 24),

                      _selectedChild == null
                          ? _buildEmptyState()
                          : _buildDrawingList(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
   
  Widget _buildBackButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: BColors.darkGrey,
              size: 22,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'الرسومات السابقة',
                style: BTypography.labelText.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildChildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          key: _dropdownKey,
          height: 48,
          decoration: BoxDecoration(
            color: BColors.secondry,
            borderRadius: BRadius.dropdownRadius,
            border: Border.all(color: BColors.grey, width: 1),
          ),
          child: InkWell(
            onTap: _showChildMenu,
            borderRadius: BRadius.dropdownRadius,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: BColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.people_outline,
                      color: BColors.darkGrey,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedChild ??
                          'اختر الطفل الذي تود رؤيه رسوماته',
                      style: _selectedChild != null
                          ? BTypography.dropdownSelected
                          : BTypography.dropdownHint,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: BColors.darkGrey,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showChildMenu() {
    final box =
        _dropdownKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final pos = box.localToGlobal(Offset.zero);
    final size = box.size;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final top = pos.dy + size.height;
    final left = pos.dx + size.width - _menuWidth;
    final right = screenWidth - pos.dx - size.width;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(left, top, right, 0),
      shape: RoundedRectangleBorder(
        borderRadius: BRadius.dropdownRadius,
      ),
      color: BColors.secondry,
      items: _childrenNames.asMap().entries.map((entry) {
        final index = entry.key;
        final name = entry.value;
        final itemColor =
            index.isEven ? BColors.secondry : BColors.white;

        return PopupMenuItem<String>(
          value: name,
          padding: EdgeInsets.zero,
          child: Container(
            width: _menuWidth,
            height: 48,
            color: itemColor,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            alignment: Alignment.centerRight,
            child: Text(
              name,
              textAlign: TextAlign.right,
              style: BTypography.dropdownSelected,
            ),
          ),
        );
      }).toList(),
    ).then((value) {
      if (value != null) setState(() => _selectedChild = value);
    });
  }

  /// Shown when no child is selected yet.
  /// Asset path for the empty state illustration
  static const String _emptyStateImageAsset =
      'assets/images/NoSelectedChild_PlaceHolder.png';

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              _emptyStateImageAsset,
              height: 370,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.brush_outlined,
                size: 120,
                color: BColors.darkGrey.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// List of drawing cards (shown only when a child is selected).
  Widget _buildDrawingList() {
    final drawings = _drawings;
    if (drawings.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            'لا توجد رسمات سابقة لهذا الطفل',
            style: BTypography.bodyText.copyWith(color: BColors.darkGrey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        drawings.length,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: _buildDrawingCard(drawings[index]),
        ),
      ),
    );
  }

  Widget _buildDrawingCard(DrawingHistoryItem item) {
    return Container(
      decoration: BoxDecoration(
        color: BColors.white,
        borderRadius: BorderRadius.circular(BRadius.cardLarge),
        border: Border.all(color: BColors.grey, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(BRadius.cardLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Drawing image or placeholder
            AspectRatio(
              aspectRatio: 16 / 10,
              child: item.imagePath != null
                  ? Image.asset(
                      item.imagePath!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: BColors.softGrey,
                      child: Center(
                        child: Icon(
                          Icons.draw,
                          size: 48,
                          color: BColors.darkGrey.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
            ),
            /// Date + Analyze button row
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  /// Date (grey)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: BColors.softGrey,
                      borderRadius:
                          BorderRadius.circular(BRadius.buttonMedium),
                    ),
                    child: Text(
                      item.dateText,
                      style: BTypography.labelText.copyWith(
                        color: BColors.darkGrey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  /// تحليل الرسمة (orange)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) => const AnalysisResultsPage(
                              hideStepper: true,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BColors.accent,
                        foregroundColor: BColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(BRadius.buttonMedium),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'تحليل الرسمة',
                        style: BTypography.labelText.copyWith(
                          color: BColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}