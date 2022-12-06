#!/usr/bin/env ruby

Player = Struct.new(:name) do
  attr_writer :score
  def score
    @score ||= 0
  end
end

Question = Struct.new(:text, :answer) do

  def guesses
    @guesses ||= []
  end
end

Guess = Struct.new(:guess, :player, :correct_answer) do

  def difference
    (correct_answer - guess).abs
  end

end

puts "How Many Players?"
number_of_players = gets.chomp.to_i
players = []
index = 0
number_of_players.times do
  index += 1
  puts "Player #{index} Name:"
  name = gets.chomp
  players << Player.new(name)
end

players = players.shuffle

questions = []
questions << Question.new("Thomas Edison demonstrates his phonograph for the first time.",1877)
questions << Question.new("FC Barcelona is founded by Catalan, Spanish and Englishmen. It later develops into one of Spanish football's most iconic and strongest teams.",1899)
questions << Question.new("U.S. Admiral Richard E. Byrd leads the first expedition to fly over the South Pole.",1929)
#questions << Question.new("U.S. President-elect Dwight D. Eisenhower fulfills a campaign promise by traveling to Korea to find out what can be done to end the conflict.",1952)
questions << Question.new("Enos, a chimpanzee, is launched into space. The spacecraft orbits the Earth twice and splashes down off the coast of Puerto Rico.",1961)
questions << Question.new("\"I Want to Hold Your Hand\", recorded on October 17, is released by the Beatles in the United Kingdom.",1963)
questions << Question.new("Atari releases Pong, the first commercially successful video game.",1972)

questions.each_with_index do |question, index|
  puts "Question #{index + 1} #{question.text}:"
  puts "Order: #{players.collect(&:name).join(', ')}"
  players.each do |player|
    puts "#{player.name}'s Guess:"
    guess = gets.chomp.to_i
    question.guesses << Guess.new(guess, player, question.answer)
  end
  puts "Results:"
  puts "The correct answer is #{question.answer}"
  win = question.guesses.sort_by { |g| g.difference }.first
  puts "#{win.player.name} is closest (off by #{win.difference})"
  puts
  
  players = players.rotate(1)
end
