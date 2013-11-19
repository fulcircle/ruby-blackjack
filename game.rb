require_relative "player"
require_relative "deck"

class Game
	def initialize(numPlayers=1)
		@deck = Deck.new
		@deck.shuffle

		@players = Array.new(numPlayers)
		@players.each_index{|i| players[i] = Player.new(i)}
	end

	def dealToPlayer(playerId, handId=0)
		# TODO: what if deck is empty?
		@players[playerId].hands[handId].add(@deck.getCard)
	end

	def deal
		# TODO: What if deck is empty? We need to check
		@players.each {|x| x.hands.each {|y| y.add(@deck.getCard)}}
	end

	def hit(playerId)
		dealToPlayer(playerId)
	end

	def splitHand(playerId, handId=0)
		player = @players[playerId]
		playerHand = player.hands[handId]

		if playerHand.size == 2
			card1 = playerHand.cards[0]
			card2 = playerHand.cards[1]
			if card1.rank == card2.rank or (card1.values.include?(10) and card2.values.include?(10))
				playerNewHand = PlayerHand.new
				playerHand.remove(card2)
				playerNewHand.add(card2)
				player.hands << playerNewHand
			end
		end

	end

	attr_reader :players
end

