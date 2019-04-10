import 'dart:ui';
import 'package:flame/components/component.dart';
import 'package:flutter/material.dart';
import 'package:grid_flame/game.dart';

class TileSet extends Component {
  final int tileID; //Identificador final de la casilla.
  final int column; //Columna en la que se encuentra del grid.
  final int row;    //Fila en la que se encuentra del grid.

  bool hasAnswerChar = false; //Identifica si la casilla forma parte de una respuesta.
  bool clear = false;         //Identifica si la palabra ya ha sido completada.

  //Variables para la posición y renderizado.
  final MainGame game;
  ParagraphBuilder paragraph;
  Rect rect, hitbox;
  String char;
  double posx = 0;
  double posy = 0;
  Color bC = Colors.lightBlue;

  TileSet(this.game, this.char, this.tileID, this.column, this.row);

  void coordSet(double posx, double posy) {
    //Fija las posiciones que se utilizarán para los elementos del tile
    this.posx = posx;
    this.posy = posy;
  }

  void charSet(String char) {
    //Cambia la letra de la casilla.
    this.char = char;
  }

  bool isAnswer() {
    //Retorna True si forma parte de una palabra.
    return hasAnswerChar;
  }

  bool isCorrectAnswer(int id) {
    //Retorna true si forma parte de la palabra que se está respondiendo.
    if (id == tileID) {
      return true;
    } else {
      return false;
    }
  }

  void congrats() {
    //Establece el tile como respondido, cambia el color de forma permanente.
    clear = true;
    bC = Colors.green;
  }

  void reset() {
    //Restaura el color del tile si se ha seleccionado y no se ha completado una palabra.
    if (clear == false) {
      bC = Colors.lightBlue;
    }
  }

  void update(double t) {}
  void render(Canvas c) {
    //Rectángulo que conforma el tile
    rect = Rect.fromLTWH(posx, posy, game.tileSize, game.tileSize);
    //Rectángulo que confroma la hitbox del tile
    hitbox = Rect.fromLTWH(
        posx + game.tileSize * 0.12,
        posy + game.tileSize * 0.12,
        game.tileSize * 0.75,
        game.tileSize * 0.75);

    //Texto del tile
    paragraph = ParagraphBuilder(ParagraphStyle(
        fontStyle: FontStyle.normal,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        fontSize: game.tileSize / 1.5));
    paragraph.addText(char);
    var p = paragraph.build()
      ..layout(ParagraphConstraints(width: game.tileSize));

    //Renderizado de elementos
    c.drawRect(rect, Paint()..color = bC);
    c.drawRect(hitbox, Paint()..color = Colors.transparent);
    c.drawParagraph(p, Offset(posx, posy + (game.tileSize * 0.1)));
  }

  void onTapDown() {
    //Cambia el color del tile cuando se selecciona
    if (clear == false) {
      bC = Colors.red;
    }
  }
}
