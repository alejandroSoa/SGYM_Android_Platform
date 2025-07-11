import 'package:flutter/material.dart';

class CustomTopBar extends StatelessWidget {
  final String username;
  final String profileImage;
  final String? currentViewTitle;
  final bool showBackButton;
  final bool showProfileIcon;
  final VoidCallback? onBack;
  final VoidCallback? onProfileTap;
  final bool showNotificationIcon;
  final VoidCallback? onNotificationsTap;

  const CustomTopBar({
    super.key,
    required this.username,
    required this.profileImage,
    this.currentViewTitle,
    this.showBackButton = false,
    this.showProfileIcon = true,
    this.showNotificationIcon = true,
    this.onBack,
    this.onProfileTap,
    this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Lado izquierdo
          showBackButton
              ? GestureDetector(
                  onTap: onBack,
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, size: 20),
                  ),
                )
              : Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Hello,',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        username,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
          
          // Centro - Título
          if (currentViewTitle != null && showBackButton)
            Expanded(
              child: Center(
                child: Text(
                  currentViewTitle!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          
          // Lado derecho - Iconos
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showNotificationIcon)
                GestureDetector(
                  onTap: onNotificationsTap,
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications_none, size: 20),
                  ),
                ),
              if (showNotificationIcon && showProfileIcon)
                const SizedBox(width: 8),
              if (showProfileIcon)
                GestureDetector(
                  onTap: onProfileTap,
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2FF),
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: profileImage.startsWith('http')
                          ? Image.network(
                              profileImage,
                              fit: BoxFit.cover,
                              width: 40,
                              height: 40,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.person, size: 20);
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                );
                              },
                            )
                          : (profileImage != 'assets/profile.png'
                              ? Image.asset(
                                  profileImage,
                                  fit: BoxFit.cover,
                                  width: 40,
                                  height: 40,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.person, size: 20);
                                  },
                                )
                              : const Icon(Icons.person, size: 20)),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}