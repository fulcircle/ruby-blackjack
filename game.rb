require_relative "player"
require_relative "deck"
require_relative "exceptions"

class Game
	def initialize(numPlayers=1, minBet=1)
		@deck = Deck.new
		@deck.shuffle

		@minBet = minBet

		@players = Array.new(numPlayers)
		@players.each_index{|i| players[i] = Player.new(i)}
		@dealer = Dealer.new(0)

	end

	def startRound
		# Deal two cards to players and dealers
		(0..1).each do
			self.dealToDealer
			@players.each {|player| self.dealToPlayer(player, player.hands.first)}
		end
		self.hideDealerHoleCard

	end

	def endRound
		dealerHand = @dealer.hands.first
		# Deal until 17 or greater
		while dealerHand.possibleValues.max < 17
			self.dealToDealer
		end
		if dealerHand.possibleValues.max > 21
			dealerHand.lost = true
		end
		@players.each {
			|player| 
			player.hands.each {
				|hand|
				unless hand.lost
					if hand > dealerHand or dealerHand.lost
						if hand.blackjack?
							player.score += hand.bet + (hand.bet*1.5)
						else
							player.score += (hand.bet*2)
						end
					elsif hand == dealerHand
						player.score += hand.bet
					else
						hand.lost = true
					end
				end
			}
		}
		self.unhideDealerHoleCard
	end

	def nextRound
		@dealer.clearHands
		@players.each{|player| player.clearHands}
		self.startRound
	end

	def hideDealerHoleCard
		@dealer.hands.first.cards.first.hidden = true
	end

	def unhideDealerHoleCard
		@dealer.hands.first.cards.first.hidden = false
	end


	def dealToPlayer(player, playerHand)
		# TODO: what if deck is empty?
		playerHand.add(@deck.getCard)

		if playerHand.possibleValues.all? {|value| value > 21}
			playerHand.lost = true
			raise PlayerLostHandException.new({:player=>player, :hand=>playerHand}), "Value of the hand is over 21"
		end

	end


	def dealToDealer
		self.dealToPlayer(@dealer, @dealer.hands.first)
	end


	def splitHand(player)

		playerHand = player.hands.first
		if player.numHands == 1 and playerHand.size == 2
			card2 = playerHand.cards[1]
			# if card1.rank == card2.rank or (card1.values.include?(10) and card2.values.include?(10))
				playerNewHand = PlayerHand.new
				playerHand.remove(card2)
				playerNewHand.add(card2)
				player.hands << playerNewHand
				self.dealToPlayer(player, playerHand)
				self.dealToPlayer(player, playerNewHand)
				playerHand.bet = playerHand.bet*0.5
				playerNewHand.bet = playerHand.bet
			# else
				# raise CannotSplitError.new({:player=>player, :hand=>playerHand}), "You cannot split this hand"
			# end
		else
			raise CannotSplitError.new({:player=>player, :hand=>playerHand}), "You cannot split this hand"
		end

	end

	def doubleDown(player, hand)
		# If this is the first turn for this player, he can double down
		if !player.isDoubledDown? and hand.size == 2 
			self.placeBet(player, hand.bet*2, hand)
			hand.isDoubledDown = true
		else
			raise CannotDoubleDownError.new({:player=>player}), "Cannot double-down now!"
		end
	end

	def placeBet(player, bet_amount, playerHand=nil)
		if playerHand.nil?
			playerHand = player.hands.first
		end
		if bet_amount < @minBet
			raise MinBetError.new({:player=>player, :hand=>playerHand, :min_bet=>@minBet, :bet_amount=>bet_amount}), \
				"The bet you placed is less than then minimum bet"
		elsif bet_amount > player.score
			raise NoMoneysError.new({:player=>player, :hand=>playerHand, :bet_amount=>bet_amount}), \
				"You cannot bet that much.  Your wallet won't let you."
		end
		playerHand.bet = bet_amount
		player.score -= bet_amount

	end

	attr_reader :players
	attr_reader :dealer
	attr_reader :currPlayerIndex
	attr_reader :currPlayer
	attr_reader :currHandIndex
	attr_reader :currHand

end

