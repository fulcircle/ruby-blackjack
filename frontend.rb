require_relative "game"

class FrontEnd
	def initialize
		puts "Welcome to BlackJack!"
		print "How many players? "
		numPlayers = getInt
		@game = Game.new(numPlayers)
		puts "Starting game"
		@game.start
		@dealer = @game.dealer
		@players = @game.players

		self.mainloop
	end

	def mainloop
		gameOver = false
		while !gameOver do
			self.printState
			puts "Available options: "
			print "> "
			option = getString
			case option
			when 'h'
				@game.dealToPlayer(@game.currPlayer, @game.currHand)
			when 'e'
				@game.nextHand
			end
		end
	end

	def getInt
		return Integer(gets.chomp)
	end

	def getString
		return gets.chomp
	end

	def printState
		puts "DEALER: " + @dealer.hands.first.to_s
		puts "---------"
		puts "---------"
		@players.each { |player|
			player.hands.each { |hand|
				puts player.to_s + ": " + hand.to_s
			}
			puts "---------"
		}
	end
end

f = FrontEnd.new