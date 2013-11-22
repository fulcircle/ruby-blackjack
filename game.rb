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
				@players.each {
					|player| 
					begin
						self.dealToPlayer(player, player.hands.first)
					# Player got a blackjack
					rescue PlayerHit21Exception
						player.hands.first.blackjack = true
					end
				}
			self.hideDealerHoleCard
		end
	end	

	def endRound
		dealerHand = @dealer.hands.first
		dealerValues = dealerHand.possibleValues
		# Dealer draws until soft 17 or greater
		while dealerValues.all?{|val| val < 17} or (dealerValues.max > 21 and dealerValues.any?{|val|val < 17}) 
			self.dealToDealer
			dealerValues = dealerHand.possibleValues
		end
		if dealerHand.possibleValues.all? {|val| val > 21}
			dealerHand.lost = true
		end
		@players.each {
			|player| 
			player.hands.each {
				|hand|
				unless hand.lost
					if hand.blackjack
						player.score += hand.bet + (hand.bet*1.5)
					elsif dealerHand.lost or hand > dealerHand 
							player.score += (hand.bet*2)
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
		elsif playerHand.possibleValues.any? {|value| value == 21}
			raise PlayerHit21Exception.new({:player=>player, :hand=>playerHand}), "You hit 21!"
		end

	end


	def dealToDealer
		begin
			self.dealToPlayer(@dealer, @dealer.hands.first)
		# Don't do anything if dealer hits or goes over 21
		rescue PlayerLostHandException
		rescue PlayerHit21Exception
		end
	end


	def splitHand(player)

		playerHand = player.hands.first

		if self.canSplit(player)
			card2 = playerHand.cards[1]
			playerNewHand = PlayerHand.new
			playerHand.remove(card2)
			playerNewHand.add(card2)
			player.hands << playerNewHand
			playerNewHand.bet = playerHand.bet
		else
			raise CannotSplitError.new({:player=>player, :hand=>playerHand}), "You cannot split this hand"
		end

	end

	def canSplit(player)
		playerHand = player.hands.first
		if player.numHands == 1 and playerHand.size == 2
			card1 = playerHand.cards[0]
			card2 = playerHand.cards[1]
			if card1.rank == card2.rank or (card1.values.include?(10) and card2.values.include?(10))
				return true
			else
				return false
			end
		else
			return false
		end
	end

	def canDoubleDown(player)
		hand = player.hands.first
		if !player.isDoubledDown and hand.size == 2 \
			and player.numHands == 1 and player.score >= hand.bet
			return true
		else
			return false
		end
	end


	def doubleDown(player, hand)
		if self.canDoubleDown(player)
			self.placeBet(player, hand.bet, hand)
			hand.isDoubledDown = true
			self.dealToPlayer(player, hand)
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
		playerHand.bet += bet_amount
		player.score -= bet_amount

	end

	attr_reader :players
	attr_reader :dealer
	attr_reader :currPlayerIndex
	attr_reader :currPlayer
	attr_reader :currHandIndex
	attr_reader :currHand
	attr_reader :deck

end

