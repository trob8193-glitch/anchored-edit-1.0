import 'package:flutter/material.dart';

class DogSpriteFrame extends StatelessWidget {
  const DogSpriteFrame({
    super.key,
    required this.row,
    required this.col,
    this.size = 90,
  });

  static const String assetPath = 'assets/mascot/dog_sprite.png';

  static int maxColForRow(int row) => 8;

  final int row;
  final int col;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.pets, color: Colors.white70),
    );
  }
}
