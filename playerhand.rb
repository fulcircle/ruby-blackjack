require_relative "exceptions"
require "set"

class PlayerHand
	def initialize
		@cards = Array.new
		@possibleValues = Set.new [0]
		@bet = 0
		@isDoubledDown = false
		@blackjack = false
	end

	def add(card)
		@cards << card
		@possibleValues = self.calculatePossibleVals
	end

	def remove(card)
		@cards.delete(card)
		@possibleValues = self.calculatePossibleVals
	end

	def >(other_hand)
		selfFilteredVals = self.possibleValues.select{|val| val<=21}
		otherFilteredVals = other_hand.possibleValues.select{|val| val<=21}
		if selfFilteredVals.length == 0 and otherFilteredVals.length >= 0
			return false
		elsif selfFilteredVals.length > 0 and otherFilteredVals.length == 0
			return true
		else 
			return selfFilteredVals.max > otherFilteredVals.max
		end
	end

	def <(other_hand)
		selfFilteredVals = self.possibleValues.select{|val| val<=21}
		otherFilteredVals = other_hand.possibleValues.select{|val| val<=21}

		if selfFilteredVals.length >= 0 and otherFilteredVals.length == 0
			return false
		elsif selfFilteredVals.length == 0 and otherFilteredVals.length > 0
			return true
		else 
			return selfFilteredVals.max < otherFilteredVals.max
		end
	end

	def ==(other_hand)
		selfFilteredVals = self.possibleValues.select{|val| val<=21}
		otherFilteredVals = other_hand.possibleValues.select{|val| val<=21}
		if selfFilteredVals.length == 0 and otherFilteredVals.length == 0
			return true
		elsif selfFilteredVals.length > 0 and otherFilteredVals.length == 0
			return false
		elsif selfFilteredVals.length == 0 and otherFilteredVals.length > 0	
			return false
		else
			return selfFilteredVals.max == otherFilteredVals.max
		end
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
		string = ""
		for card in @cards	
			string += card.to_s + " "
		end
		unless @cards.any? {|x| x.hidden}
			string += "("
			possibleValues.each_with_index {
								|val, i| 
								string += val.to_s
								i == possibleValues.length-1 ? string += "" : string += ","
							}
			string += ")"
		end
		return string
	end

	def size
		return @cards.length
	end

	attr_reader :possibleValues
	attr_reader :cards
	attr_accessor :bet
	attr_accessor :lost
	attr_accessor :isDoubledDown
	attr_accessor :blackjack
end