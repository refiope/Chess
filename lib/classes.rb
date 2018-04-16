#Chess
#
#- Finished 2018.04.16
#
#- Array with size 8 x 8 is initialized with objects representing different pieces
#
#placed in appropriate positions. Players are allowed to select a piece (ex. 'a5', or 'f2') or enter 'save'
#
#to save the process, whether the player is in check or not doesn't matter. When a piece
#
#is selected, it checks whether it has available moves, and if it does, it stores the piece's
#
#information in @selected variable, and it calls get_next method from the @selected object which
#
#creates hash data that contains moves. Moves that are normal are stored as positions inside the hash @next_moves
#
#and it's key is called :regular, while special moves (ex. en passant, castling, etc) are stored inside
#
#the hash with appropriate names and keys with available positions on the board. After a piece is selected,
#
#players input a position (ex. 'a5', or 'f2') and the program checks whether the input is included inside the hash data
#
#of regular moves or special moves. Whether the player's king will be checked after making the move or the player will check/checkmate
#
#the opponent's king is checked every time the player makes the move. The condition to end
#
#the game is either check_mate, stale_mate, or inputting 'save'.

require 'json'

class GameBoard
  attr_accessor :board

  def initialize
    @board = []
    8.times { @board.push(Array.new(8,nil)) }
    initial_setup
  end

  #Displaying the board with appropriate guides ex. a-h, 1-8
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

  #For testing purpose, below is commented out
  #private

  #Guide for counting column
  def display_column_order
    column_order = ['a','b','c','d','e','f','g','h']
    print "  "
    column_order.each do |letter|
      print letter + "  "
    end
    puts ""
  end

  #Setting up pieces at appropriate places
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

  #Setup method for rook, knight, bishop
  def setup_uniques (position, class_name, piece, color)
    color == 'B' ? side = 0 : side = 7
    @board[side].each_index do |index|
      if index == position || index == 7-position
        @board[side][index] = class_name.new(color,[side,index],piece)
      end
    end
  end

end

