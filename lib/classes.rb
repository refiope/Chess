
#Access board
class GameBoard
  attr_accessor :board

  def initialize
    @board = []
    8.times { @board.push(Array.new(8,nil)) }
    # Need to set up all the pieces here
    initial_setup
  end

  def display
    display_column_order
    @board.each_index do |row|
      print (8-row).abs
      print "|"
      @board[row].each do |column|
        print column.symbol+" " if !column.nil?
        print "  " if column.nil?
        print "|"
      end
      print (8-row).abs
      puts "\n--------------------------"
    end
    display_column_order
  end

  def display_column_order
    column_order = ['a','b','c','d','e','f','g','h']
    print "  "
    column_order.each do |letter|
      print letter+"  "
    end
    puts ""
  end

  def initial_setup
    setup_pawn
    setup_rook
    setup_knight
    setup_bishop
    setup_queen
    setup_king
  end

  def setup_pawn
    @board[1].each_index do |index|
      @board[1][index] = Pawn.new('B', [1,index],'pawn')
    end
    @board[6].each_index do |index|
      @board[6][index] = Pawn.new('W', [6,index],'pawn')
    end
  end

  def setup_rook
    setup_uniques(0, Rook, 'rook', 'B')
    setup_uniques(0, Rook, 'rook', 'W')
  end

  def setup_knight
    setup_uniques(1, Knight, 'knight', 'B')
    setup_uniques(1, Knight, 'knight', 'W')
  end

  def setup_bishop
    setup_uniques(2, Bishop, 'bishop', 'B')
    setup_uniques(2, Bishop, 'bishop', 'W')
  end

  def setup_queen
    @board[0][3] = Queen.new('B',[0,3],'queen')
    @board[7][3] = Queen.new('W',[7,3],'queen')
  end

  def setup_king
    @board[0][4] = King.new('B',[0,4],'king')
    @board[7][4] = King.new('W',[7,4],'king')
  end

  def setup_uniques (position, class_name, piece, color)
    color == 'B' ? side = 0 : side = 7
    @board[side].each_index do |index|
      if index == position || index == 7-position
        @board[side][index] = class_name.new(color,[side,index],piece)
      end
    end
  end

end

class Game

  def initialize (board=GameBoard.new, turn='W')
    @board = board
    @turn = turn
  end

end

#Access color, position, symbol
class ChessPiece
  attr_accessor :color, :position
  attr_reader :symbol, :piece

  def initialize (color, position, piece)
    @color = color
    @position = position
    @piece = piece
    @symbol = mark(piece)
  end

  def mark piece
    pieces = ['king','queen','rook','bishop','knight','pawn']
    uni_codes = [
      "\u265A","\u265B","\u265C","\u265D","\u265E","\u265F",
      "\u2654","\u2655","\u2656","\u2657","\u2658","\u2659"
    ]
    index = pieces.find_index(piece)
    return uni_codes[index] if @color == 'W'
    return uni_codes[index+6] if @color == 'B'
  end
end

#En Passant, end of the board change
class Pawn < ChessPiece

  def next_positions board
  end
end

class Knight < ChessPiece

  def next_positions board
  end
end

class Bishop < ChessPiece

  def next_positions board
  end
end

#King <=> Rook switch
class Rook < ChessPiece

  def next_positions board
  end
end

class Queen < ChessPiece

  def next_positions board
  end
end

#King <=> Rook switch
class King < ChessPiece

  def next_positions board
  end
end
