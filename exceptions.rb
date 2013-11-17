class ValuesOver21Error < Exception
	def initialize(values)
		@values = values
	end
end	