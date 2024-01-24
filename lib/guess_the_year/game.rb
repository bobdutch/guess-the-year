module GuessTheYear
  class Game
    attr_reader :players, :questions

    def initialize
      self.questions = []
      self.players = []
      setup_game
    end

    def play
      questions.each_with_index do |question, index|
        ask_question(question, index)
        current_score
        rotate_starting_order
        logputs("")
      end
      finish_game
    end

    def current_score
      logputs("\nCurrent Scores:")
      players.sort_by { |player| -player.score }.each do |player|
        logputs "#{player.name}: #{player.score} (off by #{player.total_difference})"
      end
    end

    private

    attr_writer :players, :questions
    attr_accessor :log_file_path

    Player = Struct.new(:name) do
      attr_accessor :score, :total_difference

      def initialize(name)
        super(name)
        self.score = self.total_difference = 0
      end
    end

    Question = Struct.new(:text, :answer) do
      attr_accessor :guesses

      def initialize(text, answer)
        super(text, answer)
        self.guesses = []
      end

      def record_guess(guess, player)
        self.guesses << Guess.new(guess, player, self)

        # Update the player's total_difference
        player.total_difference += guesses.last.difference
      end
    end

    Guess = Struct.new(:guess, :player, :question) do
      def difference
        (question.answer - guess).abs
      end
    end

    def setup_game
      logputs "Question file name? (Press Enter/Return to use default: #{default_filename})"
      filename_input = loggets
      filename = filename_input.empty? ? default_filename : filename_input
      filename = File.join(root_directory, "questions", filename)
      error_and_exit("File '#{filename}' not found.") if !File.exist?(filename)

      delim = ' - '
      File.open(filename, 'r').each_line do |line|
        line = line.strip
        next unless line
        year, text = line.split(delim, 2)
        self.questions << Question.new(text.strip, year.to_i)
      end
      error_and_exit("No questions in file.") if questions.empty?

      logputs "How Many Players?"
      number_of_players = loggets.to_i
      index = 0
      number_of_players.times do
        index += 1
        logputs "Player #{index} Name:"
        name = loggets
        self.players << Player.new(name)
      end

      self.players = players.shuffle
    end

    def finish_game
      max_score = players.max_by(&:score).score
      winners = players.select { |player| player.score == max_score }

      if winners.size == 1
        logputs "Game Over!"
        logputs "#{winners.first.name} is the winner with a score of #{winners.first.score}!"
      else
        logputs "It's a tie! Time for a tiebreaker question."
      end
    end

    def ask_question(question, index)
      logputs "Question #{index + 1} #{question.text}:"
      logputs "Order: #{players.collect(&:name).join(', ')}"
      players.each do |player|
        logputs "#{player.name}'s Guess:"
        guess = loggets.to_i
        question.record_guess(guess, player)
      end

      logputs "\nResults:"
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
    end

    def rotate_starting_order
      self.players = players.rotate(1)
    end

    def log(message)
      self.log_file_path ||= setup_log_file_path
      File.open(log_file_path, 'a') { |f| f.puts("#{message}\n") }
    end

    def loggets
      gets.chomp
    end

    def logputs(message)
      log message
      puts message
    end

    def default_filename
      Time.now.strftime('%m-%d.txt')
    end

    def error_and_exit(message)
      logputs "Error: #{message} Exiting."
      exit
    end

    def setup_log_file_path
      log_directory = File.join(root_directory, 'log')
      Dir.mkdir(log_directory) unless File.exist?(log_directory)
      current_date = Time.now.strftime('%Y-%m-%d')
      File.join(log_directory, "#{current_date}.txt")
    end

    def root_directory
      File.expand_path(File.join('..','..'),__dir__)
    end
  end
end
