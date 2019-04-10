import 'dart:math';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/util.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grid_flame/components/backyard.dart';
import 'package:grid_flame/components/tile.dart';

class MainGame extends BaseGame {
  BuildContext context;
  Size screensize;
  double tileSize;
  bool gridON = false;
  int gridSize;
  List<TileSet> grid = List<TileSet>();
  List<String> latinAlphabet = [
    "A",
    "B",
    "C",
    "D",
    "E",
    "F",
    "G",
    "H",
    "I",
    "J",
    "K",
    "L",
    "M",
    "N",
    "O",
    "P",
    "Q",
    "R",
    "S",
    "T",
    "U",
    "V",
    "W",
    "X",
    "Y",
    "Z"
  ];
  int charLimit = 26;
  List<String> words;
  List<List<TileSet>> answers;
  List<TileSet> currentAnswer;
  int answerCounter;
  bool answerError = false;

  Backyard background;

  MainGame(this.words,this.gridSize) {
    initialize();
  }
  initialize() async {
    //----------------Utiles y disparadores de flame-----------------//
    Util flameUtil = Util();
    await flameUtil.fullScreen();
    await flameUtil.setOrientation(DeviceOrientation.portraitUp);

    PanGestureRecognizer panner = PanGestureRecognizer();
    panner.onDown = this.onPanDown;
    panner.onUpdate = this.onPanUpdate;
    panner.onEnd = this.onPanEnd;
    flameUtil.addGestureRecognizer(panner);
    //---------------------------------------------------------------//
    //PLACEHOLDER PARA EL LOCALE
    String lang = "es";
    //-------------------------//

    //Configuración según idioma
    switch (lang) {
      case 'es':
        latinAlphabet.add("Ñ");
        charLimit++;
    }
    //-------------------------//

    //-----Generación del grid-------//
    int tileLimit = gridSize * gridSize;
    int columnCounter = 0;
    int rowCounter = 0;
    for (int i = 0; i < tileLimit; i++) {
      if (rowCounter == gridSize) {
        rowCounter = 0;
        columnCounter++;
      }
      TileSet tile = TileSet(this, "@", i, columnCounter, rowCounter);
      grid.add(tile);
      rowCounter++;
    }
    background = Backyard(this);
    resize(await Flame.util.initialDimensions());
    int tID = 0;
    for (int tX = 0; tX < gridSize; tX++) {
      for (int tY = 0; tY < gridSize; tY++) {
        double coordX = (tileSize / 2) + (tileSize * tX);
        double coordY = (tileSize / 2) + (tileSize * tY);
        coordX = coordX.roundToDouble();
        coordY = coordY.roundToDouble();
        grid[tID].coordSet(coordX, coordY);
        tID++;
      }
    }
    //-------Ubicación de palabras-------//
    Random r = Random();

    answers = List(words.length);
    int wordCount = 0;
    words.forEach((String word) {
      word = word.toUpperCase();
      answers[wordCount] = List<TileSet>(word.length);
      bool pathCorrect = false;
      while (pathCorrect == false) {
        //Tile aleatorio de inicio
        TileSet start = grid[r.nextInt(grid.length)];
        print(start.tileID.toString() + " - Start tile");
        //Tiles asociados a la palabra
        List<TileSet> tileIDs = List<TileSet>(word.length);
        //El try es un apaño para poder reiniciar el ciclo sin perder tiempo comprobando tiles innecesarios.
        try {
          //Iniciamos la posicion con -1 para que compruebe que es un tile válido.

          //Contador de los tiles válidos para comparar con la longitud de la palabra.
          int tileNeeded = 0;
          /*La dirección es aleatoria:
          0 - Derecha
          1 - Abajo
          2 - Diagonal I_Down
          3 - Diagonal I_Up
          */
          switch (r.nextInt(4)) {
            case 0:
              if (start.column + word.length > gridSize) {
                throw (pathCorrect = false);
              }
              for (int i = start.tileID; i < grid.length; i = i + gridSize) {
                TileSet temp = grid[i];
                if (word.substring(tileNeeded).startsWith(temp.char) ||
                    temp.char == "@") {
                  tileIDs[tileNeeded] = temp;
                  tileNeeded++;
                  if (tileNeeded == word.length) {
                    throw (pathCorrect = true);
                  }
                } else {
                  throw (pathCorrect = false);
                }
              }
              break;
            case 1:
              if (start.row + word.length > gridSize) {
                throw (pathCorrect = false);
              }
              for (int i = start.tileID; i < grid.length; i++) {
                TileSet temp = grid[i];
                if (word.substring(tileNeeded).startsWith(temp.char) ||
                    temp.char == "@") {
                  tileIDs[tileNeeded] = temp;
                  tileNeeded++;
                  if (tileNeeded == word.length) {
                    throw (pathCorrect = true);
                  }
                } else {
                  throw (pathCorrect = false);
                }
              }
              break;
            case 2:
              if (start.column + word.length > gridSize ||
                  start.row + word.length > gridSize) {
                throw (pathCorrect = false);
              }
              for (int i = start.tileID; i < grid.length; i = i + gridSize + 1) {
                TileSet temp = grid[i];
                if (word.substring(tileNeeded).startsWith(temp.char) ||
                    temp.char == "@") {
                  tileIDs[tileNeeded] = temp;
                  tileNeeded++;
                  if (tileNeeded == word.length) {
                    throw (pathCorrect = true);
                  }
                } else {
                  throw (pathCorrect = false);
                }
              }
              break;
            case 3:
              if (start.column + word.length > gridSize ||
                  start.row - word.length < 0) {
                throw (pathCorrect = false);
              }
              for (int i = start.tileID; i < grid.length; i = i + gridSize - 1) {
                TileSet temp = grid[i];
                if (word.substring(tileNeeded).startsWith(temp.char) ||
                    temp.char == "@") {
                  tileIDs[tileNeeded] = temp;
                  tileNeeded++;
                  if (tileNeeded == word.length) {
                    throw (pathCorrect = true);
                  }
                } else {
                  throw (pathCorrect = false);
                }
              }
              break;
          }
        } catch (pathCorrect) {
          print(pathCorrect.toString());
          if (pathCorrect == true) {
            for (var i = 0; i < word.length; i++) {
              tileIDs[i].charSet(word.substring(i, i + 1));
              tileIDs[i].hasAnswerChar = true;
              answers[wordCount][i] = tileIDs[i];
            }
            wordCount++;
          }
        }
      }
    });

    //-------Randomización de tiles vacíos-------//
    grid.forEach((TileSet tile) {
      if (tile.char == "@") {
        tile.charSet(latinAlphabet[r.nextInt(charLimit)]);
      }
    });
  }

