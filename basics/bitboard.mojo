from .row import File, Rank
from .square import Square
from bit import count_trailing_zeros, pop_count, byte_swap
from collections import Optional

trait __BitBoardIterator:
    fn __next__(mut self) -> Square:
        pass
    
    fn __has_next__(self) -> Bool:
        pass

@register_passable
struct BitBoardIterator(__BitBoardIterator):
    var iterable: UInt64

    @always_inline
    fn __init__(inout self, iterable: UInt64):
        self.iterable = iterable

    @always_inline
    fn __next__(mut self) -> Square:
        var sq = count_trailing_zeros(self.iterable)
        self.iterable ^= BitBoard.U64_1 << sq
        return Square(sq)

    @always_inline
    fn __has_next__(self) -> Bool:
        return self.iterable != BitBoard.EMPTY


trait IterableBitBoard:
    fn __iter__(self) -> BitBoardIterator:
        pass
    

@value
@register_passable
struct BitBoard(IterableBitBoard, Stringable):
    var bb: UInt64

    alias EMPTY_BB = BitBoard(0)
    alias EMPTY = UInt64(0)
    alias U64_1 = UInt64(1)

    @always_inline
    fn __iter__(self) -> BitBoardIterator:
        return BitBoardIterator(self.bb)

    @always_inline
    fn __invert__(self) -> BitBoard:
        return BitBoard(~self.bb)

    @always_inline
    fn __and__(self, other: BitBoard) -> BitBoard:
        return BitBoard(self.bb & other.bb)

    @always_inline
    fn __and__(self, other: Square) -> Bool:
        return self & BitBoard.from_square(other) != BitBoard.EMPTY_BB

    @always_inline
    fn __xor__(self, other: BitBoard) -> BitBoard:
        return BitBoard(self.bb ^ other.bb)

    @always_inline
    fn __or__(self, other: BitBoard) -> BitBoard:
        return BitBoard(self.bb | other.bb)

    @always_inline
    fn __iand__(mut self, other: BitBoard):
        self.bb &= other.bb

    @always_inline
    fn __ixor__(mut self, other: BitBoard):
        self.bb ^= other.bb

    @always_inline
    fn __ior__(mut self, other: BitBoard):
        self.bb |= other.bb

    @always_inline
    fn __mul__(self, other: BitBoard) -> BitBoard:
        return BitBoard(self.bb * other.bb)

    @always_inline
    fn __eq__(self, other: BitBoard) -> Bool:
        return self.bb == other.bb

    @always_inline
    fn __eq__(self, other: UInt64) -> Bool:
        return self.bb == other

    @always_inline
    fn __ne__(self, other: BitBoard) -> Bool:
        return self.bb != other.bb

    @always_inline
    fn __ne__(self, other: UInt64) -> Bool:
        return self.bb != other

    @always_inline
    fn __getitem__(self, sq: Square) -> Bool:
        return (self & Self.from_square(sq)) != Self.EMPTY

    @always_inline
    fn __getitem__(self, index: UInt64) -> Bool:
        return (self & Self.from_index(index)) != Self.EMPTY

    @always_inline
    fn __str__(self) -> String:
        alias rows = 8
        s = String()
        s += "\nA B C D E F G H \n"
        for row in range(rows):
            for col in range(8):
                if self & Square.make_square(Rank(7 - row), File(col)):
                    s += "■ " 
                else:
                    s += "□ "  
            if row != rows - 1:
                s += str(8 - row) + "\n"     
        return s + "1 \n"

    @always_inline
    @staticmethod
    fn from_square(sq: Square) -> Self:
        return Self(Self.U64_1 << sq.to_u64())

    @always_inline
    @staticmethod
    fn from_index(index: UInt8) -> Self:
        return Self(Self.U64_1 << index.cast[DType.uint64]())

    @always_inline
    @staticmethod
    fn from_index(index: UInt64) -> Self:
        return Self(Self.U64_1 << index)

    @always_inline
    @staticmethod
    fn from_index(index: Int) -> Self:
        return Self(Self.U64_1 << index)

    @always_inline
    @staticmethod
    fn from_rank_file(rank: Rank, file: File) -> Self:
        return Self.from_square(Square.make_square(rank, file))

    @always_inline
    fn to_square(self) -> Square:
        return Square(count_trailing_zeros(self.bb))

    @always_inline
    fn ctz(self) -> UInt64:
        return count_trailing_zeros(self.bb)

    @always_inline
    fn reverse_board(self) -> Self:
        return Self(byte_swap(self.bb))

    @always_inline
    fn rshift_u64(self, shift: UInt8) -> UInt64:
        return self.bb >> shift.cast[DType.uint64]()

    """
    @always_inline
    fn popcnt(self) -> UInt64:
        return pop_count(self.bb)"""