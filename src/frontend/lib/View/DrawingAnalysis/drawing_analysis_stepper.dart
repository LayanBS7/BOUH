import 'package:flutter/material.dart';
import 'package:bouh/theme/base_themes/colors.dart';
import 'package:bouh/theme/base_themes/typography.dart';

//DRAWING ANALYSIS STEPPER (shared across all 3 steps)

class DrawingAnalysisStepper extends StatelessWidget {
  //Which step is active: 0 = upload drawing, 1 = analyze, 2 = show result
  final int currentStep;

  const DrawingAnalysisStepper({super.key, required this.currentStep});

  static const List<String> _stepLabels = ['التحميل', 'التحليل', 'النتيجة'];

  static int get _lastStepIndex => _stepLabels.length - 1;

  /// When on the last page, the last step is shown as completed immediately (no delay).
  static bool _isStepCompleted(int stepIndex, int currentStep) {
    if (stepIndex < currentStep) return true;
    if (stepIndex == currentStep && currentStep == _lastStepIndex) return true;
    return false;
  }

  static bool _isStepActive(int stepIndex, int currentStep) {
    return stepIndex == currentStep && currentStep != _lastStepIndex;
  }

  //Main build
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, right: 32, top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        // the build: [step0] [dots] [step1] [dots] [step2]
        children: List.generate(_stepLabels.length * 2 - 1, (index) {
          if (index.isOdd) {
            // Dots between steps (animate to primary when previous step done)
            final stepIndex = index ~/ 2;
            final isCompleted = _isStepCompleted(stepIndex, currentStep);
            return Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _ConnectorDots(isCompleted: isCompleted),
                ),
              ),
            );
          }

          final stepIndex = index ~/ 2;
          final isCompleted = _isStepCompleted(stepIndex, currentStep);
          final isActive = _isStepActive(stepIndex, currentStep);

          final stepContent = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? BColors.primary : null,
                  border: Border.all(
                    color: isCompleted
                        ? BColors.primary
                        : (isActive ? BColors.primary : BColors.grey),
                    width: 2,
                  ),
                ),
                child: isCompleted
                    ? const Icon(Icons.check, color: BColors.white, size: 14)
                    : null,
              ),
              const SizedBox(height: 4),
              Text(
                _stepLabels[stepIndex],
                style: BTypography.labelText.copyWith(
                  fontSize: 16,
                  color: isCompleted || isActive
                      ? BColors.primary
                      : BColors.darkGrey,
                ),
              ),
            ],
          );
          // Pop-in for current step (including last): dots fill then step pops in
          if (stepIndex == currentStep) {
            return _StepPopIn(
              currentStep: currentStep,
              stepIndex: stepIndex,
              child: stepContent,
            );
          }
          return stepContent;
        }),
      ),
    );
  }
}

//Delays then pops in the step (after connector dots finish)
class _StepPopIn extends StatefulWidget {
  final int currentStep;
  final int stepIndex;
  final Widget child;

  const _StepPopIn({
    required this.currentStep,
    required this.stepIndex,
    required this.child,
  });

  @override
  State<_StepPopIn> createState() => _StepPopInState();
}

class _StepPopInState extends State<_StepPopIn> {
  bool _popStarted = false;

  static const _dotFillDuration = Duration(milliseconds: 500);

  @override
  void didUpdateWidget(_StepPopIn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stepIndex == widget.currentStep && !_popStarted) {
      final delay = (widget.stepIndex == 0 && widget.currentStep == 0)
          ? Duration.zero
          : _dotFillDuration;
      Future.delayed(delay, () {
        if (mounted) setState(() => _popStarted = true);
      });
    }
    if (widget.stepIndex != widget.currentStep) _popStarted = false;
  }

  @override
  void initState() {
    super.initState();
    if (widget.stepIndex == widget.currentStep) {
      final delay = (widget.stepIndex == 0 && widget.currentStep == 0)
          ? Duration.zero
          : _dotFillDuration;
      Future.delayed(delay, () {
        if (mounted) setState(() => _popStarted = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_popStarted) return widget.child;
    return TweenAnimationBuilder<double>(
      key: ValueKey('pop-${widget.currentStep}'),
      tween: Tween(begin: 1.25, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.elasticOut,
      builder: (context, value, child) =>
          Transform.scale(scale: value, child: child),
      child: widget.child,
    );
  }
}

//Dots between steps: fill one by one, then done (for next step to pop)
class _ConnectorDots extends StatefulWidget {
  final bool isCompleted;

  const _ConnectorDots({required this.isCompleted});

  @override
  State<_ConnectorDots> createState() => _ConnectorDotsState();
}

class _ConnectorDotsState extends State<_ConnectorDots>
    with SingleTickerProviderStateMixin {
  static const double _dotSize = 6;
  static const double _spacing = 38;
  static const int _dotCount = 3;
  static const Duration _fillDuration = Duration(milliseconds: 500);

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _fillDuration);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.linear);
    if (widget.isCompleted) _controller.forward();
  }

  @override
  void didUpdateWidget(_ConnectorDots oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCompleted && !oldWidget.isCompleted) {
      _controller.forward(from: 0);
    } else if (!widget.isCompleted) {
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final t = _animation.value;
        //Each dot fills when progress passes its threshold (0.2, 0.45, 0.7)
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_dotCount, (i) {
            final threshold = (i + 1) / (_dotCount + 1);
            final filled = t >= threshold;
            return Padding(
              padding: EdgeInsets.only(
                left: i == 0 ? 0 : _spacing / 2,
                right: i == _dotCount - 1 ? 0 : _spacing / 2,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                width: _dotSize,
                height: _dotSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: filled ? BColors.primary : BColors.darkGrey,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}