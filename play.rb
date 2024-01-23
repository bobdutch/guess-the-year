#!/usr/bin/env ruby
class Game
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

  def initialize
    setup_game
  end

  def setup_game
    logputs "Question file name? (Press Enter/Return to use default: #{default_filename})"
    filename = loggets.empty? ? default_filename : loggets
    filename = File.join(File.dirname(__FILE__), "questions", filename)

    if !File.exist?(filename)
      logputs "Error: File '#{filename}' not found. Exiting."
      exit
    end

    @questions = []
    delim = ' - '
    File.open(filename, 'r').each_line do |line|
      line = line.strip
      next unless line
      year, text = line.split(delim, 2)
      @questions << Question.new(text.strip, year.to_i)
    end

    if @questions.empty?
      logputs "No questions"
      exit
    end

    logputs "How Many Players?"
    number_of_players = loggets.to_i
    @players = []
    index = 0
    number_of_players.times do
      index += 1
      logputs "Player #{index} Name:"
      name = loggets
      @players << Player.new(name)
    end

    @players = @players.shuffle
  end

  def start_game
    @questions.each_with_index do |question, index|
      logputs "Question #{index + 1} #{question.text}:"
      logputs "Order: #{@players.collect(&:name).join(', ')}"
      @players.each do |player|
        logputs "#{player.name}'s Guess:"
        guess = loggets.to_i
        question.guesses << Guess.new(guess, player, question.answer)
      end

      logputs "Results:"
      logputs "The correct answer is #{question.answer}"

      min_difference = nil
      winners = []

      question.guesses.sort_by { |g| g.difference }.each do |guess|
        min_difference ||= guess.difference
        winners << guess if guess.difference == min_difference
      end

      winners.each do |win|
        logputs "#{win.player.name} is closest (off by #{win.difference})"
        win.player.score += win.difference.zero? ? 2 : 1
      end

      @players.each do |player|
        logputs "#{player.name} #{player.score}"
      end

      logputs("")
      @players = @players.rotate(1)
    end
  end

  private

  def log(string)
    current_directory = File.dirname(__FILE__)
    log_directory = File.join(current_directory, 'log')
    Dir.mkdir(log_directory) unless File.exist?(log_directory)
    current_date = Time.now.strftime('%Y-%m-%d')
    log_file_path = File.join(log_directory, "#{current_date}.txt")

    File.open(log_file_path, 'a') { |f| f.puts("#{string}\n") }
  end

  def loggets
    gets.chomp
  end

  def logputs(string)
    log string
    puts string
  end

  def default_filename
    Time.now.strftime('%m-%d.txt')
  end
end

# Create an instance of the Game class and start the game
game = Game.new
game.start_game
