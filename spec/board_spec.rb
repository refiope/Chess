require 'classes'

describe 'Chess board' do

  describe GameBoard do
    before(:each) do
      @board = GameBoard.new
    end

    context '#display' do
      it 'shows the board' do
        expect(@board.display)
      end
    end

    context '#initialize' do
      it 'starts with the right pieces' do
        expect(@board.board[0][0].symbol).to eql("\u2656")
        expect(@board.board[3][5]).to eql(nil)
        expect(@board.board[1][6].symbol).to eql("\u2659")
        expect(@board.board[7][4].symbol).to eql("\u265A")
      end
      it 'starts with the right initial position' do
        @board.board.each_index do |row|
          @board.board[row].each_index do |column|
            if !@board.board[row][column].nil?
              expect(@board.board[row][column].position).to eql([row,column])
            end
          end
        end
      end
      it 'starts with the right color' do
        @board.board.each_index do |row|
          @board.board[row].each_index do |column|
            if !@board.board[row][column].nil?
              expect(@board.board[row][column].color).to eql('B') if row < 2
              expect(@board.board[row][column].color).to eql('W') if row > 5
            end
          end
        end
      end
    end

  end

end
