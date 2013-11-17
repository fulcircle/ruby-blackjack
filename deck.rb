require_relative "card"

class Deck
	@@suites = ["Hearts", "Clubs", "Spades", "Diamonds"]
	@@ranks = ["King", "Queen", "Jack", "Ten", "Nine", "Eight", "Seven", "Six", "Five", "Four", "Three", "Two", "Ace"]
	@@values = [10, 10, 10, 10, 9, 8, 7, 6, 5, 4, 3, 2, [1,11]]

	def initialize
		@cards = Array.new
		# Build each card and add to cards array
		@@suites.product(@@ranks).zip(@@values*@@suites.length).each{|x| @cards << Card.new(x[0][1], x[0][0], x[1])}
	end

	def shuffle
		@cards.shuffle
	end

	def getCard
		return @cards.pop
	end

	def size
		return @cards.length
	end

	def to_s
		@cards
	end

	attr_reader :cards
end