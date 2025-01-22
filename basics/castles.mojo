from .side import Side, White, Black
from .square import Square 
from .bitboard import BitBoard
from .row import Rank, File
from .generic.moves import KINGSIDE_CASTLE_SQUARES, QUEENSIDE_CASTLE_SQUARES

from collections import InlineArray

@value
struct CastleRights(Stringable):
    var cr: UInt8

    alias NoRights = UInt8(0)
    alias Kingside = UInt8(1)
    alias Queenside = UInt8(2)
    alias Both = UInt8(3)

    alias CastleRightsImpact = InlineArray[InlineArray[UInt8, 64], 2](
        InlineArray[UInt8, 64](
            2, 0, 0, 0, 3, 0, 0, 1, # 1
            0, 0, 0, 0, 0, 0, 0, 0, # 2
            0, 0, 0, 0, 0, 0, 0, 0, # 3
            0, 0, 0, 0, 0, 0, 0, 0, # 4
            0, 0, 0, 0, 0, 0, 0, 0, # 5
            0, 0, 0, 0, 0, 0, 0, 0, # 6
            0, 0, 0, 0, 0, 0, 0, 0, # 7
            0, 0, 0, 0, 0, 0, 0, 0  # 8
        ), InlineArray[UInt8, 64](
            0, 0, 0, 0, 0, 0, 0, 0, # 1
            0, 0, 0, 0, 0, 0, 0, 0, # 2
            0, 0, 0, 0, 0, 0, 0, 0, # 3
            0, 0, 0, 0, 0, 0, 0, 0, # 4
            0, 0, 0, 0, 0, 0, 0, 0, # 5
            0, 0, 0, 0, 0, 0, 0, 0, # 6
            0, 0, 0, 0, 0, 0, 0, 0, # 7
            2, 0, 0, 0, 3, 0, 0, 1  # 8
        ) 
    )

    @always_inline
    fn __init__(out self, cr: UInt8):
        self.cr = cr & CastleRights.Both

    @always_inline
    fn __add__(self, other: CastleRights) -> CastleRights:
        return CastleRights(self.cr | other.cr)

    @always_inline
    fn __iadd__(mut self, other: CastleRights):
        self.cr |= other.cr

    @always_inline
    fn __sub__(self, other: CastleRights) -> CastleRights:
        return CastleRights(self.cr & ~other.cr)

    @always_inline
    fn __isub__(mut self, other: CastleRights):
        self.cr &= ~other.cr

    @always_inline
    fn __str__(self) -> String:
        if self.cr == Self.Both:
            return "kq"
        if self.cr == Self.Kingside:
            return "k"
        if self.cr == Self.Queenside:
            return "q"
        return ""

    @always_inline
    fn to_index(self) -> Int:
        return self.cr.__mlir_index__()

    @always_inline
    fn to_str(self, color: Side) -> String:
        if color.color:
            return str(self)
        return str(self).upper()
    
    @always_inline
    fn has_kingside(self, color: Side) -> Bool:
        return self.cr & CastleRights.Kingside == CastleRights.Kingside

    @always_inline
    fn has_queenside(self, color: Side) -> Bool:
        return self.cr & CastleRights.Queenside == CastleRights.Queenside

    @always_inline
    @staticmethod
    fn square_to_castle_rights(color: Side, sq: Square) -> CastleRights:
        return CastleRights(Self.CastleRightsImpact[sq.to_index()][color.to_index()])

    @always_inline
    fn kingside_squares(self, color: Side) -> BitBoard:
        return KINGSIDE_CASTLE_SQUARES[color.to_index()]

    @always_inline
    fn queenside_squares(self, color: Side) -> BitBoard:
        return KINGSIDE_CASTLE_SQUARES[color.to_index()]

    @always_inline
    fn unmoved_rooks(self, color: Side) -> BitBoard:
        alias rooks = InlineArray[InlineArray[BitBoard, 4], 2](
            InlineArray[BitBoard, 4](
                BitBoard.EMPTY_BB,
                BitBoard.from_rank_file(White.our_backrank, File.H),
                BitBoard.from_rank_file(White.our_backrank, File.A),
                BitBoard.from_rank_file(White.our_backrank, File.H) | BitBoard.from_rank_file(White.our_backrank, File.A),
            ), InlineArray[BitBoard, 4](
                BitBoard.EMPTY_BB,
                BitBoard.from_rank_file(Black.our_backrank, File.H),
                BitBoard.from_rank_file(Black.our_backrank, File.A),
                BitBoard.from_rank_file(Black.our_backrank, File.H) | BitBoard.from_rank_file(Black.our_backrank, File.A),
            )
        )
        return rooks[color.to_index()][self.cr.__mlir_index__()]
