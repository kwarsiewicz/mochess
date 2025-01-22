from .side import Side, White, Black

@value
@register_passable
struct Piece():
    var piece: UInt8

    alias Pawn = Piece(0)
    alias Knight = Piece(1)
    alias Bishop = Piece(2)
    alias Rook = Piece(3)
    alias Queen = Piece(4)
    alias King = Piece(5)

    alias NUM_PIECES = 6
    alias NUM_PROMOTION_PIECES = 4

    fn to_str(self, color: Side) -> String:
        pcs = List("p", "n", "b", "r", "q", "k")
        if color == White.color:
            return pcs[self.to_index()].upper()
        else:
            return pcs[self.to_index()]

    @always_inline
    fn to_index(self) -> Int:
        return self.piece.__mlir_index__()
