require "test/unit"
require_relative "game"
require_relative "playerhand"
require_relative "exceptions"

class TestGame < Test::Unit::TestCase

	def setup
		@g = Game.new(2)
		@deck = @g.instance_variable_get("@deck")
		@player1 = @g.players[0]
		@player2 = @g.players[1]
	end

	def test_game_creates_deck
		assert_equal(52, @deck.size)

		# Make sure values for cards are not nil
		assert(@deck.cards.all?{|x| x != nil})
	end

	def test_game_creates_players
		assert_equal(2, @g.players.length)
	end

	def test_game_deals_cards_on_game_start
		@g.startRound
		assert_equal(2, @player1.hands.first.size)
		assert_equal(2, @player2.hands.first.size)
		assert_equal(2, @g.dealer.hands.first.size)
	end

	def test_game_deals_card_to_player
		@g.dealToPlayer(@player2, @player2.hands.first)
		assert_equal(51, @deck.size)
		assert_equal(1, @player2.hands.first.size)
		assert_equal(0, @player1.hands.first.size)

		@g.dealToPlayer(@player1, @player1.hands.first)
		assert_equal(50, @deck.size)
		assert_equal(1, @player2.hands.first.size)
		assert_equal(1, @player1.hands.first.size)
	end

	def test_game_deals_to_one_hand
		@player1.addHand
		@g.dealToPlayer(@player1, @player1.hands[1])
		assert_equal(51, @deck.size)
		assert_equal(0, @player1.hands[0].size)
		assert_equal(1, @player1.hands[1].size)

		assert_equal(0, @player2.hands.first.size)
	end

	def test_game_splits_hand_on_same_rank
		# make sure first player has only 1 hand
		player = @player1
		assert_equal(1, player.numHands)
		card1 = Card.new("Ace", "Clubs", [1,11])
		card2 = Card.new("Ace", "Spades", [1,11])
		playerFirstHand = player.hands.first
		playerFirstHand.add(card1)
		playerFirstHand.add(card2)

		@g.splitHand(player)
		assert_equal(2, player.numHands)
		assert_equal(1, player.hands[0].size)
		assert_equal(1, player.hands[1].size)

		playerSecondHand = player.hands[1]

		assert_equal(playerFirstHand.cards.first, card1)
		assert_equal(playerSecondHand.cards.first, card2)
	end

	def test_game_splits_hand_on_value_of_ten
		# make sure first player has only 1 hand
		player = @player1
		assert_equal(1, player.numHands)
		card1 = Card.new("King", "Clubs", [10])
		card2 = Card.new("Jack", "Spades", [10])
		playerFirstHand = player.hands.first
		playerFirstHand.add(card1)
		playerFirstHand.add(card2)

		@g.splitHand(player)
		assert_equal(2, player.numHands)
		assert_equal(1, player.hands[0].size)
		assert_equal(1, player.hands[1].size)

		playerSecondHand = player.hands[1]

		assert_equal(playerFirstHand.cards.first, card1)
		assert_equal(playerSecondHand.cards.first, card2)
	end

	def test_game_does_not_split_if_hand_size_not_2
		# make sure first player has only 1 hand
		player = @player1
		assert_equal(1, player.numHands)
		card1 = Card.new("King", "Clubs", [10])
		playerFirstHand = player.hands.first
		playerFirstHand.add(card1)

		assert_raise(CannotSplitError) {@g.splitHand(player)}

		# Shouldn't split if only 1 card
		assert_equal(1, player.numHands)
		assert_equal(1, player.hands[0].size)

		assert_equal(playerFirstHand.cards.first, card1)

		card2 = Card.new("Ten", "Clubs", [10])
		card3 = Card.new("Jack", "Clubs", [10])

		playerFirstHand.add(card2)
		playerFirstHand.add(card3)

		assert_raise(CannotSplitError) {@g.splitHand(player)}

		# Shouldn't split if more than 2 cards
		assert_equal(1, player.numHands)
		assert_equal(3, player.hands[0].size)
	end

	def test_game_does_not_split_if_hand_is_not_two_tens
		# make sure first player has only 1 hand
		player = @player1
		assert_equal(1, player.numHands)

		card1 = Card.new("King", "Clubs", [10])
		card2 = Card.new("Ace", "Spades", [1,11])
		playerFirstHand = player.hands.first
		playerFirstHand.add(card1)
		playerFirstHand.add(card2)


		assert_raise(CannotSplitError) {@g.splitHand(player)}
		# Shouldn't split if hand is not a pair of 10s
		assert_equal(1, player.numHands)
		assert_equal(2, player.hands[0].size)

	end

	def test_game_raises_error_if_hand_value_over_21
		player = @player1

		card1 = Card.new("King", "Clubs", [10])
		card2 = Card.new("Queen", "Spades", [10])
		card3 = Card.new("Jack", "Diamonds", [10])

		playerHand = player.hands.first

		playerHand.add(card1)
		playerHand.add(card2)
		playerHand.add(card3)

		assert_raise(PlayerLostHandException) {@g.dealToPlayer(player,playerHand)}
	end

	def test_game_raises_hit_21_exception_if_value_is_21
		player = @player1

		card1 = Card.new("King", "Clubs", [10])
		card2 = Card.new("Queen", "Spades", [10])

		playerHand = player.hands.first

		playerHand.add(card1)
		playerHand.add(card2)
		@g.deck.cards.clear
		@g.deck.cards.push(Card.new("Ace", "Spades", [1,11]))

		assert_raise(PlayerHit21Exception) {@g.dealToPlayer(player,playerHand)}
	end

	def test_game_does_not_raise_error_if_hand_value_below_21
		@g.dealToPlayer(@player1,@player1.hands.first)
	end

	def test_game_end_round_calculations
		
		dealer = @g.dealer
		dealerHand = dealer.hands.first
		card1 = Card.new("King", "Clubs", 10)
		card2 = Card.new("Ace", "Diamonds", [1,11])
		dealerHand.add(card1)
		dealerHand.add(card2)

		assert(!dealerHand.lost)

		card3 = Card.new("Six", "Diamonds", 6)
		# Make the hand a soft 17
		dealerHand.add(card3)
		@g.endRound
		assert(!dealerHand.lost)
		assert_equal(3, dealerHand.size)

		# Testing that the dealer draws until we hit soft 17
		dealerHand.remove(card3)
		card4 = Card.new("Two", "Diamonds", 2)
		# Following line makes the hand values: (13, 23)
		dealerHand.add(card4)
		# Create a mock deck
		@cards = @g.deck.cards
		@cards.clear
		@cards.push(Card.new("Two", "Spades", 2))
		@cards.push(Card.new("Three", "Clubs", 3))
		@g.endRound
		assert(!dealerHand.lost)
		assert_equal(5, dealerHand.size)

	end	

	def test_game_raises_error_if_cannot_double_down
		player = @player1
		player.score = 10000
		playerHand = player.hands.first
		card1 = Card.new("Two", "Spades", 2)
		card2 = Card.new("Three", "Spades", 3)
		card3 = Card.new("Four", "Diamonds", 4)
		playerHand.add(card1)
		playerHand.add(card2)
		playerHand.add(card3)

		playerHand.bet = 10

		# Should raise an error since the hand has 3 cards
		assert_raise(CannotDoubleDownError) {@g.doubleDown(player, playerHand)}

		playerHand.remove(card3)

		# Should not raise an error now that the hand has only 2 cards
		@g.doubleDown(player, playerHand)
		playerHand.isDoubledDown = false
		# Remove the card the game added after doubling-down
		playerHand.cards.pop

		player.hands << PlayerHand.new
		# Should raise an error now that we have 2 hands for the player
		assert_raise(CannotDoubleDownError) {@g.doubleDown(player, playerHand)}
		# Remove the second hand again
		player.hands.pop
		# Make sure we can double-down
		@g.doubleDown(player, playerHand)
		playerHand.isDoubledDown = false
		playerHand.cards.pop

		# make the player score less than the bet amount, ensure we can't double down
		player.score = 5
		assert_raise(CannotDoubleDownError) {@g.doubleDown(player, playerHand)}

	end	

