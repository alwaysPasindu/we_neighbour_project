import 'package:flutter/material.dart';

class GridIcon extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  GridIcon({required this.title, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.all(15),
          child: Icon(icon, size: 40, color: color),
        ),
        SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
