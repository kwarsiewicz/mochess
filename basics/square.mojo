from .row import Rank, File
from .side import Side, White, Black

@value
@register_passable
struct Square():
    var sq: UInt8

    @always_inline
    fn __init__(out self, sq: UInt8=0):
        self.sq = sq & 63 

    @always_inline
    fn __init__(out self, sq: UInt64=0):
        self.sq = (sq & 63).cast[DType.uint8]()

    @always_inline
    fn __init__(out self, sq: Int=0):
        self.sq = UInt8(sq & 63)

    @always_inline
    fn __copyinit__(out self, another: Self):
        self.sq = another.sq

    @always_inline
    fn __eq__(self, other: Self) -> Bool:
        return self.sq == other.sq

    @always_inline
    fn __ne__(self, other: Self) -> Bool:
        return self.sq != other.sq

    @always_inline
    @staticmethod
    fn make_square(rank: Rank, file: File) -> Square:
        return Square(rank.to_index() << 3 ^ file.to_index())

    @always_inline
    fn to_index(self) -> Int:
        return Int(self.sq)

    @always_inline
    fn to_u8(self) -> UInt8:
        return self.sq

    @always_inline
    fn to_u64(self) -> UInt64:
        return self.sq.cast[DType.uint64]()

    @always_inline
    fn get_rank(self) -> Rank:
        return Rank(self.sq >> 3)

    @always_inline
    fn get_file(self) -> File:
        return File(self.sq & 7)

    @always_inline
    fn up(self) -> Self:
        return Self(self.sq + 8)
    
    @always_inline
    fn down(self) -> Self:
        return Self(self.sq - 8)

    @always_inline
    fn left(self) -> Self:
        return Self(self.sq - 1)

    @always_inline
    fn right(self) -> Self:
        return Self(self.sq + 1)

    @always_inline
    fn forward(self, color: Side) -> Self:
        return self.up() if color == White.color else self.down()
    
    @always_inline
    fn backward(self, color: Side) -> Self:
        return self.down() if color == White.color else self.up()
