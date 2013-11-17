require_relative "playerhand"
class Player
	def initialize(id, name="Some Dood")
		@id = id
		@name = name
		@hand = PlayerHand.new
		@score = 1000
	end


	attr_reader :hand
	attr_reader :name
	attr_reader :id
	attr_reader :score
end
