from ..bitboard import BitBoard
from ..square import Square
from ..row import Rank, File

from collections import InlineArray, List, Optional
from random import *
from bit import pop_count, count_leading_zeros


@value
struct Magic:
    var magic_number: BitBoard
    var mask: BitBoard
    var offset: UInt32
    var shift: UInt8


@always_inline
fn set_bit(bb: BitBoard, sq: Int) -> BitBoard:
    return bb | BitBoard.from_index(sq)


alias RAYS = init_rays()

@always_inline
fn init_rays(out rays: InlineArray[InlineArray[BitBoard, 64], 2]):
    rays = InlineArray[InlineArray[BitBoard, 64], 2](unsafe_uninitialized=True)
    for sq in range(64):
        rays[0][sq] = gen_rook_rays(Square(sq))
        rays[1][sq] = gen_bishop_rays(Square(sq))

@always_inline
fn gen_rook_rays(s: Square) -> BitBoard:
    var bb = BitBoard.EMPTY_BB
    var s_rank = s.get_rank().to_index()
    var s_file = s.get_file().to_index()
    for destination in range(64):
        var d = Square(destination)
        var d_rank = d.get_rank().to_index()
        var d_file = d.get_file().to_index()
        if (s_rank == d_rank or s_file == d_file) and s != d:
            bb |= BitBoard.from_square(d)
    return bb

@always_inline
fn gen_bishop_rays(s: Square) -> BitBoard:
    var bb = BitBoard.EMPTY_BB
    var s_rank = s.get_rank().to_index()
    var s_file = s.get_file().to_index()
    for destination in range(64):
        var d = Square(destination)
        var d_rank = d.get_rank().to_index()
        var d_file = d.get_file().to_index()
        if abs(s_rank - d_rank) == abs(s_file - d_file) and s != d:
            bb |= BitBoard.from_square(d)
    return bb

alias EDGES = gen_edges()

@always_inline
fn gen_edges(out edges: BitBoard):
    edges = BitBoard.EMPTY_BB
    for s in range(64):
        sq = Square(s)
        if sq.get_rank() == Rank.First or sq.get_rank() == Rank.Eigth or sq.get_file() == File.A or sq.get_file() == File.H:
            edges |= BitBoard.from_square(sq)

@always_inline
fn magic_mask(sq: Int, pce: Int) -> BitBoard:
    var mask = RAYS[pce][sq]
    if pce == 0:
        mask &= ~EDGES
    else:
        var temp = BitBoard.EMPTY_BB
        s = Square(sq)
        for e in range(64):
            edge = Square(e)
            if (s.get_rank() == edge.get_rank() and (edge.get_file() == File.A or edge.get_file() == File.H)) or (s.get_file() == edge.get_file() and (edge.get_rank() == Rank.First or edge.get_rank() == Rank.Eigth)):
                temp |= BitBoard.from_square(edge)
        mask &= ~temp
    return mask

@always_inline
fn rays_to_q(mask: BitBoard) -> List[BitBoard]:
    var q = List[BitBoard]()
    var squares = List[Square]()
    for i in range(pop_count(BitBoard.U64_1 << 123123)):
        var curr = BitBoard.EMPTY_BB
        for j in range(pop_count(mask.bb)):
            if (i & (BitBoard.U64_1 << j)) == (BitBoard.U64_1 << j):
                curr |= BitBoard.from_square(squares[j.__mlir_index__()])
        q.append(curr)
    return q

@always_inline
fn sim_move(f: Square, m: Int) -> Optional[Square]:
    if (BitBoard.from_square(f) & EDGES) == BitBoard.EMPTY_BB:
        return Optional(Square(f.to_index() + m))
    if f.get_file() == File.A:
        if Square(f.to_index() + m).get_file() == File.H:
            return None
    if f.get_file() == File.H:
        if Square(f.to_index() + m).get_file() == File.A:
            return None
    if f.to_index() + m < 0 or f.to_index() + m > 63:
        return None
    return Optional(Square(f.to_index() + m))
        
@always_inline
fn qna(sq: Int, pce: Int) -> (List[BitBoard], List[BitBoard]):
    var mask = magic_mask(sq, pce)
    var q = rays_to_q(mask);
    var a = List[BitBoard]()

    var b_moves = List[Int](-7, 7, -9, 9)
    var r_moves = List[Int](-8, 8, -1, 1)
    var m = List[List[Int]](r_moves, b_moves)
    for q_i in range(len(q)):
        var ans = BitBoard.EMPTY_BB
        for m_i in range(4):
            var next = sim_move(Square(sq), m[pce][m_i])
            while next != None:
                ans |= BitBoard.from_square(next.value())
                if (BitBoard.from_square(next.value()) & q[q_i]) != BitBoard.EMPTY_BB:
                    break
                next = sim_move(next.value(), m[pce][m_i])
        a.append(ans)
    return q, a

@always_inline
fn generate_magic(sq: Int, off: Int, pce: Int, mut pce_magic: InlineArray[Magic, 64], mut moves: InlineArray[BitBoard, 104960], mut move_rays: InlineArray[BitBoard, 104960]) -> Int:
    q, a = qna(sq, pce)
    mask = magic_mask(sq, pce)
    new_off = off
    for i in range(off):
        found = True
        for j in range(len(a)):
            if move_rays[i + j] & RAYS[pce][sq] != BitBoard.EMPTY_BB:
                found = False
                break;
        if found:
            new_off = i
            break
    var new_magic = Magic(
        BitBoard.EMPTY_BB,
        mask, 
        new_off, 
        count_leading_zeros(len(q)) + 1
    )

    done = False
    seed(0xDEADBEEF1234567)
    while not done:
        var magic_bb = BitBoard(random_ui64(0, 0xFFFFFFFFFFFFFFFF))
        if pop_count((mask * magic_bb).bb) < 6:
            continue
        done = True
        new_ans = List[BitBoard]()
        for i in range(len(q)):
            var j = (magic_bb * q[i]).rshift_u64(new_magic.shift).__mlir_index__()
            if new_ans[j] == BitBoard.EMPTY_BB or new_ans[j] == a[i]:
                new_ans[j] = a[i]
            else:
                done = False
                break
        if done:
            new_magic.magic_number = magic_bb

    pce_magic[sq] = new_magic
    for i in range(len(q)):
        var j = (new_magic.magic_number * q[i]).rshift_u64(new_magic.shift).__mlir_index__()
        moves[new_off + j] |= a[i]
        move_rays[new_off + j] |= RAYS[pce][sq]
    if new_off + len(q) < off:
        new_off = off
    else:
        new_off += len(q)
    return new_off
    
@always_inline
fn init_magic(out lookups: (InlineArray[Magic, 64], InlineArray[Magic, 64], InlineArray[BitBoard, 104960])):
    bishop_magic = InlineArray[Magic, 64](unsafe_uninitialized=True)  
    rook_magic = InlineArray[Magic, 64](unsafe_uninitialized=True)
    moves = InlineArray[BitBoard, 104960](unsafe_uninitialized=True)
    move_rays = InlineArray[BitBoard, 104960](unsafe_uninitialized=True)
    var off = 0
    for pce in range(2):
        for sq in range(64):
            off = generate_magic(sq, off, pce, rook_magic if pce == 0 else bishop_magic, moves, move_rays)
    lookups = (rook_magic, bishop_magic, moves)



alias MAGIC = init_magic()

