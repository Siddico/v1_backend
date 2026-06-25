import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'story_item.dart';

class StoryAvatarChip extends StatelessWidget {
  const StoryAvatarChip({super.key, required this.item});

  final StoryItem item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 65,
      child: Column(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(item.image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.doctorStoryAvatarName(
              item.name == 'Your story',
            ),
          ),
        ],
      ),
    );
  }
}
