from .castles import CastleRights
from .side import Side
from .row import File
from .piece import Piece
from .square import Square

from .generic.zorbist import *

@register_passable
struct Hash:
    @always_inline
    @staticmethod
    fn piece(piece: Piece, square: Square, color: Side) -> UInt64:
        return ZORBIST_PIECES[color.to_index()][piece.to_index()][square.to_index()]

    @always_inline
    @staticmethod
    fn castles(castle_rights: CastleRights, color: Side) -> UInt64:
        return ZORBIST_CASTLES[color.to_index()][castle_rights.to_index()]

    @always_inline
    @staticmethod
    fn en_passant(file: File, color: Side) -> UInt64:
        return ZORBIST_EP[color.to_index()][file.to_index()]

    @always_inline
    @staticmethod
    fn color() -> UInt64:
        return SIDE_TO_MOVE