#Checks conditions for check_mate, stale_mate, and receives inputs from player
class Game
  #Instance variables below are accessed for test purposes
  attr_accessor :turn, :board, :checking_piece, :checked_king
  attr_reader :selected

  #Allowing neccessary parameters to serialize/deserialize data
  def initialize (board=GameBoard.new, turn='W', in_check=false,
                  checking_piece=nil, checked_king=nil)
    @board = board
    @turn = turn
    @selected = nil
    @in_check = in_check
    @checking_piece = checking_piece
    @checked_king = checked_king
    @check_mate = false
    @save = false
  end

  #Main loop for playing the game: display board -> get input -> change turn
  #Breaks out of loop if check mate, stale mate, or save requested
  def play
    while(!@check_mate) do
      @board.display
      if @in_check
        display_turn
        puts "#{@turn} in check"
        check_mode
        break if @save
        change_turn
      else
        break if stale_mate?
        display_turn
        puts "Select piece: "
        select(get_input)
        break if @save
        puts "You selected #{@selected.piece}. Choose where to move your piece: "
        get_move
        change_turn
      end
    end
    end_message
  end

  #For testing purpose, below is commented out
  #private

  def end_message
    if @check_mate
      @board.display
      puts "Checkmate!"
    elsif !@save
      @board.display
      puts "Stalemate!"
    end
  end

  def display_turn
    puts "White's turn" if @turn == 'W'
    puts "Black's turn" if @turn == 'B'
  end

  def change_turn
    @turn == 'W' ? @turn = 'B' : @turn = 'W'
  end

  #Called when current player is in check: if player is still in check after
  #moving piece, calls itself again to select/move piece
  def check_mode
    puts "Select piece: "
    select(get_input)
    return if @save
    puts "You selected #{@selected.piece}. Choose where to move your piece: "
    check_mode if check_mode_move(get_input).nil?
  end

  #Gets called by select, move, check_mode_move
  #Converts player input, and serialize to json if input is 'save'
  def get_input
    order = ['a','b','c','d','e','f','g','h']
    input = gets.chomp

    if input == ''
      get_input
    elsif input == 'save'
      @save = true
      File.open("./save/save.txt", "w") do |file|
        file.puts game_to_json
      end
      to_json_board
      to_json_check
    elsif input[0].between?('a','h') && input[1].between?('1','8')
      row = (input[1].to_i - 8).abs
      column = order.find_index(input[0])
      return [row, column]
    else
      puts "Wrong input"
      get_input
    end
  end

  #Selects piece (sets @selected)
  def select input
    return if @save

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

  #Calling #move again if player inputs invalid move
  def get_move
    get_move if move(get_input).nil?
  end

  #Moves the @selected piece to target position if it's a valid move
  #This method also checks all possible conditions: getting yourself in check,
  #checking/check mating opponent, etc. Also disables jump, or castling after moving
  def move input
    return if @save

    @selected.get_next(@board.board)
    row, column = @selected.position[0], @selected.position[1]
    reset_passant
    valid_move = check_regular_move(input)
    valid_move = check_special_move(input) if valid_move.nil?

    if valid_move.nil?
      puts "#{@selected.piece} can't move there. Choose again"
      return nil
    elsif !king_in_check_after?(valid_move, @board.board)
      move_piece(valid_move, @board.board, row, column)
      if move_checks_king?(valid_move)
        @check_mate = true if check_mate?
      end
      @selected.can_castle = false if @selected.piece == 'rook' || @selected.piece == 'king'
      @selected.jump_used = true if @selected.piece == 'pawn'
      return true
    end
  end

  #Similar to #move, but if current player's king is in check after moving, method
  #returns nil
  def check_mode_move input
    return if @save

    clone = @board.board
    @selected.get_next(clone)
    row, column = @selected.position[0], @selected.position[1]
    reset_passant

    valid_move = check_regular_move(input)
    valid_move = check_special_move(input) if valid_move.nil?

    if valid_move.nil?
      return nil
    else
      move_piece(valid_move, clone, row, column)
      return nil if check_king(clone)

      move_piece(valid_move, @board.board, row, column)
      if move_checks_king?(valid_move)
        @check_mate = true if check_mate?
      end
      @selected.can_castle = false if @selected.piece == 'rook' || @selected.piece == 'king'
      @selected.jump_used = true if @selected.piece == 'pawn'
      return true
    end
  end

  #Checks if moving the piece checks the king, and changes values of instance variables
  #if in check/not in check
  def move_checks_king? move
    moved_piece = @board.board[move[0]][move[1]]
    moved_piece.get_next(@board.board)

    moved_piece.next_moves[:regular].each do |move|
      tile = @board.board[move[0]][move[1]]
      if !tile.nil? && tile.color == moved_piece.opposite_color && tile.piece == 'king'
        @checking_piece = moved_piece
        @in_check = true
        @checked_king = tile
        return true
      end
    end

    @checking_piece = nil
    @in_check = false
    @checked_king = nil
    return false
  end

  #Uses the updated values of variables changed in #move_checks_king? and checks check mate
  #The condition for check mate is if king has no moves available and there are no piece that
  #could eliminate the piece that is checking the king (if the piece is rook, bishop, or queen,
  #it's not check mate if a piece can get in between king and the checking piece)
  def check_mate?
    @checked_king.get_next(@board.board)
    return false if !@checked_king.next_moves[:regular].empty?

    special_case = ['rook','bishop','queen']
    special_case = true if special_case.include?(@checking_piece.piece)

    @checking_piece.get_next(@board.board)
    c_row, c_column = @checking_piece.position[0], @checking_piece.position[1]

    @board.board.each_index do |row|
      @board.board[row].each do |tile|
        if !tile.nil? && tile.color == @checked_king.color && tile.piece != 'king'
          tile.get_next(@board.board)
          if tile.next_moves[:regular].include?([c_row, c_column])
            return false
          elsif special_case == true
            return false if check_in_the_way(tile) == true
          end
        end
      end
    end

    return true
  end

  #If not in check, but there are absolutely no moves available then it is stalemate
  def stale_mate?
    @board.board.each_index do |row|
      @board.board[row].each do |tile|
        if !tile.nil? && tile.color == @turn
          tile.get_next(@board.board)

          if tile.next_moves[:regular].empty? && tile.next_moves.keys[1..-1].empty?
            next
          else
            return false
          end

        end
      end
    end

    return true
  end

  #This method deals with the special_case of #check_mate? and checks if there is
  #a piece that can get between the @checking_piece and @checked_king
  def check_in_the_way tile
    #Calculating direction from the @checked_king to @checking_piece
    direction_row = @checking_piece.position[0] - @checked_king.position[0]
    direction_row = direction_row/direction_row.abs if direction_row != 0
    direction_column = @checking_piece.position[1] - @checked_king.position[1]
    direction_column = direction_column/direction_column.abs if direction_column != 0
    direction = [direction_row, direction_column]

    #Using the calcuated direction to check if any regular move gets in the way
    tile.get_next(@board.board)
    tile.next_moves[:regular].each do |move|
      d = direction

      while (move[0]+d[0]).between?(0,7) && (move[1]+d[1]).between?(0,7) do
        checking_tile = @board.board[move[0]+d[0]][move[1]+d[1]]

        if checking_tile == @checking_piece
          return true
        end

        d[0] += 1 if d[0] > 0
        d[0] -= 1 if d[0] < 0
        d[1] += 1 if d[1] > 0
        d[1] -= 1 if d[1] < 0
      end

    end

    return false
  end

  #Pawn can use en_passant right after the opponent's pawn jumps, so
  #to prevent pawns from getting en_passanted after more than one turn,
  #Pawn's be_passant(if true, opponent's pawn can use en_passant on you)
  #is set to false every turn
  def reset_passant
    @board.board.each_index do |row|
      @board.board[row].each do |tile|
        if !tile.nil? && tile.color == @turn && tile.piece == 'pawn'
          tile.be_passant = false
        end
      end
    end
  end

  #Moving the @selected piece in the board and updating it's position
  def move_piece (valid_move, board, row, column)
    board[valid_move[0]][valid_move[1]] = @selected
    board[valid_move[0]][valid_move[1]].position = valid_move
    board[valid_move[0]][valid_move[1]].row = valid_move[0]
    board[valid_move[0]][valid_move[1]].column = valid_move[1]
    board[row][column] = nil
  end

  #Check if player input is a valid regular move
  def check_regular_move (input)
    @selected.next_moves[:regular].each do |move|
      return input if input == move
    end
    return nil
  end

  #Check if player input is a valid special move
  def check_special_move (input)
    if @selected.next_moves.key(input).nil?
      return nil
    else
      return special_move(@selected.next_moves.key(input), input)
    end
  end

  #Using key value of hash data of moves to find out the right special move
  def special_move (move_type, input)
    case move_type
    #Pawn can't take enemy piece while moving up/down one tile, so it's considered special
    when :move
      return input

    #Pawn's ability to jump
    when :jump
      @selected.jump_used = true
      @selected.be_passant = true
      return input

    #Pawn's ability to en passant other piece
    when :en_passant
      side = 1 if @selected.color == 'W'
      side = -1 if @selected.color == 'B'
      @board.board[input[0]+side][input[1]] = nil
      return input

    #Pawn's ability to change piece at the end of the board: calls #change_piece
    when :end_pawn
      change_piece(input)
      return input

    #King can't castle while in check
    when :left_castle
      return nil if @in_check
      @selected.can_castle = false
      @board.board[input[0]][0] = nil
      @board.board[input[0]][3] = Rook.new(@selected.color,[input[0], 3],'rook',false)
      return input

    when :right_castle
      return nil if @in_check
      @selected.can_castle = false
      @board.board[input[0]][7] = nil
      @board.board[input[0]][5] = Rook.new(@selected.color, [input[0], 3], 'rook',false)
      return input

    else
      puts "Special move is not recognized: check special moves of classes"
    end
  end

  #Getting input from player to change piece for pawn
  def change_piece input
    color = @selected.color
    puts "Choose queen, knight, rook, or bishop to change your pawn"
    piece = gets.chomp
    case piece

      when 'queen'
        @selected = Queen.new(color,[input[0],input[1]],'queen')

      when 'knight'
        @selected = Knight.new(color,[input[0],input[1]],'knight')

      when 'rook'
        @selected = Rook.new(color,[input[0],input[1]],'rook')

      when 'bishop'
        @selected = Bishop.new(color,[input[0],input[1]],'bishop')

      else
        puts "Choose queen, knight, rook, or bishop"
        change_piece(input)
      end

  end

  #Checks whether rook, queen, or bishop checks king after moving piece
  def king_in_check_after? (input, board)
    return false if @selected.piece == 'king'

    possible_pieces = ['rook','queen','bishop']
    clone = board
    check_board = []
    8.times {check_board.push(Array.new(8,nil))}
    row,column = @selected.position[0], @selected.position[1]

    move_piece(input, clone, row, column)

    clone.each_index do |row|
      clone[row].each do |tile|
        if !tile.nil? && tile.color == @selected.opposite_color &&
           possible_pieces.include?(tile.piece)

          tile.get_next(clone)
          tile.next_moves[:regular].each do |move|
            check_board[move[0]][move[1]] = 'x'
          end
        end
      end
    end

    king_position = find_king(board)
    check_board[king_position[0]][king_position[1]].nil? ? false : true
  end

  #Find current player's king's position
  def find_king board
    board.each_index do |row|
      board[row].each do |tile|
        if !tile.nil? && tile.color == @turn && tile.piece == 'king'
          return tile.position
        end
      end
    end
  end

  #Check if the current player is in check with the given board
  def check_king board
    king_position = find_king(board)
    @turn == 'W' ? opponent = 'B' : opponent = 'W'

    board.each_index do |row|
      board[row].each do |tile|
        if !tile.nil? && tile.color == opponent && tile.piece != 'king'
          tile.get_next(board)

          tile.next_moves[:regular].each do |move|
              return true if move == king_position
          end
        end
      end
    end

    return false
  end

  #Serializes @turn and @in_check and puts the data into './save/save.txt'
  def game_to_json
    { :turn => @turn,
      :in_check => @in_check
    }.to_json
  end

  #Serializes the @checking_piece and @checked_king, which are important variables
  #to allow saving/loading game while in check, and puts the data into './save/check_save.txt'
  def to_json_check
      File.open("./save/check_save.txt",'w') do |file|
        if @in_check == false
          file.puts 'null'
          break
        end
        file.puts @checking_piece.piece_to_json
        file.puts @checked_king.piece_to_json
      end
  end

  #Serializes the game board and puts the data into './save/board_save.txt'
  def to_json_board
    File.open("./save/board_save.txt",'w') do |file|
      @board.board.each_index do |row|
        @board.board[row].each do |tile|
          if tile.nil?
            file.puts 'null'
          else
            file.puts tile.piece_to_json
          end
        end
      end
    end
  end

  #Deserializes the @checking_piece and @checked_king, which are important variables
  #to allow saving/loading game while in check, from the data in './save/check_save.txt'
  def self.from_json_check address
    check_related = []
    File.readlines(address).each do |line|
      if line == 'null'
        return [nil,nil]
      end
      check_related.push(create_piece_from_json(line))
    end
    return check_related
  end

  #Deserializes the game board from the data in './save/board_save.txt'
  def self.from_json_board address
    line_of_tiles = []

    File.readlines(address).each do |line|
      if line == 'null'
        line_of_tiles.push(nil)
      else
        line_of_tiles.push(create_piece_from_json(line))
      end
    end

    empty_board = []
    8.times { empty_board.push(Array.new(8,nil)) }

    loaded_board = load_board(empty_board, line_of_tiles)

    gameboard = GameBoard.new
    gameboard.board = loaded_board
    return gameboard
  end

  #Helper method for deserializing board: creating appropriate pieces from
  #save file's line
  def self.create_piece_from_json line
    if line.include?('pawn')
      return Pawn.from_json(line)

    elsif line.include?('knight')
      return Knight.from_json(line)

    elsif line.include?('rook')
      return Rook.from_json(line)

    elsif line.include?('bishop')
      return Bishop.from_json(line)

    elsif line.include?('queen')
      return Queen.from_json(line)

    elsif line.include?('king')
      return King.from_json(line)

    end
  end

  #Helper method for deserializing board: puts the converted info of array into the board
  def self.load_board empty_board, tiles
    counter = 0
    for row in 0..7
      for column in 0..7
        empty_board[row][column] = tiles[counter]
        counter += 1
      end
    end
    return empty_board
  end

  #Deserialize all info and make a new game
  def self.game_from_json (board_address, check_address, string)
    board = from_json_board(board_address)
    check_related = from_json_check(check_address)
    data = JSON.load string

    self.new board, data['turn'], data['in_check'],
             check_related[0], check_related[1]
  end