end

class TestPlayerHand < Test::Unit::TestCase
	def test_add_card_to_hand
		hand = PlayerHand.new
		# Test empty hand returns a set with value 0
		assert_equal([0].to_set, hand.possibleValues)
		# Test that the calculator returns 0
		assert_equal([0].to_set, hand.calculatePossibleVals)

		hand.add(Card.new("Five", "Diamonds", 5))
		assert_equal([5].to_set, hand.possibleValues)

		hand.add(Card.new("Ace", "Clubs", [1,11]))
		assert_equal([6,16].to_set, hand.possibleValues)

		hand.add(Card.new("Ace", "Spades", [1,11]))
		assert_equal([7, 17, 27].to_set, hand.possibleValues)
	end

	def test_remove_card_from_hand
		hand = PlayerHand.new
		card1 = Card.new("Five", "Diamonds", 5)
		card2 = Card.new("Ace", "Clubs", [1,11])
		hand.add(card1)
		hand.add(card2)

		hand.remove(card1)

		assert_equal(1, hand.size)
		assert_equal(hand.cards.first, card2)
		assert_equal([1,11].to_set, hand.possibleValues)
	end

	def test_hand_comparisons
		hand1 = PlayerHand.new
		hand2 = PlayerHand.new

		card1 = Card.new("Five", "Diamonds", 5)
		card2 = Card.new("Ace", "Clubs", [1,11])

		hand1.add(card1)
		hand1.add(card2)

		card3 = Card.new("Ten", "Diamonds", 10)
		card4 = Card.new("Ten", "Clubs", 10)
		card5 = Card.new("Six", "Diamonds", 6)

		hand2.add(card3)
		hand2.add(card4)
		hand2.add(card5)

		assert(hand1 > hand2)
		assert(!(hand1 < hand2))
		assert(hand2 < hand1)
		assert(!(hand2 > hand1))
		assert(!(hand2 == hand1))

		hand2.remove(card5)
		assert(hand2 > hand1)
		assert(!(hand2 < hand1))
		assert(hand1 < hand2)
		assert(!(hand1 > hand2))
		assert(!(hand1 == hand2))

		hand2.add(card5)
		hand2.remove(card4)

		assert(!(hand1 > hand2))
		assert(!(hand1 < hand2))
		assert(!(hand2 < hand1))
		assert(!(hand2 > hand1))

		assert(hand1 == hand2)
		assert(hand2 == hand1)

	end

end

class TestDeck < Test::Unit::TestCase

	def test_deck_created_after_cards_finished
		deck = Deck.new
		deck.cards.clear
		deck.cards << Card.new("King", "Diamonds", 10)
		assert_equal(1, deck.size)

		deck.getCard
		assert_equal(52, deck.size)

	end
end