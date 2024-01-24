#!/usr/bin/env ruby
# frozen_string_literal: true

libx = File.expand_path('../lib', __dir__)
$LOAD_PATH.unshift(libx) unless $LOAD_PATH.include?(libx)

require 'guess_the_year'


# Create an instance of the Game class and start the game
game = GuessTheYear::Game.new
#puts game.players
#puts game.questions
#puts game.current_score
game.play