end

#Parent class for all pieces
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

  #For bishop, knight, queen
  def piece_to_json
    { :color => @color,
      :position => @position,
      :piece => @piece
    }.to_json
  end

  #For bishop, knight, queen
  def self.from_json string
    data = JSON.load string
    self.new data['color'], data['position'], data['piece']
  end

  #Assigning appropriate symbol for each piece according to the value @piece
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

  #Getting next moves for piece (erasing previous moves in this case)
  def get_next board
    @next_moves = Hash.new([])
    @next_moves[:regular] = []
  end
end

#Class for Pawn: has @jump_used to discern whether it can jump or not, and be_passant
#to discern if opponent's pawn can use en_passant on it
class Pawn < ChessPiece
  attr_accessor :jump_used, :be_passant

  def initialize (color, position, piece, jump_used=false, be_passant=false)
    super(color, position, piece)
    @jump_used = jump_used
    @be_passant = be_passant
  end

  #Serializing
  def piece_to_json
    {
      :color => @color,
      :position => @position,
      :piece => @piece,
      :jump_used => @jump_used,
      :be_passant => @be_passant
    }.to_json
  end

  #Deserializing
  def self.from_json string
    data = JSON.load string
    self.new data['color'], data['position'], data['piece'],
             data['jump_used'], data['be_passant']
  end

  #Getting next moves for pawn
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

  #Checking if pawn can take another piece
  def check_attack (row, column, move, board, direction)
    if (!board[row+move][column+direction].nil? &&
        board[row+move][column+direction].color == @opposite_color)
          @next_moves[:regular].push([row+move, column+direction])
    end
  end

  #Checking conditions for special moves
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

  #Checking if pawn can en passant
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

