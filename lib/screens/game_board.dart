import 'package:chess_game/exports.dart';
import 'package:flutter/material.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  //A 2-dimensional list representing the board
  //with each positon possibly containing a piece
  late List<List<ChessPiece?>> board;

  //the currently selected piece on the board
  //if no piece is selected, this will be null
  ChessPiece? selectedPiece;

//the row & col index of the selected piece
//default value for the selected row and column
  int selectedRow = -1;
  int selectedCol = -1;

  //a list of valid moves for the selected piece
  //each move is represented as a list with 2 elements:row and col
  List<List<int>> validMoves = [];

  //a list of white pieces that have been captured
  List<ChessPiece> whitePiecesTaken = [];

  //a list of black pieces that have been captured
  List<ChessPiece> blackPiecesTaken = [];

  //A boolen to indicate whose turn it is
  bool isWhiteTurn = true;

  //initial positon of  the king in the board
  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];
  bool checkStatus = false;

  @override
  void initState() {
    super.initState();
    _initBoard();
  }

  void _initBoard() {
    //Initialize the board with nulls, meaning no pieces in those positions
    List<List<ChessPiece?>> newBoard = List.generate(
      8,
      (index) => List.generate(
        8,
        (index) => null,
      ),
    );

//place random pieces on the board
    // newBoard[3][3] = const ChessPiece(
    //   type: ChessPieceType.queen,
    //   isWhite: false,
    //   imagePath: "assets/images/queen.png",
    // );

    //place pawns on the board
    for (int i = 0; i < 8; i++) {
      newBoard[1][i] = const ChessPiece(
          type: ChessPieceType.pawn,
          isWhite: false,
          imagePath: "assets/images/pawn.png");
    }

    for (int i = 0; i < 8; i++) {
      newBoard[6][i] = const ChessPiece(
          type: ChessPieceType.pawn,
          isWhite: true,
          imagePath: "assets/images/pawn.png");
    }

    //place rooks on the board
    newBoard[0][0] = const ChessPiece(
        type: ChessPieceType.rook,
        isWhite: false,
        imagePath: "assets/images/rook.png");

    newBoard[0][7] = const ChessPiece(
        type: ChessPieceType.rook,
        isWhite: false,
        imagePath: "assets/images/rook.png");

    newBoard[7][0] = const ChessPiece(
        type: ChessPieceType.rook,
        isWhite: true,
        imagePath: "assets/images/rook.png");

    newBoard[7][7] = const ChessPiece(
        type: ChessPieceType.rook,
        isWhite: true,
        imagePath: "assets/images/rook.png");

    //place knights on the board
    newBoard[0][1] = const ChessPiece(
        type: ChessPieceType.knight,
        isWhite: false,
        imagePath: "assets/images/knight.png");

    newBoard[0][6] = const ChessPiece(
        type: ChessPieceType.knight,
        isWhite: false,
        imagePath: "assets/images/knight.png");

    newBoard[7][1] = const ChessPiece(
        type: ChessPieceType.knight,
        isWhite: true,
        imagePath: "assets/images/knight.png");

    newBoard[7][6] = const ChessPiece(
        type: ChessPieceType.knight,
        isWhite: true,
        imagePath: "assets/images/knight.png");

    //place bishops on the board
    newBoard[0][2] = const ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: false,
        imagePath: "assets/images/bishop.png");

    newBoard[0][5] = const ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: false,
        imagePath: "assets/images/bishop.png");

    newBoard[7][2] = const ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: true,
        imagePath: "assets/images/bishop.png");

    newBoard[7][5] = const ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: true,
        imagePath: "assets/images/bishop.png");

    //place queens on the board

    newBoard[0][3] = const ChessPiece(
        type: ChessPieceType.queen,
        isWhite: false,
        imagePath: "assets/images/queen.png");

    newBoard[7][4] = const ChessPiece(
        type: ChessPieceType.queen,
        isWhite: true,
        imagePath: "assets/images/queen.png");

    //place kings on the board

    newBoard[0][4] = const ChessPiece(
        type: ChessPieceType.king,
        isWhite: false,
        imagePath: "assets/images/king.png");

    newBoard[7][3] = const ChessPiece(
        type: ChessPieceType.king,
        isWhite: true,
        imagePath: "assets/images/king.png");

    board = newBoard;
  }

  void pieceSelected(int row, int col) {
    setState(() {
      //no piece has been selected
      if (selectedPiece == null && board[row][col] != null) {
        if (board[row][col]!.isWhite == isWhiteTurn) {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
        }
      }
      //there is a piece already selected,but user can select another one of their piece
      else if (board[row][col] != null &&
          board[row][col]!.isWhite == selectedPiece!.isWhite) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      }

      //if there is a piece already selected and user taps on a square that is a vaild move , move the piece
      else if (selectedPiece != null &&
          validMoves.any((element) => element[0] == row && element[1] == col)) {
        movePiece(row, col);
      }
      //move the piece

      //if a piece is selected calculate the possible moves
      validMoves = calculateRawValidMoves(row, col, selectedPiece);
    });
  }

  //calulate raw valid moves
  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece) {
    List<List<int>> candidateMoves = [];

    //check if the piece is null
    if (piece == null) {
      return [];
    }

    //different directions based on their color
    int direction = piece.isWhite ? -1 : 1;

    switch (piece.type) {
      case ChessPieceType.pawn:
        //pawns can move one space forward if not occupied
        if (isInBoard(row + direction, col) &&
            board[row + direction][col] == null) {
          candidateMoves.add([row + direction, col]);
        }
        //pawns can move two spaces if it is their first move
        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
          if (isInBoard(row + 2 * direction, col) &&
              board[row + 2 * direction][col] == null &&
              board[row + direction][col] == null) {
            candidateMoves.add([row + 2 * direction, col]);
          }
        }
        //pawns can capture diagonally
        if (isInBoard(row + direction, col - 1) &&
            board[row + direction][col - 1] != null &&
            board[row + direction][col - 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col - 1]);
        }

        if (isInBoard(row + direction, col + 1) &&
            board[row + direction][col + 1] != null &&
            board[row + direction][col + 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col + 1]);
        }
        break;
      case ChessPieceType.knight:
        //knight can move in an L shape
        var knightMoves = [
          [-2, -1], //up 2 left 1
          [-2, 1], //up 2 right 1
          [-1, -2], //left 2 up 1
          [-1, 2], //left 2 down 1
          [1, -2], //right 2 up 1
          [1, 2], //right 2 down 1
          [2, -1], //down 2 left 1
          [2, 1], //down 2 right 1
        ];

        for (var move in knightMoves) {
          var nextRow = row + move[0];
          var nextCol = col + move[1];
          if (!isInBoard(nextRow, nextCol)) {
            continue;
          }
          if (board[nextRow][nextCol] != null) {
            if (board[nextRow][nextCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([nextRow, nextCol]); //capture
            }
            continue; //blocked
          }
          candidateMoves.add([nextRow, nextCol]);
        }
        break;
      case ChessPieceType.bishop:
        //diagonal moves
        var directions = [
          [-1, -1], //up left
          [-1, 1], //up right
          [1, -1], //down left
          [1, 1], //down right
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var nextRow = row + i * direction[0];
            var nextCol = col + i * direction[1];
            if (!isInBoard(nextRow, nextCol)) {
              break;
            }
            if (board[nextRow][nextCol] != null) {
              if (board[nextRow][nextCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([nextRow, nextCol]); //kill
              }
              break; //blocked
            }
            candidateMoves.add([nextRow, nextCol]);
            i++;
          }
        }
      case ChessPieceType.rook:
        //horizontal &vertical moves
        var directions = [
          [-1, 0], //up
          [1, 0], //down
          [0, -1], //left
          [0, 1], //right
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var nextRow = row + i * direction[0];
            var nextCol = col + i * direction[1];
            if (!isInBoard(nextRow, nextCol)) {
              break;
            }
            if (board[nextRow][nextCol] != null) {
              if (board[nextRow][nextCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([nextRow, nextCol]); //kill
              }
              break; //blocked
            }
            candidateMoves.add([nextRow, nextCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.queen:
        //all directions
        var directions = [
          [-1, -1], //up left
          [-1, 1], //up right
          [1, -1], //down left
          [1, 1], //down right
          [-1, 0], //up
          [1, 0], //down
          [0, -1], //left
          [0, 1], //right
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var nextRow = row + i * direction[0];
            var nextCol = col + i * direction[1];
            if (!isInBoard(nextRow, nextCol)) {
              break;
            }
            if (board[nextRow][nextCol] != null) {
              if (board[nextRow][nextCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([nextRow, nextCol]); //kill
              }
              break; //blocked
            }
            candidateMoves.add([nextRow, nextCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.king:
        var directions = [
          [-1, -1], //up left
          [-1, 0], //up
          [-1, 1], //up right
          [0, -1], //left
          [0, 1], //right
          [1, -1], //down left
          [1, 0], //down
          [1, 1], //down right
        ];

        for (var direction in directions) {
          var nextRow = row + direction[0];
          var nextCol = col + direction[1];
          if (!isInBoard(nextRow, nextCol)) {
            continue;
          }
          if (board[nextRow][nextCol] != null) {
            if (board[nextRow][nextCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([nextRow, nextCol]); //capture
            }
            continue; //blocked
          }
          candidateMoves.add([nextRow, nextCol]);
        }
        break;
      default:
    }

    return candidateMoves;
  }

//move the piece
  void movePiece(int newRow, int newCol) {
    //if the new spot has an opponent piece
    if (board[newRow][newCol] != null) {
      //add the captured piece to the captured pieces list
      var capturedPiece = board[newRow][newCol];
      if (capturedPiece!.isWhite) {
        whitePiecesTaken.add(capturedPiece);
      } else {
        blackPiecesTaken.add(capturedPiece);
      }
    }

    //check if the piece being moved is a king
    // if (selectedPiece!.type == ChessPieceType.king) {
    //   whiteKingPosition = [newRow, newCol];
    // } else {
    //   blackKingPosition = [newRow, newCol];
    // }

    //remove the piece from the old position
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    //see if the king is in check
    if (isKingInCheck(!isWhiteTurn)) {
      checkStatus = true;
    } else {
      checkStatus = false;
    }

    // clear the square
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });

    //change the turn
    setState(() {
      isWhiteTurn = !isWhiteTurn;
    });
  }

  bool isKingInCheck(bool isWhiteKing) {
    // Get the position of the king
    List<int> kingPosition =
        isWhiteKing ? whiteKingPosition : blackKingPosition;

    // Check if any enemy piece can attack the king
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        // Skip empty squares and pieces of the same color
        if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing) {
          continue;
        }

        // Get the valid moves for the current piece
        List<List<int>> pieceValidMoves =
            calculateRawValidMoves(i, j, board[i][j]);

        // Check if the king's position is in the valid moves
        if (pieceValidMoves.any((move) =>
            move[0] == kingPosition[0] && move[1] == kingPosition[1])) {
          return true; // The king is in check
        }
      }
    }
    return false; // The king is not in check
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          //White piecestaken
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
              ),
              itemCount: whitePiecesTaken.length,
              itemBuilder: (BuildContext context, int index) => DeadPiece(
                imagePath: whitePiecesTaken[index].imagePath,
                isWhite: whitePiecesTaken[index].isWhite,
              ),
            ),
          ),
          //Check status
          Text(
            checkStatus
                ? 'Check'
                : isWhiteTurn
                    ? 'White Turn'
                    : 'Black Turn',
            style: TextStyle(
              color: checkStatus ? Colors.red : Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          //chessboard
          Expanded(
            flex: 3,
            child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                ),
                itemCount: 8 * 8,
                itemBuilder: (BuildContext context, int index) {
                  //get the row and column position of the square
                  int row = index ~/ 8;
                  int col = index % 8;

                  //check if the square is selected
                  bool isSelected = selectedRow == row && selectedCol == col;

                  //check if the square is a valid move
                  bool isValidMove = false;
                  for (var position in validMoves) {
                    //compare the row and column position of the square
                    if (position[0] == row && position[1] == col) {
                      isValidMove = true;
                      break;
                    }
                  }

                  return Square(
                    isWhite: isWhite(index),
                    piece: board[row][col],
                    isSelected: isSelected,
                    onTap: () => pieceSelected(row, col),
                    isValidMove: isValidMove,
                  );
                }),
          ),
          //Black piecestaken
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
              ),
              itemCount: blackPiecesTaken.length,
              itemBuilder: (BuildContext context, int index) => DeadPiece(
                imagePath: blackPiecesTaken[index].imagePath,
                isWhite: blackPiecesTaken[index].isWhite,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
