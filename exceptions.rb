class ValueOver21Error < Exception
	def initialize(values)
		@values = values
	end
end	

class CannotSplitHandException < Exception
	def initialize(values)
		@values = values
	end
end