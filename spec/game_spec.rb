require 'classes'

describe 'Chess game' do

  describe Game do
    #keep in mind that new game starts with white's turn
    before(:each) do
      @game = Game.new
      @input = StringIO.new('queen')

      @empty_board = GameBoard.new
      @empty_array = []
      8.times {@empty_array.push(Array.new(8,nil))}
      @empty_board.board = @empty_array

      @empty_game = Game.new(@empty_board)
    end

    context '#select' do

      it 'selects the right piece' do
        @game.select([6,0])
        expect(@game.selected).to eql(@game.board.board[6][0])
      end

      it 'does not select empty tile' do
        @game.select([2,4])
        expect(@game.selected).to eql(nil)
      end

      it "does not select opposite side's piece" do
        @game.select([2,0])
        expect(@game.selected).to eql(nil)
      end

    end

    #will have to be tested/refactored more in the future
    #only pawn's regular move can be done
    context '#move' do

      context 'movements with pawn' do

        it 'moves white pawn one tile up' do
          @game.select([6,4])
          @game.move([5,4])
          expect(@game.board.board[5][4].piece).to eql('pawn')
          expect(@game.board.board[5][4].position).to eql([5,4])
          expect(@game.board.board[6][4]).to eql(nil)
        end

        it 'moves black pawn one tile down' do
          @game.turn = 'B'
          @game.select([1,3])
          @game.move([2,3])
          expect(@game.board.board[2][3].piece).to eql('pawn')
          expect(@game.board.board[2][3].position).to eql([2,3])
          expect(@game.board.board[1][3]).to eql(nil)
        end

        it 'allows jump for white pawn' do
          @game.select([6,4])
          @game.move([4,4])
          expect(@game.board.board[4][4].piece).to eql('pawn')
          expect(@game.board.board[4][4].position).to eql([4,4])
          expect(@game.board.board[6][4]).to eql(nil)
          expect(@game.board.board[4][4].jump_used).to be true
        end

        it 'allows jump for black pawn' do
          @game.turn = 'B'
          @game.select([1,4])
          @game.move([3,4])
          expect(@game.board.board[3][4].piece).to eql('pawn')
          expect(@game.board.board[3][4].position).to eql([3,4])
          expect(@game.board.board[1][4]).to eql(nil)
          expect(@game.board.board[3][4].jump_used).to be true
        end

        it 'does not allow jump twice' do
          @game.select([6,4])
          @game.move([4,4])
          @game.select([4,4])
          expect(@game.move([2,4])).to eql(nil)
        end

        it 'white pawn can en_passant' do
          @empty_game.board.board[4][4] = Pawn.new('W',[4,4],'pawn',false,false)
          @empty_game.board.board[4][3] = Pawn.new('B',[4,3],'pawn',true,true)
          @empty_game.select([4,4])
          @empty_game.move([3,3])
          expect(@empty_game.board.board[4][3]).to eql(nil)
          expect(@empty_game.board.board[3][3].piece).to eql('pawn')
        end

        it 'changes white pawn at the end of the board' do
          allow(@empty_game).to receive(:gets).and_return('queen')

          @empty_game.board.board[1][4] = Pawn.new('W', [1,4], 'pawn', false, false)
          @empty_game.select([1,4])
          @empty_game.move([0,4])

          expect(@empty_game.board.board[0][4].piece).to eql('queen')
          expect(@empty_game.board.board[0][4].color).to eql('W')
          expect(@empty_game.board.board[0][4].position).to eql([0,4])
        end

        it 'does not allow invalid moves for pawn' do
          @game.select([6,4])
          expect(@game.move([3,6])).to eql(nil)
        end

      end

      context 'movements with knight' do

        it 'moves white to right positions' do
          @empty_game.board.board[3][3] = Knight.new('W',[3,3],'knight')
          @empty_game.select([3,3])
          @empty_game.move([4,5])
          expect(@empty_game.board.board[4][5].piece).to eql('knight')
          expect(@empty_game.board.board[4][5].color).to eql('W')
          expect(@empty_game.board.board[4][5].position).to eql([4,5])
          expect(@empty_game.board.board[3][3]).to eql(nil)
        end

        it 'moves black to right positions' do
          @empty_game.turn = 'B'
          @empty_game.board.board[3][3] = Knight.new('B',[3,3],'knight')
          @empty_game.select([3,3])
          @empty_game.move([4,5])
          expect(@empty_game.board.board[4][5].piece).to eql('knight')
          expect(@empty_game.board.board[4][5].color).to eql('B')
        end

        it "does not move to ally's piece" do
          @game.select([7,1])
          expect(@game.move([6,3])).to eql(nil)
        end

        it 'does not make invalid moves' do
          @empty_game.board.board[3][3] = Knight.new('W',[3,3],'knight')
          @empty_game.select([3,3])
          expect(@empty_game.move([5,5])).to eql(nil)
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
          @empty_game.board.board[3][3] = Queen.new('B',[3,3], 'rook')
          @empty_game.board.board[6][6] = Rook.new('W',[6,6], 'rook')
          @empty_game.select([3,3])
          @empty_game.move([6,6])
          expect(@empty_game.board.board[6][6].color).to eql('B')
        end

        it 'does not take ally piece' do
          @empty_game.board.board[3][3] = Queen.new('W',[3,3], 'rook')
          @empty_game.board.board[5][1] = Bishop.new('W',[5,1], 'rook')
          @empty_game.select([3,3])
          expect(@empty_game.move([5,1])).to eql(nil)
        end
      end

      context 'movements with king' do
      end

    end

  end

end
