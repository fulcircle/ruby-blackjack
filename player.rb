require_relative "playerhand"

class Player
	def initialize(id, name="")
		@id = id
		@name = name.empty? ? "Player" + (@id+1).to_s : name
		@hands = [PlayerHand.new]
		@score = 1000
	end

	def addHand
		@hands << PlayerHand.new
	end

	def isDoubledDown?
		return @hands.any? {|hand| hand.isDoubledDown}
	end

	def numHands
		return @hands.length
	end

	def to_s
		return @name
	end

	def clearHands
		@hands.clear
		@hands = [PlayerHand.new]
	end


	attr_reader :hands
	attr_reader :name
	attr_reader :id
	attr_accessor :score
	attr_reader :isDoublingDown
end

class Dealer < Player

	def initialize(id, name="")
		super
		@name = "Dealer"
	end

	def addHand
	end

	def doubleDown
	end
end
