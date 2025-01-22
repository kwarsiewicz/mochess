from .row import Rank

@value
@register_passable
struct White():
    alias color = False
    alias our_backrank = Rank.First
    alias their_backrank = Rank.Eigth
    alias second_rank = Rank.Second
    alias seventh_rank = Rank.Seventh
    alias fourth_rank = Rank.Fourth

@value
@register_passable
struct Black():
    alias color = True
    alias our_backrank = Rank.Eigth
    alias their_backrank = Rank.First
    alias second_rank = Rank.Seventh
    alias seventh_rank = Rank.Second
    alias fourth_rank = Rank.Fifth

@value
@register_passable
struct Side():
    var color: Bool

    alias NUM_COLORS = 2

    @always_inline
    fn __eq__(self, other: Bool) -> Bool:
        return self.color == other

    @always_inline
    fn __invert__(mut self):
        self.color = ~self.color
    
    @always_inline
    fn to_index(self) -> Int:
        return self.color

    @always_inline
    fn to_my_backrank(self) -> Rank:
        return Black.our_backrank if self.color else White.our_backrank

    @always_inline
    fn to_their_backrank(self) -> Rank:
        return Black.their_backrank if self.color else White.their_backrank
    
    @always_inline
    fn to_second_rank(self) -> Rank:
        return Black.second_rank if self.color else White.second_rank

    @always_inline
    fn to_fourth_rank(self) -> Rank:
        return Black.fourth_rank if self.color else White.fourth_rank

    @always_inline
    fn to_seventh_rank(self) -> Rank:
        return Black.seventh_rank if self.color else White.seventh_rank






