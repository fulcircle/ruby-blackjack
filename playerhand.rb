require_relative "exceptions"
require "set"

class PlayerHand
	def initialize
		@cards = Array.new
		@possibleValues = Set.new [0]
		@bet = 0
	end

	def add(card)
		@cards << card
		@possibleValues = self.calculatePossibleVals
	end

	def remove(card)
		@cards.delete(card)
		@possibleValues = self.calculatePossibleVals
	end

	def calculatePossibleVals
		if @cards.length > 0
			# All possible combinations of card values in this hand
			# See http://stackoverflow.com/questions/5226895/combine-array-of-array-into-all-possible-combinations-forward-only-in-ruby
			valueCombos = @cards.first.values.product(*(@cards[1..-1].collect{|x| x.values}))
			possibleVals = Set.new
			# All possible values of a hand
			valueCombos.each{|x| possibleVals << x.reduce(:+)} 
			return possibleVals
		else
			return [0].to_set
		end
	end

	def to_s
		return @cards.to_s
	end

	def size
		return @cards.length
	end

	attr_reader :possibleValues
	attr_reader :cards
	attr_accessor :bet
end