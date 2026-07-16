import 'package:flutter/material.dart';

class TopHeader extends StatelessWidget {
  final String userName;
  final String? avatarImagePath;
  final VoidCallback? onSettingsTap;

  const TopHeader({
    super.key,
    this.userName = 'Celeste',
    this.avatarImagePath,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Avatar + Greeting
          Row(
            children: [
              // Circular Avatar
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: avatarImagePath != null
                      ? Image.asset(
                          avatarImagePath!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: const Color(0xFFD9C5B2),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              // Greeting Text
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                      letterSpacing: 0.1,
                    ),
                  ),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Right: Settings Icon
          GestureDetector(
            onTap: onSettingsTap,
            child: const Icon(
              Icons.tune_rounded,
              color: Color(0xFF1A1A1A),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
