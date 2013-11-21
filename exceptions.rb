class GameError < Exception
	def initialize(data)
		@data = data
	end

	attr_reader :data
end

class ValueOver21Error < GameError
end	

class CannotSplitError < GameError
end

class CannotDoubleDownError < GameError
end

class NoMoreHandsError < GameError
end

class MinBetError < GameError
end

class NoMoneysError < GameError
end