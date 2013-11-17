class Card
	def initialize(rank, suite, values)
		@rank = rank
		@suite = suite
		@values = Array(values)
	end

	def to_s
		@rank + " of " + @suite + "(" + @values.to_s + ")"
	end

	attr_reader :values
end