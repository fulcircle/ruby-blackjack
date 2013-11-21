class Card
	def initialize(rank, suite, values)
		@rank = rank
		@suite = suite
		@values = Array(values)
		@hidden = false
	end

	def to_s
		unless @hidden
			return @rank + " of " + @suite + "(" + @values.to_s + ")"
		else
			return "**Hidden Card**"
		end
	end

	attr_reader :values
	attr_reader :rank
	attr_reader :suite
	attr_accessor :hidden
end