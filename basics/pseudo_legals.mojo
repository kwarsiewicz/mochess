from .bitboard import BitBoard
from .side import Side
from .row import File, Rank
from .square import Square

from .generic.lines import LINE, RANKS, FILES, ADJACENT_FILES
from .generic.between import BETWEEN
from .generic.moves import BISHOP, ROOK, KING_MOVES, KNIGHT_MOVES, PAWN_ATTACKS, PAWN_MOVES, CASTLE_MOVES, PAWN_SOURCE_DOUBLE_MOVES, PAWN_DEST_DOUBLE_MOVES
#from .generic.magic import MOVES, MAGIC_NUMBERS
#from .generic.magic import ROOK_BMI_MASK, BISHOP_BMI_MASK, BMI_MOVES

from sys import llvm_intrinsic

@always_inline
fn pext(a: UInt64, b: UInt64) -> UInt64:
    alias intrin: StringLiteral = "llvm.x86.bmi.pext.64"
    return llvm_intrinsic[intrin, UInt64](a, b)

@always_inline
fn pdep(a: UInt64, b: UInt64) -> UInt64:
    alias intrin: StringLiteral = "llvm.x86.bmi.pdep.64"
    return llvm_intrinsic[intrin, UInt64](a, b)
"""
@always_inline
fn get_bishop_rays(sq: Square) -> BitBoard:
    return RAYS[BISHOP][sq.to_index()]

@always_inline
fn get_rook_rays(sq: Square) -> BitBoard:
    return RAYS[ROOK][sq.to_index()]

@always_inline
fn get_rook_moves(sq: Square, blockers: BitBoard) -> BitBoard:
    var m = MAGIC_NUMBERS[ROOK][sq.to_index()]
    return MOVES[((m.magic_number * (m.mask & blockers)).rshift_u64(m.shift) + m.offset.cast[DType.uint64]()).__mlir_index__()] & get_rook_rays(sq)

@always_inline
fn get_rook_moves_bmi(sq: Square, blockers: BitBoard) -> BitBoard:
    var m = ROOK_BMI_MASK[sq.to_index()]
    var index = (pext(blockers.bb, m.blockers_mask.bb) + m.offset.cast[DType.uint64]()).__mlir_index__()
    return BitBoard(pdep(BMI_MOVES[index].cast[DType.uint64](), get_rook_rays(sq).bb))

@always_inline
fn get_bishop_moves(sq: Square, blockers: BitBoard) -> BitBoard:
    var m = MAGIC_NUMBERS[BISHOP][sq.to_index()]
    return MOVES[((m.magic_number * (m.mask & blockers)).rshift_u64(m.shift) + m.offset.cast[DType.uint64]()).__mlir_index__()] & get_rook_rays(sq)

@always_inline
fn get_bishop_moves_bmi(sq: Square, blockers: BitBoard) -> BitBoard:
    var m = BISHOP_BMI_MASK[sq.to_index()]
    var index = (pext(blockers.bb, m.blockers_mask.bb) + m.offset.cast[DType.uint64]()).__mlir_index__()
    return BitBoard(pdep(BMI_MOVES[index].cast[DType.uint64](), get_bishop_rays(sq).bb))

@always_inline
fn get_king_moves(sq: Square) -> BitBoard:
    return KING_MOVES[sq.to_index()]

@always_inline
fn get_knight_moves(sq: Square) -> BitBoard:
    return KNIGHT_MOVES[sq.to_index()]

@always_inline
fn get_pawn_attacks(sq: Square, color: Side, blockers: BitBoard) -> BitBoard:
    return PAWN_ATTACKS[color.to_index()][sq.to_index()] & blockers

@always_inline
fn get_castle_moves() -> BitBoard:
    return CASTLE_MOVES

@always_inline
fn get_pawn_quiets(sq: Square, color: Side, blockers: BitBoard) -> BitBoard:
    if (BitBoard.from_square(sq.forward(color)) & blockers) != BitBoard.EMPTY_BB:
        return BitBoard.EMPTY_BB
    else:
        return PAWN_MOVES[color.to_index()][sq.to_index()] & ~blockers

@always_inline
fn get_pawn_moves(sq: Square, color: Side, blockers: BitBoard) -> BitBoard:
    return get_pawn_attacks(sq, color, blockers) ^ get_pawn_quiets(sq, color, blockers)

@always_inline
fn line(sq1: Square, sq2: Square) -> BitBoard:
    return LINE[sq1.to_index()][sq2.to_index()]

@always_inline
fn between(sq1: Square, sq2: Square) -> BitBoard:
    return BETWEEN[sq1.to_index()][sq2.to_index()]

@always_inline
fn get_rank(rank: Rank) -> BitBoard:
    return RANKS[rank.to_index()]

@always_inline
fn get_file(file: File) -> BitBoard:
    return FILES[file.to_index()]

@always_inline
fn get_adjacent_files(file: File) -> BitBoard:
    return ADJACENT_FILES[file.to_index()]

@always_inline
fn get_pawn_source_double_moves() -> BitBoard:
    return PAWN_SOURCE_DOUBLE_MOVES

@always_inline
fn get_pawn_dest_double_moves() -> BitBoard:
    return PAWN_DEST_DOUBLE_MOVES
"""