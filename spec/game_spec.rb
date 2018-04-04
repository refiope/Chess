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

      it 'moves white pawn one tile up' do
        @game.select([6,4])
        @game.move([5,4])
        expect(@game.board.board[5][4].piece).to eql('pawn')
        expect(@game.board.board[5][4].position).to eql([5,4])
        expect(@game.board.board[6][4]).to eql(nil)
      end

      it 'does not allow invalid moves for pawn' do
        @game.select([6,4])
        expect(@game.move([3,6])).to eql(nil)
      end

    end

  end

end
