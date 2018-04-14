require 'classes'

describe 'Chess game' do

  describe Game do
    #keep in mind that new game starts with white's turn
    before(:each) do |example|
      @game = Game.new
      @empty_board = GameBoard.new
      @empty_array = []
      8.times {@empty_array.push(Array.new(8,nil))}
      @empty_board.board = @empty_array

      @empty_game = Game.new(@empty_board)

      #not putting in parameters makes both jump_used, be_passant false
      if example.metadata[:pawn_test]
        @empty_game.board.board[0][2] = Pawn.new('B',[0,2],'pawn')
        @empty_game.board.board[1][0] = Pawn.new('W',[1,0],'pawn',true)
        @empty_game.board.board[3][3] = Pawn.new('B',[3,3],'pawn',true)
        @empty_game.board.board[4][2] = Pawn.new('W',[4,2],'pawn',true)
        @empty_game.board.board[7][2] = Pawn.new('W',[7,2],'pawn',true)
        @empty_game.board.board[7][3] = Pawn.new('W',[7,3],'pawn')
        @empty_game.board.board[5][0] = Pawn.new('B',[5,0],'pawn',true,true)
        @empty_game.board.board[5][1] = Pawn.new('W',[5,1],'pawn',true,false)
      end

      if example.metadata[:knight_test]
        @empty_game.board.board[2][2] = Knight.new('W',[2,2],'knight')
        @empty_game.board.board[3][4] = Knight.new('W',[3,4],'knight')
        @empty_game.board.board[5][2] = Knight.new('B',[5,2],'knight')
        @empty_game.board.board[0][1] = Bishop.new('B',[0,1],'bishop')
      end

      unless example.metadata[:skip_before]
        @empty_game.board.board[4][7] = King.new('W',[4,7],'king')
        @empty_game.board.board[2][7] = King.new('B',[2,7],'king')
      end
    end

    context '#select' do

      it 'selects the right piece' do
        @game.select([6,0])
        expect(@game.selected).to eql(@game.board.board[6][0])
      end

      it 'does not select empty tile' do
        allow(@game).to receive(:gets).and_return('a2')

        #should ask for input again if wrong input, and will replace input with white pawn
        @game.select([2,4])
        expect(@game.selected.piece).to eql('pawn')
      end

      it "does not select opposite side's piece" do
        allow(@game).to receive(:gets).and_return('a2')

        #should ask for input again if wrong input, and will replace input with white pawn
        @game.select([2,0])
        expect(@game.selected.piece).to eql('pawn')
      end

    end

    context '#move' do
      #Should be able to en_passant: [5,1] -> [4,0]
      #Should be able to change piece: [1,0] -> [0,0]
      #Should be able to take enemy piece: [3,3] -> [4,2]
      #Should not be able to jump twice: [7,2] -> [5,2] -> nil

      context 'movements with pawn', pawn_test: true do

        #White Pawn Position: [7,3]
        it 'moves white pawn one tile up' do
          @empty_game.select([7,3])
          @empty_game.move([6,3])

          expect(@empty_game.board.board[6][3].piece).to eql('pawn')
          expect(@empty_game.board.board[6][3].position).to eql([6,3])
          expect(@empty_game.board.board[7][3]).to eql(nil)
        end

        #Black Pawn Position: [0,2]
        it 'moves black pawn one tile down' do
          @empty_game.turn = 'B'
          @empty_game.select([0,2])
          @empty_game.move([1,2])

          expect(@empty_game.board.board[1][2].piece).to eql('pawn')
          expect(@empty_game.board.board[1][2].position).to eql([1,2])
          expect(@empty_game.board.board[0][2]).to eql(nil)
        end

        #White Pawn Position: [7,3], jump_used == false (should be able to jump)
        it 'allows jump for white pawn' do
          @empty_game.select([7,3])
          @empty_game.move([5,3])

          expect(@empty_game.board.board[5][3].piece).to eql('pawn')
          expect(@empty_game.board.board[5][3].position).to eql([5,3])
          expect(@empty_game.board.board[7][3]).to eql(nil)
          expect(@empty_game.board.board[5][3].jump_used).to be true
        end

        #Black Pawn Position: [0,2], jump_used == false (should be able to jump)
        it 'allows jump for black pawn' do
          @empty_game.turn = 'B'
          @empty_game.select([0,2])
          @empty_game.move([2,2])

          expect(@empty_game.board.board[2][2].piece).to eql('pawn')
          expect(@empty_game.board.board[2][2].position).to eql([2,2])
          expect(@empty_game.board.board[0][2]).to eql(nil)
          expect(@empty_game.board.board[2][2].jump_used).to be true
        end

        #White Pawn Position: [7,2], jump_used == true (should not be able to jump)
        it 'does not allow jump twice' do
          @empty_game.select([7,2])
          expect(@empty_game.move([5,2])).to eql(nil)
        end

        #White Pawn Position: [5,1]
        #Black Pawn Position: [5,0], be_passant == true (can be en_passanted)
        it 'white pawn can en_passant' do
          @empty_game.select([5,1])
          @empty_game.move([4,0])

          expect(@empty_game.board.board[5][0]).to eql(nil)
          expect(@empty_game.board.board[4][0].piece).to eql('pawn')
          expect(@empty_game.board.board[5][1]).to eql(nil)
        end

        #White Pawn Position: [1,0]
        it 'changes white pawn at the end of the board' do
          allow(@empty_game).to receive(:gets).and_return('queen')

          @empty_game.select([1,0])
          @empty_game.move([0,0])

          expect(@empty_game.board.board[0][0].piece).to eql('queen')
          expect(@empty_game.board.board[0][0].color).to eql('W')
          expect(@empty_game.board.board[0][0].position).to eql([0,0])
        end

        it 'does not allow invalid moves for pawn' do
          @empty_game.select([7,3])

          expect(@empty_game.move([7,4])).to eql(nil)
        end

        #White Pawn Position: [4,2]
        #Black Pawn Position: [3,3]
        it 'takes enemy piece' do
          @empty_game.turn = 'B'
          @empty_game.select([3,3])
          @empty_game.move([4,2])

          expect(@empty_game.board.board[4][2].color).to eql('B')
          expect(@empty_game.board.board[3][3]).to eql(nil)
        end
      end

      #White Knight Positions: [2,2], [3,4]
      #Black Knight Position: [5,2]
      #Black Bishop Position: [0,1]
      context 'movements with knight', knight_test: true do

        it 'moves white to right positions' do
          @empty_game.select([2,2])
          @empty_game.move([1,4])

          expect(@empty_game.board.board[1][4].piece).to eql('knight')
          expect(@empty_game.board.board[1][4].color).to eql('W')
          expect(@empty_game.board.board[1][4].position).to eql([1,4])
          expect(@empty_game.board.board[2][2]).to eql(nil)
        end

        it 'moves black to right positions' do
          @empty_game.turn = 'B'
          @empty_game.select([5,2])
          @empty_game.move([3,3])

          expect(@empty_game.board.board[3][3].piece).to eql('knight')
          expect(@empty_game.board.board[3][3].color).to eql('B')
        end

        it "does not move to ally's piece" do
          @empty_game.select([3,4])

          expect(@empty_game.move([2,2])).to eql(nil)
        end

        it 'does not make invalid moves' do
          @empty_game.select([3,4])

          expect(@empty_game.move([5,6])).to eql(nil)
        end

        it 'takes enemy piece' do
          @empty_game.select([2,2])
          @empty_game.move([0,1])

          expect(@empty_game.board.board[0][1].piece).to eql('knight')
          expect(@empty_game.board.board[0][1].color).to eql('W')
        end
      end

      context 'movements with bishop' do

        it 'white bishop makes right move' do
          @empty_game.board.board[3][3] = Bishop.new('W',[3,3],'bishop')
          @empty_game.select([3,3])
          @empty_game.move([0,0])

          expect(@empty_game.board.board[0][0].piece).to eql('bishop')
        end

        it 'does not make invalid move' do
          @empty_game.turn = 'B'
          @empty_game.board.board[3][3] = Bishop.new('B',[3,3],'bishop')
          @empty_game.select([3,3])

          expect(@empty_game.move([2,3])).to eql(nil)
        end

        it 'does not go past ally piece' do
          @empty_game.board.board[3][3] = Bishop.new('W',[3,3],'bishop')
          @empty_game.board.board[1][1] = Bishop.new('W',[1,1],'bishop')
          @empty_game.select([3,3])

          expect(@empty_game.move([0,0])).to eql(nil)
        end

        it 'does not go past enemy piece' do
          @empty_game.turn = 'B'
          @empty_game.board.board[3][3] = Bishop.new('B',[3,3], 'bishop')
          @empty_game.board.board[1][1] = Bishop.new('W',[1,1], 'bishop')
          @empty_game.select([3,3])

          expect(@empty_game.move([0,0])).to eql(nil)
        end

        it 'does take enemy piece' do
          @empty_game.turn = 'B'
          @empty_game.board.board[3][3] = Bishop.new('B',[3,3], 'bishop')
          @empty_game.board.board[1][1] = Bishop.new('W',[1,1], 'bishop')
          @empty_game.select([3,3])
          @empty_game.move([1,1])

          expect(@empty_game.board.board[1][1].color).to eql('B')
        end

        it 'does not take ally piece' do
          @empty_game.board.board[3][3] = Bishop.new('W',[3,3], 'bishop')
          @empty_game.board.board[1][1] = Bishop.new('W',[1,1], 'bishop')
          @empty_game.select([3,3])

          expect(@empty_game.move([1,1])).to eql(nil)
        end
      end

      context 'movements with rook' do

        it 'makes the right move' do
          @empty_game.board.board[3][3] = Rook.new('W',[3,3], 'rook')
          @empty_game.select([3,3])
          @empty_game.move([0,3])

          expect(@empty_game.board.board[0][3].piece).to eql('rook')
        end

        it 'does not make invalid move' do
          @empty_game.turn = 'B'
          @empty_game.board.board[3][3] = Rook.new('B',[3,3],'rook')
          @empty_game.select([3,3])

          expect(@empty_game.move([2,2])).to eql(nil)
        end

        it 'does not go past ally piece' do
          @empty_game.board.board[3][3] = Rook.new('W',[3,3],'rook')
          @empty_game.board.board[3][1] = Rook.new('W',[3,1],'rook')
          @empty_game.select([3,3])

          expect(@empty_game.move([3,0])).to eql(nil)
        end

        it 'does not go past enemy piece' do
          @empty_game.turn = 'B'
          @empty_game.board.board[3][3] = Rook.new('B',[3,3], 'rook')
          @empty_game.board.board[3][1] = Rook.new('W',[3,1], 'rook')
          @empty_game.select([3,3])

          expect(@empty_game.move([3,0])).to eql(nil)
        end

        it 'does take enemy piece' do
          @empty_game.turn = 'B'
          @empty_game.board.board[3][3] = Rook.new('B',[3,3], 'rook')
          @empty_game.board.board[3][1] = Rook.new('W',[3,1], 'rook')
          @empty_game.select([3,3])
          @empty_game.move([3,1])

          expect(@empty_game.board.board[3][1].color).to eql('B')
        end

        it 'does not take ally piece' do
          @empty_game.board.board[3][3] = Rook.new('W',[3,3], 'rook')
          @empty_game.board.board[3][1] = Rook.new('W',[3,1], 'rook')
          @empty_game.select([3,3])

          expect(@empty_game.move([3,1])).to eql(nil)
        end
      end

      context 'movements with queen' do

        it 'makes the right move' do
          @empty_game.board.board[3][3] = Queen.new('W',[3,3], 'queen')
          @empty_game.select([3,3])
          @empty_game.move([4,2])

          expect(@empty_game.board.board[4][2].piece).to eql('queen')
        end
        it 'does not make invalid move' do
          @empty_game.turn = 'B'
          @empty_game.board.board[3][3] = Queen.new('B',[3,3],'queen')
          @empty_game.select([3,3])

          expect(@empty_game.move([5,4])).to eql(nil)
        end

        it 'does not go past ally piece' do
          @empty_game.board.board[3][3] = Queen.new('W',[3,3],'queen')
          @empty_game.board.board[3][1] = Rook.new('W',[3,1],'rook')
          @empty_game.select([3,3])

          expect(@empty_game.move([3,0])).to eql(nil)
        end

        it 'does not go past enemy piece' do
          @empty_game.turn = 'B'
          @empty_game.board.board[3][3] = Queen.new('B',[3,3], 'queen')
          @empty_game.board.board[1][1] = Rook.new('W',[0,0], 'rook')
          @empty_game.select([3,3])

          expect(@empty_game.move([0,0])).to eql(nil)
        end

        it 'does take enemy piece' do
          @empty_game.turn = 'B'
          @empty_game.board.board[3][3] = Queen.new('B',[3,3], 'queen')
          @empty_game.board.board[6][6] = Rook.new('W',[6,6], 'rook')
          @empty_game.select([3,3])
          @empty_game.move([6,6])

          expect(@empty_game.board.board[6][6].color).to eql('B')
        end

        it 'does not take ally piece' do
          @empty_game.board.board[3][3] = Queen.new('W',[3,3], 'queen')
          @empty_game.board.board[5][1] = Bishop.new('W',[5,1], 'rook')
          @empty_game.select([3,3])

          expect(@empty_game.move([5,1])).to eql(nil)
        end
      end

      context 'movements with king', skip_before: true do

        it 'makes regular movements' do
          @empty_game.board.board[3][3] = King.new('W',[3,3],'king',true)
          @empty_game.select([3,3])
          @empty_game.move([2,3])

          expect(@empty_game.board.board[2][3].piece).to eql('king')
          expect(@empty_game.board.board[3][3]).to eql(nil)
        end

        it 'takes enemy piece' do
          @empty_game.board.board[3][3] = King.new('W',[3,3],'king',false)
          @empty_game.board.board[2][3] = Pawn.new('B',[2,3],'pawn',false,false)
          @empty_game.select([3,3])
          @empty_game.move([2,3])

          expect(@empty_game.board.board[2][3].piece).to eql('king')
        end

        it 'does not take ally piece' do
          @empty_game.board.board[3][3] = King.new('W',[3,3],'king',false)
          @empty_game.board.board[2][3] = Pawn.new('W',[2,3],'pawn',false,false)
          @empty_game.select([3,3])

          expect(@empty_game.move([2,3])).to eql(nil)
        end

        it 'does not move into check: pawn version' do
          @empty_game.board.board[3][3] = King.new('W',[3,3],'king',false)
          @empty_game.board.board[0][7] = King.new('B',[0,7],'king',false)
          @empty_game.board.board[2][3] = Pawn.new('B',[2,3],'pawn',false,false)
          @empty_game.select([3,3])
          expect(@empty_game.move([3,2])).to eql(nil)
        end

        it 'does not move into check: knight version' do
          @empty_game.board.board[3][3] = King.new('W',[3,3],'king',false)
          @empty_game.board.board[0][1] = Knight.new('B',[0,1],'knight')
          @empty_game.select([3,3])

          expect(@empty_game.move([2,2])).to eql(nil)
        end

        it 'does not move into check: rook version' do
          @empty_game.board.board[3][3] = King.new('W',[3,3],'king',false)
          @empty_game.board.board[2][1] = Rook.new('B',[2,1],'rook')
          @empty_game.select([3,3])

          expect(@empty_game.move([2,2])).to eql(nil)
        end

        it 'does not move into check: bishop version' do
          @empty_game.board.board[3][3] = King.new('W',[3,3],'king',false)
          @empty_game.board.board[2][3] = Bishop.new('B',[2,3],'bishop')
          @empty_game.select([3,3])

          expect(@empty_game.move([3,2])).to eql(nil)
        end

        it 'does not move into check: queen version' do
          @empty_game.board.board[3][3] = King.new('W',[3,3],'king',false)
          @empty_game.board.board[1][2] = Queen.new('B',[1,2],'queen')
          @empty_game.select([3,3])

          expect(@empty_game.move([2,2])).to eql(nil)
        end

        it 'castles left' do
          @empty_game.board.board[7][4] = King.new('W',[7,4],'king')
          @empty_game.board.board[7][0] = Rook.new('W',[7,0],'rook')
          @empty_game.select([7,4])
          @empty_game.move([7,2])

          expect(@empty_game.board.board[7][2].piece).to eql('king')
          expect(@empty_game.board.board[7][0]).to eql(nil)
          expect(@empty_game.board.board[7][4]).to eql(nil)
        end

        it 'castles right' do
          @empty_game.board.board[7][4] = King.new('W',[7,4],'king')
          @empty_game.board.board[7][7] = Rook.new('W',[7,7],'rook')
          @empty_game.select([7,4])
          @empty_game.move([7,6])

          expect(@empty_game.board.board[7][6].piece).to eql('king')
          expect(@empty_game.board.board[7][7]).to eql(nil)
          expect(@empty_game.board.board[7][4]).to eql(nil)
        end

        it 'does not castle if there is a piece in between king and rook' do
          @empty_game.board.board[7][4] = King.new('W',[7,4],'king')
          @empty_game.board.board[7][7] = Rook.new('W',[7,7],'rook')
          @empty_game.board.board[7][5] = Knight.new('W',[7,5],'knight')
          @empty_game.select([7,4])

          expect(@empty_game.move([7,6])).to eql(nil)
        end

        it 'does not castle if rook has moved before' do
          @empty_game.board.board[7][4] = King.new('W',[7,4],'king')
          @empty_game.board.board[7][7] = Rook.new('W',[7,7],'rook',false)
          @empty_game.select([7,4])

          expect(@empty_game.move([7,6])).to eql(nil)
        end

        it 'does not castle into check' do
          @empty_game.board.board[7][4] = King.new('W',[7,4],'king')
          @empty_game.board.board[7][7] = Rook.new('W',[7,7],'rook')
          @empty_game.board.board[2][6] = Rook.new('B',[2,6],'rook')
          @empty_game.select([7,4])

          expect(@empty_game.move([7,6])).to eql(nil)
        end

        it 'does not get king in check by moving other ally piece' do
          @empty_game.board.board[7][4] = King.new('W',[7,4],'king')
          @empty_game.board.board[6][4] = Bishop.new('W',[6,4],'bishop')
          @empty_game.board.board[3][4] = Rook.new('B',[3,4],'rook')
          @empty_game.select([6,4])
          expect(@empty_game.move([5,3])).to eql(nil)
        end
      end

    end

  context '#move_checks_king?' do

    #[4,7] = white king
    #[2,7] = black king
    it 'works' do
      @empty_game.board.board[2][2] = Rook.new('W',[2,2],'rook')
      expect(@empty_game.move_checks_king?([2,2])).to eql(true)
    end

    it 'does not return true when it is not in check' do
      @empty_game.board.board[1][5] = Queen.new('W',[1,5],'queen')
      expect(@empty_game.move_checks_king?([1,5])).to eql(false)
    end

    it 'should return false if there is a piece in between' do
      @empty_game.board.board[2][2] = Rook.new('W',[2,2],'rook')
      @empty_game.board.board[2][5] = Knight.new('B',[2,5],'knight')
      expect(@empty_game.move_checks_king?([2,2])).to eql(false)
    end

  end

  #this method assumes there is no move available for king
  #have to manually set @checking_piece and @checked_king
  context '#check_in_the_way' do

    it 'returns true if there is something that can be in between' do
      @empty_game.board.board[2][2] = Rook.new('W',[2,2],'rook')
      @empty_game.board.board[1][7] = Knight.new('B',[1,7], 'knight')
      @empty_game.checking_piece = @empty_game.board.board[2][2]
      @empty_game.checked_king = @empty_game.board.board[2][7]
      expect(@empty_game.check_in_the_way(@empty_game.board.board[1][7])).to eql(true)
    end

    it 'returns false if there is no piece that can be in between' do
      @empty_game.board.board[2][2] = Rook.new('W',[2,2],'rook')
      @empty_game.board.board[1][7] = Rook.new('B',[1,7],'rook')
      @empty_game.checking_piece = @empty_game.board.board[2][2]
      @empty_game.checked_king = @empty_game.board.board[2][7]
      expect(@empty_game.check_in_the_way(@empty_game.board.board[1][7])).to eql(false)
    end

    it 'returns false even if there is no piece that can be in between' do
      @empty_game.board.board[2][2] = Rook.new('W',[2,2],'rook')
      @empty_game.board.board[1][7] = Rook.new('B',[1,7],'rook')
      @empty_game.checking_piece = @empty_game.board.board[2][2]
      @empty_game.checked_king = @empty_game.board.board[2][7]
      expect(@empty_game.check_in_the_way(@empty_game.board.board[1][7])).to eql(false)
    end
  end

  #manually set @checked_king and @checking_piece
    context '#check_mate?' do

      it 'returns false if there is a regular move available for king' do
        @empty_game.board.board[2][2] = Rook.new('W',[2,2],'rook')
        @empty_game.board.board[2][7].can_castle = false
        @empty_game.board.board[4][7].can_castle = false
        @empty_game.checking_piece = @empty_game.board.board[2][2]
        @empty_game.checked_king = @empty_game.board.board[2][7]
        expect(@empty_game.check_mate?).to eql(false)
      end

      it 'returns false if there is a piece that can take checking_piece out' do
        @empty_game.board.board[2][2] = Rook.new('W',[2,2],'rook')
        @empty_game.board.board[1][2] = Rook.new('W',[1,2],'rook')
        @empty_game.board.board[3][1] = Bishop.new('B',[3,1],'bishop')
        @empty_game.board.board[2][7].can_castle = false
        @empty_game.board.board[4][7].can_castle = false
        @empty_game.checking_piece = @empty_game.board.board[2][2]
        @empty_game.checked_king = @empty_game.board.board[2][7]
        expect(@empty_game.check_mate?).to eql(false)
      end

      it 'returns false if there is a piece that can be in between' do
        @empty_game.board.board[2][2] = Rook.new('W',[2,2],'rook')
        @empty_game.board.board[1][2] = Rook.new('W',[1,2],'rook')
        @empty_game.board.board[3][1] = Bishop.new('B',[3,1],'bishop')
        @empty_game.board.board[2][7].can_castle = false
        @empty_game.board.board[4][7].can_castle = false
        @empty_game.checking_piece = @empty_game.board.board[2][2]
        @empty_game.checked_king = @empty_game.board.board[2][7]
        expect(@empty_game.check_mate?).to eql(false)
      end

      it 'returns true if there is no piece to take checking_piece out' do
        @empty_game.board.board[2][2] = Rook.new('W',[2,2],'rook')
        @empty_game.board.board[1][2] = Rook.new('W',[1,2],'rook')
        @empty_game.board.board[2][7].can_castle = false
        @empty_game.board.board[4][7].can_castle = false
        @empty_game.checking_piece = @empty_game.board.board[2][2]
        @empty_game.checked_king = @empty_game.board.board[2][7]
        expect(@empty_game.check_mate?).to eql(true)
      end
    end

    context '#check_king' do

      it "returns true when it's in check" do
        @empty_game.board.board[2][2] = Rook.new('W',[2,2],'rook')
        @empty_game.turn = 'B'
        expect(@empty_game.check_king(@empty_game.board.board)).to eql(true)
      end

      it 'returns false when no check' do
        @empty_game.turn = 'B'
        expect(@empty_game.check_king(@empty_game.board.board)).to eql(false)
      end
    end

    context '#check_mode_move' do
      it "returns false if king is still in check after move" do
        @empty_game.board.board[2][2] = Rook.new('W',[2,2],'rook')
        @empty_game.board.board[1][7] = Knight.new('B',[1,7], 'knight')
        @empty_game.turn = 'B'
        @empty_game.checking_piece = @empty_game.board.board[2][2]
        @empty_game.checked_king = @empty_game.board.board[2][7]
        @empty_game.select([1,7])
        expect(@empty_game.check_mode_move([0,5])).to eql(nil)
      end

      it "returns true if king is not in check after other move" do
        @empty_game.board.board[2][2] = Rook.new('W',[2,2],'rook')
        @empty_game.board.board[1][7] = Knight.new('B',[1,7], 'knight')
        @empty_game.turn = 'B'
        @empty_game.checking_piece = @empty_game.board.board[2][2]
        @empty_game.checked_king = @empty_game.board.board[2][7]
        @empty_game.select([1,7])
        expect(@empty_game.check_mode_move([2,5])).to eql(true)
      end

      it "returns true if king is not in check after king move" do
        @empty_game.board.board[2][2] = Rook.new('W',[2,2],'rook')
        @empty_game.board.board[1][7] = Knight.new('B',[1,7], 'knight')
        @empty_game.turn = 'B'
        @empty_game.checking_piece = @empty_game.board.board[2][2]
        @empty_game.checked_king = @empty_game.board.board[2][7]
        @empty_game.select([2,7])
        expect(@empty_game.check_mode_move([1,6])).to eql(true)
      end
    end

    context '#stale_mate?', skip_before: true do

      it "returns true if no moves available for every ally piece" do
        @empty_game.board.board[6][3] = Pawn.new('B',[6,3],'pawn',false,false)
        @empty_game.board.board[7][3] = King.new('W',[7,3],'king',false)
        @empty_game.board.board[5][3] = Queen.new('B',[5,3],'queen')
        @empty_game.board.board[5][7] = Pawn.new('W',[5,7],'pawn',false,false)
        @empty_game.board.board[4][7] = Pawn.new('B',[4,7],'pawn',false,false)
        expect(@empty_game.stale_mate?).to be true
      end

      it "returns false if move are available for an ally piece" do
        @empty_game.board.board[6][3] = Pawn.new('B',[6,3],'pawn',true,false)
        @empty_game.board.board[7][3] = King.new('W',[7,3],'king',false)
        @empty_game.board.board[5][3] = Queen.new('B',[5,3],'queen')
        @empty_game.board.board[5][7] = Pawn.new('W',[5,7],'pawn',true,false)
        @empty_game.board.board[5][7].get_next(@empty_game.board.board)
        puts @empty_game.board.board[5][7].next_moves.inspect
        @empty_game.board.display
        expect(@empty_game.stale_mate?).to be false
      end

    end
  end

end
