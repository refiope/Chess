require './lib/classes.rb'

def ask_load
  puts "You have a save file available.\n\nWould you like to continue playing from last time? (y/n)"
  input = gets.chomp

  if input[0].downcase == 'y'
    game = Game.game_from_json('./save/board_save.txt',
                               './save/check_save.txt',
                               File.read("./save/save.txt"))
    game.play
  else
    game = Game.new
    game.play
  end
end

if File.exist?("./save/save.txt")
  ask_load
else
  game = Game.new
  game.play
end
