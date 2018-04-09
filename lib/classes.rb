
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
        print column.symbol if !column.nil?
        print " |" if !column.nil?
        print "  |" if column.nil?
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

#be_passant set false on the start of turn
#king/rook's can_castle set false when moved
class Game
  #accessing selected, board, turn for test purposes
  attr_accessor :turn, :board
  attr_reader :selected

  def initialize (board=GameBoard.new, turn='W')
    @board = board
    @turn = turn
    @selected = nil
  end

  #display board
  #prints who's turn it is
  #(done)select the given input - get it again if wrong or does not have any moves available
  #move the selected piece - 'cancel' to select again, wrong move == recursion
  #before moving piece, check if moving piece(other than the king) will make yourself in check
  #--will have to clone the board and simulate(check rook, bishop, queen)
  #before moving piece, check if opponent's king will be checked
  # -check if it's checkmate for king
  #change turn
  #back to first
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
      puts "Wrong input"
      get_input
    end
  end

  #input = [n,n]
  def select input

    if @board.board[input[0]][input[1]].nil?
      puts "Choose the right piece"
      select(get_input)
    elsif @board.board[input[0]][input[1]].color == @turn
      @selected = @board.board[input[0]][input[1]]
      @selected.get_next(@board.board)

      if @selected.next_moves[:regular].empty? && @selected.next_moves.keys[1..-1].empty?
        puts 'Selected piece has no moves available'
        select(get_input)
      end
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

    if !valid_move.nil?
      @board.board[valid_move[0]][valid_move[1]] = @selected
      @board.board[valid_move[0]][valid_move[1]].position = valid_move
      @board.board[valid_move[0]][valid_move[1]].row = valid_move[0]
      @board.board[valid_move[0]][valid_move[1]].column = valid_move[1]
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

  #jump, en_passant, left and right castle, pawn-end-game
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

    when :left_castle
      @selected.can_castle = false
      @board.board[input[0]][0] = nil
      @board.board[input[0]][3] = Rook.new(@selected.color,[input[0], 3],'rook',false)
      return input

    when :right_castle
      @selected.can_castle = false
      @board.board[input[0]][7] = nil
      @board.board[input[0]][5] = Rook.new(@selected.color, [input[0], 3], 'rook',false)
      return input

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

  def king_in_check_after?
  end

end

#Access color, position, symbol, next_moves
class ChessPiece
  attr_accessor :color, :position, :next_moves, :row, :column
  attr_reader :symbol, :piece, :opposite_color

  def initialize (color, position, piece)
    @color = color
    @opposite_color = opposite(color)
    @position = position
    @piece = piece
    @next_moves = Hash.new([])
    @symbol = mark(piece)
    @row = @position[0]
    @column = @position[1]
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

  def get_next board
    @next_moves = Hash.new([])
    @next_moves[:regular] = []
  end
end

#En Passant, end of the board change
#moving only one tile is considered special move for pawn
#because it cannot take opponent's piece this way
class Pawn < ChessPiece
  attr_accessor :jump_used, :be_passant

  def initialize (color, position, piece, jump_used=false, be_passant=false)
    super(color, position, piece)
    @jump_used = jump_used
    @be_passant = be_passant
  end

  def get_next board
  super(board)

    @color == 'W' ? move = -1 : move = 1

    direction = [-1,1]
    direction.each do |d|
      check_attack(@row, @column, move, board, d)
      check_en_passant(@row, @column, move, board, d)
    end
    check_moves(@row, @column, move, board)
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
        @next_moves[:move] = [row+move, column]
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

class Knight < ChessPiece

  def get_next board
    super(board)

    knight_moves = [[1,2],[-1,2],[1,-2],[-1,-2],
                    [2,1],[-2,1],[2,-1],[-2,-1]]

    knight_moves.each do |move|
      if (@row + move[0]).between?(0,7) &&
         (@column + move[1]).between?(0,7) &&
         if !board[@row+move[0]][@column+move[1]].nil?
           if board[@row+move[0]][@column+move[1]].color == @opposite_color
             @next_moves[:regular].push([@row+move[0],@column+move[1]])
           end
         else
           @next_moves[:regular].push([@row+move[0],@column+move[1]])
         end
      end
    end
  end

end

