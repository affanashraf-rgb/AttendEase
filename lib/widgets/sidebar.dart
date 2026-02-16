import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Color(0xFF7C3AED)),
                SizedBox(width: 12),
                Text(
                  'AttendEase',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _sidebarItem(Icons.grid_view_rounded, 'Dashboard', 0),
          _sidebarItem(Icons.group_outlined, 'Students', 1),
          _sidebarItem(Icons.history, 'History', 2),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String label, int index) {
    bool isSelected = selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: ListTile(
        onTap: () => onItemSelected(index),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isSelected ? const Color(0xFF7C3AED) : Colors.transparent,
        leading: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey[600],
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
