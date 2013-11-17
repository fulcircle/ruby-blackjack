require "test/unit"
require_relative "game"

class TestGame < Test::Unit::TestCase

	def test_game_creates_deck
		g = Game.new(2)
		deck = g.instance_variable_get("@deck")
		assert_equal(52, deck.size)

		# Make sure values for cards are not nil
		assert(deck.cards.all?{|x| x != nil})
	end

	def test_game_creates_players
		g = Game.new(2)
		assert_equal(2, g.players.length)
	end

	def test_game_deals_cards
		g = Game.new(2)
		deck = g.instance_variable_get("@deck")
		g.deal
		assert_equal(50, deck.size)
		assert_equal(1, g.players[0].hand.size)
		assert_equal(1, g.players[1].hand.size)
	end

	def test_game_deals_card_to_player
		g = Game.new(2)
		deck = g.instance_variable_get("@deck")
		g.dealToPlayer(1)
		assert_equal(51, deck.size)
		assert_equal(1, g.players[1].hand.size)
		assert_equal(0, g.players[0].hand.size)

		g.dealToPlayer(0)

		assert_equal(50, deck.size)
		assert_equal(1, g.players[1].hand.size)
		assert_equal(1, g.players[0].hand.size)
	end
end
