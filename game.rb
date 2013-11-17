require_relative "player"
require_relative "deck"

class Game
	def initialize(numPlayers=1)
		@deck = Deck.new
		@deck.shuffle

		@players = Array.new(numPlayers)
		@players.each_index{|i| players[i] = Player.new(i)}
	end

	def dealToPlayer(playerId)
		# TODO: what if deck is empty?
		@players[playerId].hand.add(@deck.getCard)
	end

	def deal
		# TODO: What if deck is empty? We need to check
		@players.each{|x| x.hand.add(@deck.getCard)}
	end

	def hit(playerId)
	end

	attr_reader :players
end

