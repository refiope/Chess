
#Access board
class GameBoard
  attr_accessor :board

  def initialize
    @board = []
    8.times { @board.push(Array.new(8,nil)) }
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
      @board[1][index] = Pawn.new('B', [1,index],'pawn', false, false)
    end
    @board[6].each_index do |index|
      @board[6][index] = Pawn.new('W', [6,index],'pawn', false, false)
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

#Game needs to control special cases:
#ex. pawns with the jump, en passant, and piece change
#ex. rooks and kings with switch
class Game
  #accessing selected, board, turn for test purposes
  attr_accessor :turn, :board
  attr_reader :selected

  def initialize (board=GameBoard.new, turn='W')
    @board = board
    @turn = turn
    @selected = nil
  end

  def play
  end

  #a...h, 1...8
  def get_input
    order = ['a','b','c','d','e','f','g','h']
    input = gets.chomp
    if input[0].between?('a','h') && input[1].between?('1','8')
      row = (input[1].to_i - 8).abs
      column = order.find_index(input[0])
      return [row, column]
    else
      puts "wrong input"
      get_input
    end
  end

  #input = [n,n]
  def select input

    if @board.board[input[0]][input[1]].nil?
      puts "Choose the right piece"
    elsif @board.board[input[0]][input[1]].color == @turn
      @selected = @board.board[input[0]][input[1]]
    end

  end

  #input = [n,n]
  #this is also where you check if moving piece checks the king
  #the only case where that happens is rook, bishop, or queen
  def move input
    #this spends the turn: maybe reset all pawn's en_passant here?
    @selected.get_next(@board.board)
    row, column = @selected.position[0], @selected.position[1]

    valid_move = check_regular_move(input)
    valid_move = check_special_move(input) if valid_move.nil?

    #check if there's absolutely no move to be made
    if !valid_move.nil?
      @board.board[valid_move[0]][valid_move[1]] = @selected
      @board.board[valid_move[0]][valid_move[1]].position = valid_move
      @board.board[row][column] = nil
    end
  end

  def check_regular_move (input)
    @selected.next_moves[:regular].each do |move|
      return input if input == move
    end
    return nil
  end

  def check_special_move (input)
    if @selected.next_moves.key(input).nil?
      puts "You can't move there"
      return nil
      #start getting input again?
    else
      return special_move(@selected.next_moves.key(input), input)
    end
  end

  #jump, en_passant, switch, pawn-end-game
  #hint for en_passant, every turn, the current player's pawns become
  #ineligible for en_passant
  def special_move (move_type, input)
    case move_type
    when :move
      return input

    when :jump
      @selected.jump_used = true
      @selected.be_passant = true
      return input

    when :en_passant
      side = 1 if @selected.color == 'W'
      side = -1 if @selected.color == 'B'
      @board.board[input[0]+side][input[1]] = nil
      return input

    when :end_pawn
      change_piece
      return input

    when :switch

    else
    end
  end

  def change_piece
    color = @selected.color
    piece = gets.chomp
    case piece
      when 'queen'
        @selected = Queen.new(color,[],'queen')
      when 'knight'
        @selected = Knight.new(color,[],'knight')
      when 'rook'
        @selected = Rook.new(color,[],'rook')
      when 'bishop'
        @selected = Bishop.new(color,[],'bishop')
      else
        puts "Choose queen, knight, rook, or bishop"
        change_piece
      end
  end

end

#Access color, position, symbol, next_moves
class ChessPiece
  attr_accessor :color, :position, :next_moves
  attr_reader :symbol, :piece, :opposite_color

  def initialize (color, position, piece)
    @color = color
    @opposite_color = opposite(color)
    @position = position
    @piece = piece
    @next_moves = Hash.new([])
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

  def opposite color
    return 'B' if @color == 'W'
    return 'W' if @color == 'B'
  end
end

#En Passant, end of the board change
#moving only one tile is considered special move for pawn
#because it cannot take opponent's piece this way
class Pawn < ChessPiece
  attr_accessor :jump_used, :be_passant

  def initialize (color, position, piece, jump_used, be_passant)
    super(color, position, piece)
    @jump_used = jump_used
    @be_passant = be_passant
  end

  def get_next board
    @next_moves = Hash.new([])
    @next_moves[:regular] = []

    row, column = @position[0], @position[1]

    @color == 'W' ? move = -1 : move = 1

    direction = [-1,1]
    direction.each do |d|
      check_attack(row, column, move, board, d)
      check_en_passant(row, column, move, board, d)
    end
    check_moves(row, column, move, board)
  end

  def check_attack (row, column, move, board, direction)
    if (!board[row+move][column+direction].nil? &&
        board[row+move][column+direction].color == @opposite_color)
          @next_moves[:regular].push([row+move, column+direction])
    end
  end

  def check_moves (row, column, move, board)
    if board[row+move][column].nil?
      if row + move == 7 ||row + move == 0
        @next_moves[:end_pawn] = [row+move, column]
      else
        @next_moves[:move].push([row+move, column])
      end
      if board[row + 2*move][column].nil? && @jump_used == false
        @next_moves[:jump] = [row + 2*move, column]
      end
    end
  end

  def check_en_passant (row, column, move, board, direction)
    if (!board[row][column+direction].nil? &&
        board[row+move][column+direction].nil? &&
        board[row][column+direction].color == @opposite_color &&
        board[row][column+direction].piece == 'pawn' &&
        board[row][column+direction].be_passant == true)
          @next_moves[:en_passant] = [row+move, column+direction]
    end
  end

