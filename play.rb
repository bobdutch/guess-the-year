#!/usr/bin/env ruby

Player = Struct.new(:name) do
  attr_writer :score
  def score
    @score ||= 0
  end
end

Question = Struct.new(:text, :answer) do
end

player1 = Player.new("Player 1")
player2 = Player.new("Player 2")
players = [player1, player2].shuffle
puts players.collect(&:name).join(", ")
questions = []
questions << Question.new("Thomas Edison demonstrates his phonograph for the first time.",1877)
questions << Question.new("FC Barcelona is founded by Catalan, Spanish and Englishmen. It later develops into one of Spanish football's most iconic and strongest teams.",1899)
questions << Question.new("U.S. Admiral Richard E. Byrd leads the first expedition to fly over the South Pole.",1929)
#questions << Question.new("U.S. President-elect Dwight D. Eisenhower fulfills a campaign promise by traveling to Korea to find out what can be done to end the conflict.",1952)
questions << Question.new("Enos, a chimpanzee, is launched into space. The spacecraft orbits the Earth twice and splashes down off the coast of Puerto Rico.",1961)
questions << Question.new("\"I Want to Hold Your Hand\", recorded on October 17, is released by the Beatles in the United Kingdom.",1963)
questions << Question.new("Atari releases Pong, the first commercially successful video game.",1972)

questions.each do |question|
  puts question.text
  guesses = []
  players.each do |player|
    puts "#{player.name}'s Guess"
    answer = gets.chomp.to_i
    difference = (question.answer - answer).abs
    puts difference
    guesses << { player: player, guess: answer, difference: difference}
  end
  win = guesses.sort_by { |g| g[:difference] }.first
  puts "winner"
  puts win
end