#Class for Knight
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

#Class for Bishop
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

#Class for Rook: @can_castle discerns whether rook can castle or not
class Rook < ChessPiece
  attr_accessor :can_castle

  def initialize(color, position, piece, can_castle=true)
    super(color, position,piece)
    @can_castle = can_castle
  end

  def piece_to_json
    {
      :color => @color,
      :position => @position,
      :piece => @piece,
      :can_castle => @can_castle
    }.to_json
  end

  def self.from_json string
    data = JSON.load string
    self.new data['color'], data['position'], data['piece'], data['can_castle']
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

#Class for Queen
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

#Class for King: @can_castle discerns whether it can castle or not
class King < ChessPiece

attr_accessor :can_castle

  def initialize(color, position, piece, can_castle=true)
    super(color, position, piece)
    @can_castle = can_castle
  end

  def piece_to_json
    {
      :color => @color,
      :position => @position,
      :piece => @piece,
      :can_castle => @can_castle
    }.to_json
  end

  def self.from_json string
    data = JSON.load string
    self.new data['color'], data['position'], data['piece'], data['can_castle']
  end

  #Getting next moves for King, it checks whether moving to an empty tile gets the player
  #in check or taking an opponent's piece gets the player in check
  def get_next board
    super(color)

    king_move = [[1,1],[-1,1],[1,-1],[-1,-1],
                [1,0],[0,1],[-1,0],[0,-1]]

    check_left_castle(@row, board) if @can_castle
    check_right_castle(@row, board) if @can_castle

    king_move.each do |move|

      if (@row+move[0]).between?(0,7) && (@column+move[1]).between?(0,7)

        if board[@row+move[0]][@column+move[1]].nil?

          next if move_in_check?(@row, @column, move, board)
          @next_moves[:regular].push([@row+move[0], @column+move[1]])

        else

          if board[@row+move[0]][@column+move[1]].color == @opposite_color
            next if taking_piece_but_checked?(@row,@column,move,board)
            @next_moves[:regular].push([@row+move[0], @column+move[1]])
          end

        end

      end

    end

  end

  #Checks if taking pieces gets yourself in check
  def taking_piece_but_checked? (row, column, move, board)
    board.each_index do |r|
      board[r].each do |tile|

        if !tile.nil? && tile.color == @opposite_color &&
           tile.position != [row+move[0], column+move[1]]

          if tile.piece != 'king'
            return true if check_bait(tile,row,column,move,board)
          else
            return true if check_bait_for_king(tile,row,column,move,board)
          end

        end

      end
    end
    return false
  end

  #Check if any opponent's piece checks the ally king's position which took an opponent piece
  def check_bait (tile, row, column, move, board)
    return false if [row+move[0], column+move[1]] == tile.position

    board[row+move[0]][column+move[1]].color = @color
    tile.get_next(board)

    if !tile.next_moves[:regular].empty?
      tile.next_moves[:regular].each do |potential|
        if potential == [row+move[0], column+move[1]]
          board[row+move[0]][column+move[1]].color = @opposite_color
          return true
        end
      end
    end
    board[row+move[0]][column+move[1]].color = @opposite_color
    return false
  end

  #Check if any opponent's king checks the ally king's position which took an opponent piece
  def check_bait_for_king (tile, row, column, move, board)
    king_move = [[1,1],[-1,1],[1,-1],[-1,-1],
                [1,0],[0,1],[-1,0],[0,-1]]
    k_row, k_column = tile.position[0], tile.position[1]

    king_move.each do |k_move|
      if (k_row+k_move[0]).between?(0,7) && (k_column+k_move[1]).between?(0,7)
        return true if [k_row+k_move[0],k_column+k_move[1]] == [row+move[0], column+move[1]]
      end
    end
    return false
  end

  #Check if in check by moving to an empty tile
  def move_in_check? (row, column, move, board)
    check_board = []
    8.times {check_board.push(Array.new(8,nil))}

    board.each_index do |r|
      board[r].each do |tile|

        if tile.nil?
          next
        elsif tile.color == @opposite_color
          if tile.piece == 'pawn'
            mark_x_for_pawn(tile, column, move, board, check_board)
          elsif tile.piece == 'king'
            mark_x_for_king(tile, check_board, board)
          else
            mark_x_without(tile, check_board, board)
          end
        end

      end
    end

    check_board[row+move[0]][column+move[1]] == 'x' ? true : false
  end

  #The below mark_x_... methods marks 'x' in the checkboard in #move_in_check? method
  #if the moved king's position is marked, it will not be able to move there
  def mark_x_without (tile, check_board, board)
    tile.get_next(board)

    if !tile.next_moves[:regular].empty?
      tile.next_moves[:regular].each do |potential|
        check_board[potential[0]][potential[1]] = 'x'
      end
    end
  end

  def mark_x_for_king (tile, check_board, board)
    king_move = [[1,1],[-1,1],[1,-1],[-1,-1],
                [1,0],[0,1],[-1,0],[0,-1]]
    row, column = tile.position[0], tile.position[1]

    king_move.each do |move|
      if (row+move[0]).between?(0,7) && (column+move[1]).between?(0,7)
        if board[row+move[0]][column+move[1]].nil?
          check_board[row+move[0]][column+move[1]] = 'x'
        end
      end
    end

  end

  def mark_x_for_pawn (tile, column, move, board, check_board)

    tile.color == 'W' ? pawn_row = -1 : pawn_row = 1
    pawn_moves = [[pawn_row,-1], [pawn_row,1]]
    pawn_moves.each do |p_move|
      if board[tile.position[0]+p_move[0]][tile.position[1]+p_move[1]].nil?
        check_board[tile.position[0]+p_move[0]][tile.position[1]+p_move[1]] = 'x'
      end
    end
  end

  #Checking whether if king can castle
  def check_left_castle (row,board)
    if left_empty(board) && !move_in_check?(row,2,[0,0],board)
      if !board[row][0].nil? && board[row][0].piece == 'rook' && board[row][0].can_castle
        @next_moves[:left_castle] = [row, 2]
      end
    end
  end

  def check_right_castle (row,board)
    if right_empty(board) && !move_in_check?(row,6,[0,0],board)
      if !board[row][7].nil? && board[row][7].piece == 'rook' && board[row][7].can_castle
        @next_moves[:right_castle] = [row, 6]
      end
    end
  end

  #Checking if tile is empty to be able to castle
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