class Bishop < ChessPiece

  def get_next board
    super(color)

    bishop_move = [[1,1],[-1,1],[1,-1],[-1,-1]]

    bishop_move.each do |move|
      next_row, next_column = move[0], move[1]
      while (@row+next_row).between?(0,7) &&
            (@column+next_column).between?(0,7) do

        if board[@row+next_row][@column+next_column].nil?
          @next_moves[:regular].push([@row+next_row,@column+next_column])
        else
          if board[@row+next_row][@column+next_column].color == @opposite_color
            @next_moves[:regular].push([@row+next_row,@column+next_column])
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
  attr_accessor :can_castle

  def initialize(color, position, piece, can_castle=true)
    super(color, position,piece)
    @can_castle = can_castle
  end

  def get_next board
    super(color)

    rook_move = [[1,0],[0,1],[-1,0],[0,-1]]

    rook_move.each do |move|
      next_row, next_column = move[0], move[1]

      while (@row+next_row).between?(0,7) &&
              (@column+next_column).between?(0,7) do

       if board[@row+next_row][@column+next_column].nil?
          @next_moves[:regular].push([@row+next_row,@column+next_column])
        else
          if board[@row+next_row][@column+next_column].color == @opposite_color
            @next_moves[:regular].push([@row+next_row,@column+next_column])
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
    super(color)

    queen_move = [[1,1],[-1,1],[1,-1],[-1,-1],
                  [1,0],[0,1],[-1,0],[0,-1]]

    queen_move.each do |move|
      next_row, next_column = move[0], move[1]

      while (@row+next_row).between?(0,7) &&
            (@column+next_column).between?(0,7) do

        if board[@row+next_row][@column+next_column].nil?
          @next_moves[:regular].push([@row+next_row,@column+next_column])
        else
          if board[@row+next_row][@column+next_column].color == @opposite_color
            @next_moves[:regular].push([@row+next_row,@column+next_column])
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
attr_accessor :can_castle

  def initialize(color, position, piece, can_castle=true)
    super(color, position, piece)
    @can_castle = can_castle
  end

  def get_next board
    super(color)

    king_move = [[1,1],[-1,1],[1,-1],[-1,-1],
                [1,0],[0,1],[-1,0],[0,-1]]

    check_left_castle(@row, board)
    check_right_castle(@row, board)

    king_move.each do |move|
      if (@row+move[0]).between?(0,7) && (@column+move[1]).between?(0,7)
        if board[@row+move[0]][@column+move[1]].nil?
          next if move_in_check?(@row, @column, move, board)
          @next_moves[:regular].push([@row+move[0], @column+move[1]])
        else
          if board[@row+move[0]][@column+move[1]].color == @opposite_color
            @next_moves[:regular].push([@row+move[0], @column+move[1]])
          end
        end
      end
    end

  end

  def move_in_check? (row, column, move, board)
    check_board = []
    clone = board
    8.times {check_board.push(Array.new(8,nil))}

    board.each_index do |r|
      board[r].each do |tile|
        if tile.nil?
          next
        elsif tile.color == @opposite_color
          if tile.piece != 'pawn'
            mark_x_without_pawn(tile, row, check_board, board)
          else
            mark_x_for_pawn(tile, row, column, move, clone, check_board)
          end
        end
      end
    end

    check_board[row+move[0]][column+move[1]] == 'x' ? true : false
  end

  def mark_x_without_pawn (tile, row, check_board, board)
    tile.get_next(board)

    if !tile.next_moves[:regular].empty?
      tile.next_moves[:regular].each do |potential|
        check_board[potential[0]][potential[1]] = 'x'
      end
    end
  end

  def mark_x_for_pawn (tile, row, column, move, clone, check_board)
    clone[row+move[0]][column+move[1]] = King.new(@color,[],'king')
    clone[row][column] = nil
    tile.get_next(clone)

    if !tile.next_moves[:regular].empty?
      tile.next_moves[:regular].each do |potential|
        check_board[potential[0]][potential[1]] = 'x'
      end
    end
  end

  def check_left_castle (row,board)
    if @can_castle && !move_in_check?(row,2,[0,0],board)
      if !board[row][0].nil? && board[row][0].piece == 'rook' && board[row][0].can_castle
        @next_moves[:left_castle] = [row, 2] if left_empty(board)
      end
    end
  end

  def check_right_castle (row,board)
    if @can_castle && !move_in_check?(row,6,[0,0],board)
      if !board[row][7].nil? && board[row][7].piece == 'rook' && board[row][7].can_castle
        @next_moves[:right_castle] = [row, 6] if right_empty(board)
      end
    end
  end

  def left_empty board
    if @color == 'W'
      board[7][1..3].each do |tile|
        return false if !tile.nil?
      end
      return true
    else
      board[0][1..3].each do |tile|
        return false if !tile.nil?
      end
      return true
    end
  end

  def right_empty board
    if @color == 'W'
      board[7][5..6].each do |tile|
        return false if !tile.nil?
      end
      return true
    else
      board[0][5..6].each do |tile|
        return false if !tile.nil?
      end
      return true
    end
  end
end
