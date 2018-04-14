require './lib/classes.rb'

def ask_load
  puts "You have a save file available.\n\nWould you like to continue playing from last time? (y/n)"
  input = gets.chomp

  if input[0].downcase == 'y'
    game = Game.new.from_json(File.read("./save/save.txt"))
    game.play
  else
    game = Game.new
    game.play
  end
end

if !File.zero?("./save/save.txt")
  ask_load
else
  game = Game.new
  game.play
end
