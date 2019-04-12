import 'dart:math';
import 'dart:ui' as dartUI;
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/util.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grid_flame/components/backyard.dart';
import 'package:grid_flame/components/tile.dart';

class SoupGame extends BaseGame {
  Size screensize;
  double tileSize;
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
  List<bool> answersClear;
  int answerCounter;
  int answerError = 0;
  TileSet currentTile = null;

  //FLAGS-START
  bool screenReady = false;
  //FLAGS-END
  Backyard background;

  SoupGame(this.words, this.gridSize) {
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
    //Límite de tiles a crear, el tablero siempre será cuadrado.
    int tileLimit = gridSize * gridSize;
    //Contadores para controlar las columnas y filas.
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
    //Configuración del fondo
    background = Backyard(this);
    //Primera llamada para obtener las dimensiones de la pantalla.
    resize(await Flame.util.initialDimensions());
    //Configurar las coordenadas para cada tile. Se deja media casilla de espacio al principio y al final como márgen.
    int tID = 0;
    for (int tX = 0; tX < gridSize; tX++) {
      for (int tY = 0; tY < gridSize; tY++) {
        double coordX = (tileSize / 2) + (tileSize.round() * tX);
        double coordY = (tileSize / 2) + (tileSize.round() * tY);
        grid[tID].coordSet(coordX, coordY);
        tID++;
      }
    }
    //-------Ubicación de palabras-------//
    Random r = Random();

    answers = List(words.length);
    answersClear = List(words.length);
    int wordCount = 0;
    words.forEach((String word) {
      //Fijamos la palabra en mayúscula para evitar problemas.
      word = word.toUpperCase();
      answersClear[wordCount] = false;
      //Le asignamos a una de las listas de palabras un largo igual al siuo.
      answers[wordCount] = List<TileSet>(word.length);
      //Variable para controlar el loop de establecer las palabras.
      bool pathCorrect = false;
      while (pathCorrect == false) {
        //Tile aleatorio de inicio
        TileSet start = grid[r.nextInt(grid.length)];
        print(start.tileID.toString() + " - Start tile");
        //Tiles asociados a la palabra
        List<TileSet> tileIDs = List<TileSet>(word.length);
        //El try es un apaño para poder reiniciar el ciclo sin perder tiempo comprobando tiles innecesarios.
        try {
          //Contador de los tiles válidos para comparar con la longitud de la palabra.
          int tileNeeded = 0;
          /*La dirección es aleatoria:
          0 - Derecha
          1 - Abajo
          2 - Diagonal I_Down
          3 - Diagonal I_Up

          Después de comprobar si hay tiles suficientes los métodos son iguales,
          sólo cambia el incremento de las ID de los tiles dependiendo de la dirección,
          después se comprueba si el tile está vacío (tiene una @ por defecto), o 
          si ya tiene letra (por formar parte de otra palabra) que séa la misma.
          Cuando se han comprobado tantos tiles como letras tiene la palabra
          se lanza un True sobre pathCorrect, se cambian las letras de los tiles
          a las de la palabra y se registran como parte de la respuesta.
          */
          switch (r.nextInt(4)) {
            case 0:
              //Comprobamos que la palabra no sea mas larga que las casillas disponibles
              if (start.column + word.length > gridSize) {
                throw (pathCorrect = false);
              }
              //Comprobamos los tiles desde el inicial, al saltar de columna en columna sumamos siempre el tamaño del grid.
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
              //Comprobamos que la palabra no sea mas larga que las casillas disponibles
              if (start.row + word.length > gridSize) {
                throw (pathCorrect = false);
              }
              //Comprobamos los tiles desde el inicial, al saltar de fila en fila sumamos siempre 1.
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
              //Comprobamos que la palabra no sea mas larga que las casillas disponibles
              if (start.column + word.length > gridSize ||
                  start.row + word.length > gridSize) {
                throw (pathCorrect = false);
              }
              //Comprobamos los tiles desde el inicial, al saltar en diagonal sumamos 1 por fila y el tamaño del grid por columna
              for (int i = start.tileID;
                  i < grid.length;
                  i = i + gridSize + 1) {
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
              //Comprobamos que la palabra no sea mas larga que las casillas disponibles
              if (start.column + word.length > gridSize ||
                  start.row - word.length < 0) {
                throw (pathCorrect = false);
              }
              //Comprobamos los tiles desde el inicial, al saltar en diagonal hacia arriba restamos 1 por fila y suamos el tamaño del grid por columna
              for (int i = start.tileID;
                  i < grid.length;
                  i = i + gridSize - 1) {
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
              tileIDs[i].answerID = wordCount;
            }
            wordCount++;
          }
        }
      }
    });
    //Confirmamos que la pantalla está lista para renderizar las respuestas.
    screenReady = true;

    //-------Randomización de tiles vacíos-------//
    grid.forEach((TileSet tile) {
      if (tile.char == "@") {
        tile.charSet(latinAlphabet[r.nextInt(charLimit)]);
      }
    });
  }

  void render(Canvas c) {
    //Renderiza todas las imágenes y textos.
    background.render(c);
    grid.forEach((TileSet tile) => tile.render(c));
    if (screenReady == true) {
      double x = grid[gridSize - 1].posx;
      double y = grid[gridSize - 1].posy + this.tileSize.round();
      for (int i = 0; i < words.length; i++) {
        var form = dartUI.ParagraphBuilder(dartUI.ParagraphStyle(
            fontStyle: FontStyle.normal,
            textAlign: TextAlign.left,
            textDirection: TextDirection.ltr,
            fontSize: this.tileSize / 1.5));
        if(answersClear[i] == true){
          form.pushStyle(dartUI.TextStyle(decoration: TextDecoration.lineThrough));
        }
        form.addText(words[i]);
        dartUI.Paragraph ans = form.build()..layout(dartUI.ParagraphConstraints(width: this.tileSize*gridSize));;
        y = y + tileSize.round();
        c.drawParagraph(ans, Offset(x, y));
      }
    }
  }

  void update(double t) {}

  void resize(Size size) {
    //Provee del tamaño de pantalla, del cual se establece el de los tiles en función del grid.
    screensize = size;
    tileSize = screensize.width / (gridSize + 1);
  }

  dynamic onPanDown(DragDownDetails d) {
    //Este método se activa al pulsar la pantalla, ANTES de moverse por ella.

    //Contadores de tiles correctos seleccionados y de errores.
    answerCounter = 0;
    answerError = 0;
    /*
    Para todos los tiles se comprueba su posición para saber con cual se ha
    hecho contacto. Si es un tile que INICIA una palabra se establece la misma
    como la respuesta actual.
    */
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
    //Este método se activa cuando se EMPIEZA a mover el dedo sobre la pantalla.
    grid.forEach((TileSet tile) {
      /*
      De nuevo se comprueba entre todos los tiles con cual se ha hecho contacto.
      Si es el siguiente tile de la respuesta se aumenta el contador, si no se establece como fallo,
      si el contador de aciertos ha subido al numero de letras establece los tiles de la palabra como 
      completados.
      */
      if (tile.hitbox.contains(d.globalPosition)) {
        tile.onTapDown();
        if (tile != currentTile) {
          currentTile = tile;
          if (currentAnswer[answerCounter].isCorrectAnswer(tile.tileID)) {
            answerCounter++;
            print(answerCounter.toString());
            if (answerCounter == currentAnswer.length && answerError <= 1) {
              currentAnswer.forEach((TileSet ans) {
                ans.congrats();
                answersClear[ans.answerID] = true;
              });
              answerCounter = 0;
              answerError = 0;
            }
          } else {
            answerError++;
            print(answerError.toString());
          }
        }
      }
    });
  }

  dynamic onPanEnd(DragEndDetails d) {
    //Este método se activa al levantar el dedo de la pantlla, restablece
    //los tiles sleccionados que no se hayan resuelto a su color original.
    grid.forEach((TileSet tile) {
      tile.reset();
    });
  }
}
