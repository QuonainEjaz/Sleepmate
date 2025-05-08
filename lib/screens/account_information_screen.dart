import 'package:flutter/material.dart';
import '../widgets/custom_bottom_navigation.dart';
import '../widgets/custom_profile_drawer.dart';

class AccountInformationScreen extends StatelessWidget {
  const AccountInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF262135),
      endDrawer: const CustomProfileDrawer(),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
                            const SizedBox(height: 80),

              Positioned(
                child: const Text(
                  'Account Information',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontFamily: 'Montaga',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 140),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Table(
                    columnWidths: const {
                      0: IntrinsicColumnWidth(),
                      1: FlexColumnWidth(),
                    },
                    border: TableBorder(
                      horizontalInside: BorderSide(
                        color: Colors.white24,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    children: [
                      _InfoTableRow(label: 'Name', value: 'Yousaf Labidi'),
                      _InfoTableRow(label: 'Email', value: 'yousaflabidi12@gmail.com'),
                      _InfoTableRow(label: 'Age', value: '22'),
                      _InfoTableRow(label: 'Gender', value: 'Male'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: 2,
        screenColor: Colors.purple,
        onTap: (index) {
          // Handle tab changes if needed
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Montaga',
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Montaga',
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _InfoTableRow extends TableRow {
  _InfoTableRow({required String label, required String value})
      : super(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Montaga',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Montaga',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
} 