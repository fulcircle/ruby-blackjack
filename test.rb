require "test/unit"
require_relative "game"
require_relative "playerhand"

class TestGame < Test::Unit::TestCase

	def setup
		@g = Game.new(2)
		@deck = @g.instance_variable_get("@deck")
	end

	def test_game_creates_deck
		assert_equal(52, @deck.size)

		# Make sure values for cards are not nil
		assert(@deck.cards.all?{|x| x != nil})
	end

	def test_game_creates_players
		assert_equal(2, @g.players.length)
	end

	def test_game_deals_cards
		@g.deal
		assert_equal(50, @deck.size)
		assert_equal(1, @g.players[0].hands.first.size)
		assert_equal(1, @g.players[1].hands.first.size)
		assert_not_equal(@g.players[0].hands.first.cards[0], @g.players[1].hands.first.cards[0])
	end

	def test_game_deals_card_to_player
		@g.dealToPlayer(1)
		assert_equal(51, @deck.size)
		assert_equal(1, @g.players[1].hands.first.size)
		assert_equal(0, @g.players[0].hands.first.size)

		@g.dealToPlayer(0)
		assert_equal(50, @deck.size)
		assert_equal(1, @g.players[1].hands.first.size)
		assert_equal(1, @g.players[0].hands.first.size)
	end

	def test_game_deals_card_on_hit
		@g.hit(1)
		assert_equal(51, @deck.size)
		assert_equal(1, @g.players[1].hands.first.size)
		assert_equal(0, @g.players[0].hands.first.size)

		@g.hit(0)
		assert_equal(50, @deck.size)
		assert_equal(1, @g.players[1].hands.first.size)
		assert_equal(1, @g.players[0].hands.first.size)
	end

	def test_game_deals_to_all_hands
		@g.players.first.addHand
		@g.deal
		assert_equal(49, @deck.size)
		assert_equal(1, @g.players[0].hands[0].size)
		assert_equal(1, @g.players[0].hands[1].size)

		assert_equal(1, @g.players[1].hands.first.size)
	end

	def test_game_deals_to_one_hand
		@g.players.first.addHand
		@g.dealToPlayer(0, 1)
		assert_equal(51, @deck.size)
		assert_equal(0, @g.players[0].hands[0].size)
		assert_equal(1, @g.players[0].hands[1].size)

		assert_equal(0, @g.players[1].hands.first.size)
	end

	def test_game_splits_hand_on_same_rank
		# make sure first player has only 1 hand
		player = @g.players.first
		assert_equal(1, player.hands.size)
		card1 = Card.new("Ace", "Clubs", [1,11])
		card2 = Card.new("Ace", "Spades", [1,11])
		playerFirstHand = player.hands.first
		playerFirstHand.add(card1)
		playerFirstHand.add(card2)

		@g.splitHand(0)
		assert_equal(2, player.hands.size)
		assert_equal(1, player.hands[0].size)
		assert_equal(1, player.hands[1].size)

		playerSecondHand = player.hands[1]

		assert_equal(playerFirstHand.cards.first, card1)
		assert_equal(playerSecondHand.cards.first, card2)
	end

	def test_game_splits_hand_on_value_of_ten
		# make sure first player has only 1 hand
		player = @g.players.first
		assert_equal(1, player.hands.size)
		card1 = Card.new("King", "Clubs", [10])
		card2 = Card.new("Jack", "Spades", [10])
		playerFirstHand = player.hands.first
		playerFirstHand.add(card1)
		playerFirstHand.add(card2)

		@g.splitHand(0)
		assert_equal(2, player.hands.size)
		assert_equal(1, player.hands[0].size)
		assert_equal(1, player.hands[1].size)

		playerSecondHand = player.hands[1]

		assert_equal(playerFirstHand.cards.first, card1)
		assert_equal(playerSecondHand.cards.first, card2)
	end

	def test_game_does_not_split_if_hand_size_not_2
		# make sure first player has only 1 hand
		player = @g.players.first
		assert_equal(1, player.hands.size)
		card1 = Card.new("King", "Clubs", [10])
		playerFirstHand = player.hands.first
		playerFirstHand.add(card1)

		@g.splitHand(0)
		# Shouldn't split if only 1 card
		assert_equal(1, player.hands.size)
		assert_equal(1, player.hands[0].size)

		assert_equal(playerFirstHand.cards.first, card1)

		card2 = Card.new("Ten", "Clubs", [10])
		card3 = Card.new("Jack", "Clubs", [10])

		playerFirstHand.add(card2)
		playerFirstHand.add(card3)

		@g.splitHand(0)

		# Shouldn't split if more than 2 cards
		assert_equal(1, player.hands.size)
		assert_equal(3, player.hands[0].size)
	end

	def test_game_does_not_split_if_hand_is_not_two_tens
		# make sure first player has only 1 hand
		player = @g.players.first
		assert_equal(1, player.hands.size)

		card1 = Card.new("King", "Clubs", [10])
		card2 = Card.new("Ace", "Spades", [1,11])
		playerFirstHand = player.hands.first
		playerFirstHand.add(card1)
		playerFirstHand.add(card2)


		@g.splitHand(0)
		# Shouldn't split if hand is not a pair of 10s
		assert_equal(1, player.hands.size)
		assert_equal(2, player.hands[0].size)

	end

end

class TestPlayerHand < Test::Unit::TestCase
	def test_possible_values_calculation
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
	end
end