end

#each piece needs #get_next method where it pushes next possible moves to
#next_moves, which is initiated with class ChessPiece
#each piece may have to check if it's checking every move
class Knight < ChessPiece

  def get_next board
    @next_moves = Hash.new([])
    @next_moves[:regular] = []

    row, column = @position[0], @position[1]

    knight_moves = [[1,2],[-1,2],[1,-2],[-1,-2],
                    [2,1],[-2,1],[2,-1],[-2,-1]]

    knight_moves.each do |move|
      if (row + move[0]).between?(0,7) &&
         (column + move[1]).between?(0,7) &&
         if !board[row+move[0]][column+move[1]].nil?
           if board[row+move[0]][column+move[1]].color == @opposite_color
             @next_moves[:regular].push([row+move[0],column+move[1]])
           end
         else
           @next_moves[:regular].push([row+move[0],column+move[1]])
         end
      end
    end
  end

end

class Bishop < ChessPiece

  def get_next board
    @next_moves = Hash.new([])
    @next_moves[:regular] = []

    row, column = @position[0], @position[1]

    bishop_move = [[1,1],[-1,1],[1,-1],[-1,-1]]

    bishop_move.each do |move|
      next_row, next_column = move[0], move[1]
      while (row+next_row).between?(0,7) &&
            (column+next_column).between?(0,7) do

        if board[row+next_row][column+next_column].nil?
          @next_moves[:regular].push([row+next_row,column+next_column])
        else
          if board[row+next_row][column+next_column].color == @opposite_color
            @next_moves[:regular].push([row+next_row,column+next_column])
            break
          else
            break
          end
        end

        next_row > 0 ? next_row += 1 : next_row -= 1
        next_column > 0 ? next_column += 1 : next_column -= 1

      end
    end
  end

end

class Rook < ChessPiece

    def get_next board
      @next_moves = Hash.new([])
      @next_moves[:regular] = []

      row, column = @position[0], @position[1]

      rook_move = [[1,0],[0,1],[-1,0],[0,-1]]

      rook_move.each do |move|
        next_row, next_column = move[0], move[1]

        while (row+next_row).between?(0,7) &&
              (column+next_column).between?(0,7) do

          if board[row+next_row][column+next_column].nil?
            @next_moves[:regular].push([row+next_row,column+next_column])
          else
            if board[row+next_row][column+next_column].color == @opposite_color
              @next_moves[:regular].push([row+next_row,column+next_column])
              break
            else
              break
            end
          end

          next_row += 1 if next_row > 0
          next_row -= 1 if next_row < 0
          next_column += 1 if next_column > 0
          next_column -= 1 if next_column < 0
        end
      end

    end

end

class Queen < ChessPiece

  def get_next board
    @next_moves = Hash.new([])
    @next_moves[:regular] = []

    row, column = @position[0], @position[1]

    queen_move = [[1,1],[-1,1],[1,-1],[-1,-1],
                  [1,0],[0,1],[-1,0],[0,-1]]

    queen_move.each do |move|
      next_row, next_column = move[0], move[1]

      while (row+next_row).between?(0,7) &&
            (column+next_column).between?(0,7) do

        if board[row+next_row][column+next_column].nil?
          @next_moves[:regular].push([row+next_row,column+next_column])
        else
          if board[row+next_row][column+next_column].color == @opposite_color
            @next_moves[:regular].push([row+next_row,column+next_column])
            break
          else
            break
          end
        end

        next_row += 1 if next_row > 0
        next_row -= 1 if next_row < 0
        next_column += 1 if next_column > 0
        next_column -= 1 if next_column < 0
      end
    end
  end
end

#King <=> Rook switch
class King < ChessPiece
  def get_next board
    @next_moves = Hash.new([])
    @next_moves[:regular] = []

    row, column = @position[0], @position[1]

    king_move = [[1,1],[-1,1],[1,-1],[-1,-1],
                [1,0],[0,1],[-1,0],[0,-1]]

    king_move.each do |move|
      if (row+move[0]).between?(0,7) && (column+move[1]).between?(0,7)
        if board[row+move[0]][column+move[1]].nil?
          next if mic_check_check(row, column, move, board)
          @next_moves[:regular].push([row+move[0], column+move[1]])
        else
          if board[row+move[0]][column+move[1]].color == @opposite_color
            @net_moves[:regular].push([row+move[0], column+move[1]])
          end
        end
      end
    end

  end

  def mic_check_check (row, column, move, board)
    check_board = []
    clone = board
    8.times {check_board.push(Array.new(8,nil))}

    board.each_index do |r|
      board[r].each do |tile|
        if !tile.nil?
          if tile.color == @opposite_color && tile.piece != 'pawn'
            tile.get_next(board)
            tile.next_moves[:regular].each do |potential|
              check_board[potential[0]][potential[1]] = 'x'
            end
          else
            clone[row+move[0]][column+move[1]] = King.new(@color,[],'king')
            clone[row][column] = nil
            tile.get_next(clone)
            tile.next_moves[:regular].each do |potential|
              check_board[potential[0]][potential[1]] = 'x'
            end
          end
        end
      end
    end

    check_board[row+move[0]][column+move[1]] == 'x' ? true : false
  end
end
