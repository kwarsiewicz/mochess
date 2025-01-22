@value
@register_passable
struct File():
    var file: UInt8

    alias A = File(0)
    alias B = File(1)
    alias C = File(2)
    alias D = File(3)
    alias E = File(4)
    alias F = File(5)
    alias G = File(6)
    alias H = File(7)

    alias NUM_FILES = 8

    @always_inline
    fn __eq__(self, file: Self) -> Bool:
        return self.file == file.file

    @always_inline
    fn __init__(out self, f: UInt8=0):
        self.file = f & 7

    @always_inline
    fn to_index(self) -> Int:
        return self.file.__mlir_index__()

    @always_inline
    fn left(self) -> Self:
        return Self(self.file - 1)

    @always_inline
    fn right(self) -> Self:
        return Self(self.file + 1)

@value
@register_passable
struct Rank():
    var rank: UInt8

    alias First = Rank(0)
    alias Second = Rank(1)
    alias Third = Rank(2)
    alias Fourth = Rank(3)
    alias Fifth = Rank(4)
    alias Sixth = Rank(5)
    alias Seventh = Rank(6)
    alias Eigth = Rank(7)

    alias NUM_RANKS = 8

    @always_inline
    fn __eq__(self, other: Self) -> Bool:
        return self.rank == other.rank

    @always_inline
    fn __init__(out self, r: UInt8=0):
        self.rank = r & 7

    @always_inline
    fn to_index(self) -> Int:
        return self.rank.__mlir_index__()

    @always_inline
    fn down(self) -> Self:
        return Self(self.rank - 1)

    @always_inline
    fn up(self) -> Self:
        return Self(self.rank + 1)
