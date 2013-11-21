require_relative "game"

class FrontEnd
	def initialize
		puts "Welcome to BlackJack!"
		numPlayers = prompt "How many players?", "int"
		@game = Game.new(numPlayers)
		@game.start
		@dealer = @game.dealer
		@players = @game.players

		self.mainloop
	end

	def mainloop
		gameOver = false
		firstRound = true
		while !gameOver do
			if firstRound
				for player in @players
					amt = prompt player.to_s + ", place your bet: ", "int"
					@game.placeBet(player, amt)
				end
			end
			self.printState
			option = nil
			unless @game.currPlayer.numHands > 1
				option = prompt "Available options: "
			else
				option = prompt "Available options (currently playing Hand " + (@game.currHandIndex+1).to_s + "): "
			end

			case option
			when 'h'
				@game.dealToPlayer(@game.currPlayer, @game.currHand)
			when 's'
				@game.nextHand
			when 'sp'
				if firstRound
					@game.splitHand(@game.currPlayer, @game.currHand)
				end
			when 'd'
				if firstRound
					@game.doubleDown(@game.currPlayer)
				end
			end
			firstRound = false
		end
	end

	def prompt(string, readAs="string")
		puts string
		print "> "
		val = nil
		case readAs
		when "int"
			val = Integer(gets.chomp)
		when "string"	
			val = gets.chomp
		end

		return val
	end


	def printState
		puts "DEALER: " + @dealer.hands.first.to_s
		puts ""
		puts ""
		@players.each { |player|
			puts player.to_s + " (Wallet: $" + player.score.to_s + ")"
			player.hands.each_with_index { |hand, i|
				if player.numHands > 1
					puts "Hand " + (i+1).to_s + ": " + hand.to_s
				else
					puts "Hand: " + hand.to_s
				end
				puts "	Bet Amount: $" + hand.bet.to_s
			}
			puts ""
		}
	end
end

f = FrontEnd.new