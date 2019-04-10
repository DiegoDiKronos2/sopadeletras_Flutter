import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:grid_flame/game.dart';

class Backyard {
  final MainGame game;
  Rect bgRect;

  Backyard(this.game) {
    bgRect = Rect.fromLTWH(
      0,
      0,
      game.tileSize * (game.gridSize+1),
      game.tileSize * (game.gridSize+16),
    );
  }

  void render(Canvas c) {
    Paint p = Paint();
    p.color = Colors.grey;
    c.drawRect(bgRect, p);
  }

  void update(double t) {}
}
