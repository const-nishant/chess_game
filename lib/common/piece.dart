enum ChessPieceType { pawn, knight, bishop, rook, queen, king }

class ChessPiece {
  final ChessPieceType type;
  final bool isWhite;
  final String imagePath;

  const ChessPiece(
      {required this.type, required this.isWhite, required this.imagePath});
}
