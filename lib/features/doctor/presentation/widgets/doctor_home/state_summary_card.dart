import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../domain/entities/stat_summary_entity.dart';

class StatSummaryCard extends StatelessWidget {
  const StatSummaryCard({super.key, required this.data});

  final StatSummaryEntity data;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      // padding: const EdgeInsetsDirectional.fromSTEB(8, 6, 8, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: data.colors,
        ),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.black12, width: 0.6),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowBlack25,
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            start: 8,
            top: 6,
            child: Text(
              data.title.tr(context),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.doctorStatTitleRedDarkest13ExtraBold,
            ),
          ),

          Align(
            alignment: AlignmentDirectional.bottomEnd,
            child: SizedBox(
              width: 100,
              height: 35,
              child: Stack(
                alignment: AlignmentDirectional.bottomEnd,
                children: [
                  Positioned(
                    right: 0,
                    left: 0,
                    bottom: 0,
                    child: Opacity(
                      opacity: 0.9,
                      child: SizedBox(
                        width: 100,
                        height: 35,
                        child: SvgPicture.asset(
                          data.image,
                          fit: BoxFit.fill,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox(),
                        ),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    end: 8,
                    bottom: 6,
                    child: Text(
                      data.value,
                      style:
                          AppTextStyles.doctorStatValueGreenMintSnow16ExtraBold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
