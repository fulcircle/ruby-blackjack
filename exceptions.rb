class GameException < Exception
	def initialize(data)
		@data = data
	end

	attr_reader :data
end

class PlayerLostHandException < GameException
end	

class CannotSplitError < GameException
end

class CannotDoubleDownError < GameException
end

class MinBetError < GameException
end

class NoMoneysError < GameException
end

class PlayerStayException < GameException
end

class PlayerSplitException < GameException
end

class PlayerDoubleDownException < GameException
end