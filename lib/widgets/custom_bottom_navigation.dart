import 'package:flutter/material.dart';
import '../utils/app_constants.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey,
            width: 0.2,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            icon: Icons.arrow_back_ios,
            index: 0,
            isSelected: currentIndex == 0,
            onTap: () {
              onTap(0);
              Navigator.pop(context);
            },
          ),
          _buildNavItem(
            icon: Icons.home_outlined,
            index: 1,
            isSelected: currentIndex == 1,
            onTap: () {
              onTap(1);
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppConstants.homeRoute,
                (route) => false,
              );
            },
          ),
          _buildNavItem(
            icon: Icons.person_outline,
            index: 2,
            isSelected: currentIndex == 2,
            onTap: () {
              onTap(2);
              Navigator.pushNamed(context, AppConstants.profileRoute);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        child: Icon(
          icon,
          color: isSelected ? const Color(0xFF2D2041) : Colors.grey,
          size: 24,
        ),
      ),
    );
  }
} 