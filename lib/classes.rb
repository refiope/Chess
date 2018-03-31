
class GameBoard
  attr_accessor :board

  def initialize
    @board = []
    8.times { @board.push(Array.new(8,"")) }
    # Need to set up all the pieces here
  end

  def initial_setup

  end

  def setup_pawn
    @board[1].each_with_index do |column, index|
      column = Pawn.new('B', [1,index])
    end
    @board[6].each_with_index do |column, index|
      column = Pawn.new('W', [6,index])
    end
  end

  def setup_rook
    @board[0].each_with_index do |column, index|
      column = Rook.new('B',[0,index]) if index == 0 || 7
    end
    @board[7].each_with_index do |column, index|
      column = Rook.new('B',[7,index]) if index == 0 || 7
    end
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
    last_code = ['A','B','C','D','E','F','4','5','6','7','8','9']
    index = pieces.find_index(piece)
    return chess_code + last_code[index] if @color == 'W'
    return chess_code + last_code[index+6] if @color == 'B'
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
