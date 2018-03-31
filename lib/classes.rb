
class GameBoard
  attr_accessor :board

  def initialize
    @board = []
    8.times { @board.push(Array.new(8,"")) }
  end

end

class Game

  def initialize
    @board = GameBoard.new
  end

end

class ChessPiece
  attr_accessor :color, :initial_pos

  def initialize
    @color = nil
    @initial_pos = nil
  end

end

class Pawn < ChessPiece
end

class Knight < ChessPiece
end

class Bishop < ChessPiece
end

class Rook < ChessPiece
end

class Queen < ChessPiece
end

class King < ChessPiece
end
