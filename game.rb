require_relative "player"
require_relative "deck"
require_relative "exceptions"

class Game
	def initialize(numPlayers=1)
		@deck = Deck.new
		@deck.shuffle

		@players = Array.new(numPlayers)
		@players.each_index{|i| players[i] = Player.new(i)}
		@dealer = Dealer.new(0)
		@currPlayerIndex = 0
		@currPlayer = @players.first
		@currHandIndex = 0
		@currHand = @currPlayer.hands.first

	end

	def start
		# Deal two cards to players and dealers
		(0..1).each do
			self.dealToDealer
			@players.each {|player| self.dealToPlayer(player, player.hands.first)}
		end

	end

	def dealToPlayer(player, playerHand)
		# TODO: what if deck is empty?
		playerHand.add(@deck.getCard)

		if playerHand.possibleValues.all? {|value| value > 21}
			raise ValueOver21Error.new({:player=>player, :hand=>playerHand}), "Value of the hand is over 21"
		end

	end

	def nextPlayer
		@currPlayerIndex == @players.length-1 ? @currPlayerIndex = 0 : @currPlayerIndex += 1
		@currPlayer = @players[@currPlayerIndex]
		@currHandIndex = 0
		@currHand = @currPlayer.hands.first
	end

	def nextHand
		if @currHandIndex == @currPlayer.hands.length-1
			raise NoMoreHandsError.new(@currHand), @currPlayer.to_s + " has no more hands"
		else 
			@currHandIndex +=1
			@currHand = @currPlayer.hands[@currHandIndex]
		end
	end

	# def dealToPlayers
	# 	# TODO: What if deck is empty? We need to check
	# 	@players.each {|player| player.hands.each {|hand| self.dealToPlayer(player, hand)}}
	# end

	def dealToDealer
		self.dealToPlayer(@dealer, @dealer.hands.first)
	end

	# def hit(player, playerHand=nil)
	# 	if (playerHand.nil?)
	# 		playerHand = player.hands.first
	# 	end
	# 	self.dealToPlayer(player, playerHand)
	# end

	def splitHand(player, playerHand=nil)

		if (playerHand.nil?)
			playerHand = player.hands.first
		end

		if playerHand.size == 2
			card1 = playerHand.cards[0]
			card2 = playerHand.cards[1]
			if card1.rank == card2.rank or (card1.values.include?(10) and card2.values.include?(10))
				playerNewHand = PlayerHand.new
				playerHand.remove(card2)
				playerNewHand.add(card2)
				player.hands << playerNewHand
			else
				raise CannotSplitError.new({:player=>player, :hand=>playerHand}), "You cannot split this hand"
			end
		else
			raise CannotSplitError.new({:player=>player, :hand=>playerHand}), "You cannot split this hand"
		end

	end

	def doubleDown(player)
		# If this is the first turn for this player, he can double down
		if player.numHands == 1 and player.hands.first.size == 2
			player.doubleDown
		else
			raise CannotDoubleDownError.new({:player=>player}), "Cannot double-down now!"
		end
	end

	attr_reader :players
	attr_reader :dealer
	attr_reader :currPlayer
	attr_reader :currHand

end

