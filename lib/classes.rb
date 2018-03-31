
class GameBoard
  attr_accessor :board

  def initialize
    @board = []
    8.times { @board.push(Array.new(8,"")) }
    # Need to set up all the pieces here
  end

end

class Game

  def initialize (board=GameBoard.new, turn='W')
    @board = board
    @turn = turn
  end

end

class ChessPiece
  attr_accessor :color, :pos

  def initialize (color, position)
    @color = color
    @position = position
  end

  def mark piece
    chess_code = "\u265"
    pieces = ['king','queen','rook','bishop','knight','pawn']
    order = ['A','B','C','D','E','F','4','5','6','7','8','9']
    index = pieces.find_index(piece)
    return chess_code + order[index] if @color == 'W'
    return chess_code + order[index+6] if @color == 'B'
  end
end

class Pawn < ChessPiece
  attr_reader :symbol

  def initialize
    @symbol = mark('pawn')
  end

  def next_positions
  end
end

class Knight < ChessPiece
  attr_reader :symbol

  def initialize
    @symbol = mark('knight')
  end

  def next_positions
  end
end

class Bishop < ChessPiece
  attr_reader :symbol

  def initialize
    @symbol = mark('bishop')
  end

  def next_positions
  end
end

class Rook < ChessPiece
  attr_reader :symbol

  def initialize
    @symbol = mark('rook')
  end

  def next_positions
  end
end

class Queen < ChessPiece
  attr_reader :symbol

  def initialize
    @symbol = mark('queen')
  end

  def next_positions
  end
end

class King < ChessPiece
  attr_reader :symbol

  def initialize
    @symbol = mark('king')
  end

  def next_positions
  end
end
