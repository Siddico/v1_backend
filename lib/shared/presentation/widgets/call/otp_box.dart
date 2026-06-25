import 'package:flutter/material.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';

class OtpBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String) onChanged;
  final VoidCallback onBackspace;
  final Color textColor;
  final Color activeBorderColor;
  final double boxSize;

  const OtpBox({super.key, 
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
    required this.textColor,
    required this.activeBorderColor,
    required this.boxSize,
  });

  @override
  State<OtpBox> createState() => OtpBoxState();
}

class OtpBoxState extends State<OtpBox> {
  String _previousValue = '';

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleTextChange);
    widget.focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChange);
    widget.focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  void _handleTextChange() {
    final currentValue = widget.controller.text;

    // Detect backspace (text was deleted)
    if (currentValue.isEmpty && _previousValue.isNotEmpty) {
      widget.onBackspace();
    }

    _previousValue = currentValue;
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = widget.focusNode.hasFocus;

    return Container(
      width: widget.boxSize,
      height: widget.boxSize,
      decoration: ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: isFocused ? 2 : 1,
            color: isFocused ? widget.activeBorderColor : AppColors.otpBorder,
          ),
          borderRadius: BorderRadius.circular(21),
        ),
        shadows: [
          BoxShadow(
            color: AppColors.shadowBlack25,
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: SizedBox(
        width: widget.boxSize * 0.58,
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          onChanged: widget.onChanged,
          style: AppTextStyles.textStyleFontsize20WithWeight600AndBlackColor
              .copyWith(
                fontSize: widget.boxSize * 0.32,
                color: widget.textColor,
              ),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
