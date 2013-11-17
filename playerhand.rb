require_relative "exceptions"
require "ostruct"

class PlayerHand
	def initialize
		@hand = Array.new
		@possibleValues = [0]
	end

	def add(card)
		@hand << card
		@possibleValues = self.calculatePossibleVals
		unless @possibleValues.any? { |val| val <= 21}
			raise ValuesOver21Error(@possibleValues)
		end
	end

	def calculatePossibleVals
		# All possible combinations of card values in this hand
		# See http://stackoverflow.com/questions/5226895/combine-array-of-array-into-all-possible-combinations-forward-only-in-ruby
		valueCombos = @hand.first.values.product(*@hand[1..-1])
		possibleVals = Array.new
		# All possible values of a hand
		valueCombos.each{|x| possibleVals << x.reduce(:+)} 
		return possibleVals
	end


	def size
		return @hand.length
	end

	attr_reader :possibleValues
	attr_reader :hand
end