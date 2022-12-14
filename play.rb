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
puts "question file name?"
filename = gets.chomp
unless filename
  puts "give it a file"
  exit
end

questions = []
delim = '-'
File.open(filename, 'r').each_line do |line|
  line = line.strip
  next unless line
  year, text = line.split(delim,2)
  questions << Question.new(text.strip, year.to_i)
end
if questions.empty?
  puts "no questions"
  exit
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
