require_relative "playerhand"

class Player
	def initialize(id, name="")
		@id = id
		@name = name.empty? ? "Player" + @id.to_s : name
		@hands = [PlayerHand.new]
		@score = 1000
	end

	def addHand
		@hands << PlayerHand.new
	end


	attr_reader :hands
	attr_reader :name
	attr_reader :id
	attr_reader :score
end
