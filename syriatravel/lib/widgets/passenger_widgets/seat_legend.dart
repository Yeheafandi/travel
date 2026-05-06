import 'package:flutter/material.dart';

class SeatLegend extends StatelessWidget {
  final Color primaryGreen;
  const SeatLegend({super.key, required this.primaryGreen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem("متاح", Colors.white, Colors.grey[300]!),
          const SizedBox(width: 20),
          _legendItem("مختار", primaryGreen, primaryGreen),
          const SizedBox(width: 20),
          _legendItem("محجوز", Colors.grey.shade400, Colors.grey.shade400),
        ],
      ),
    );
  }

  Widget _legendItem(String text, Color fill, Color border) {
    return Row(
      children: [
        Container(
          width: 14, height: 14,
          decoration: BoxDecoration(
            color: fill,
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}