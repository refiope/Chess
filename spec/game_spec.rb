require 'classes'

describe 'Chess game' do

  describe Game do

    #keep in mind that new game starts with white's turn
    before(:each) do
      @game = Game.new
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

        it 'can en_passant: WARNING-Will not work when turn changes automatically' do
          @game.select([6,4])
          @game.move([4,4])
          @game.select([4,4])
          @game.move([3,4])
          @game.turn = 'B'
          @game.select([1,3])
          @game.move([3,3])
          @game.turn = 'W'
          @game.select([3,4])
          @game.move([2,3])
          @game.board.display
          expect(@game.board.board[3][3]).to eql(nil)
          expect(@game.board.board[2][3].piece).to eql('pawn')
        end

        it 'does not allow invalid moves for pawn' do
          @game.select([6,4])
          expect(@game.move([3,6])).to eql(nil)
        end

      end

    end

  end

end
