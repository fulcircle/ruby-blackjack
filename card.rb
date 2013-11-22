class Card
	@@suiteSymbols = {"Spades"=>"\u2660", "Hearts"=>"\u2665", "Diamonds"=>"\u2666", "Clubs"=>"\u2663"}
	@@rankSymbols = {"One"=>"1", "Two"=>"2", "Three"=>"3", "Four"=>"4", "Five"=>"5", \
							"Six"=>"6", "Seven"=>"7", "Eight"=>"8", "Nine"=>"9", "Ten"=>"10", \
							"Jack"=>"J", "Queen"=>"Q", "King"=>"K", "Ace"=>"A"}

	def initialize(rank, suite, values)
		@rank = rank
		@suite = suite
		@values = Array(values)
		@hidden = false
	end

	def to_s
		unless @hidden
			# return @rank + " of " + @suite + "(" + @values.to_s + ")"
			symbol = @@rankSymbols[@rank] + @@suiteSymbols[@suite].encode("utf-8")
			return symbol
		else
			return "??"
			# return "**Hidden Card**"
		end
	end

	attr_reader :values
	attr_reader :rank
	attr_reader :suite
	attr_accessor :hidden
end