  void render(Canvas c) {
    background.render(c);
    grid.forEach((TileSet tile) => tile.render(c));
  }

  void update(double t) {}

  void resize(Size size) {
    screensize = size;
    tileSize = screensize.width / (gridSize+1);
  }

  void onTapDown(TapDownDetails d) {}

  dynamic onPanDown(DragDownDetails d) {
    answerCounter = 0;
    answerError = false;
    grid.forEach((TileSet tile) {
      if (tile.hitbox.contains(d.globalPosition)) {
        tile.onTapDown();
        if (tile.isAnswer()) {
          answers.forEach((List<TileSet> answer) {
            if (answer[answerCounter].isCorrectAnswer(tile.tileID)) {
              currentAnswer = answer;
            }
          });
        }
      }
    });
  }

  dynamic onPanUpdate(DragUpdateDetails d) {
    grid.forEach((TileSet tile) {
      if (tile.hitbox.contains(d.globalPosition)) {
        tile.onTapDown();
        if (currentAnswer[answerCounter].isCorrectAnswer(tile.tileID)) {
          answerCounter++;
          if (answerCounter == currentAnswer.length && answerError == true) {
            currentAnswer.forEach((TileSet ans) {
              ans.congrats();
            });
            answerCounter = 0;
            answerError = false;
          }
        } else {
          answerError = true;
        }
      }
    });
  }

  dynamic onPanEnd(DragEndDetails d) {
    grid.forEach((TileSet tile) {
      tile.reset();
    });
  }
}
