require_relative "game"
require_relative "exceptions"

class FrontEnd
	NEWLINE = "\n"

	def initialize
		puts "Welcome to BlackJack!"
		numPlayers = prompt "How many players?", "int"
		@game = Game.new(numPlayers)
		@game.startRound
		@dealer = @game.dealer
		@players = @game.players

		self.startGame
	end

	def startGame
		while true do
			self.playRound
			@game.nextRound
		end
	end

	def playRound
		for player in @players
			amt = prompt player.to_s + ", place your bet: ", "int"
			@game.placeBet(player, amt)
		end

		self.printState
		
		@players.each {
			|player|
				player.hands.each {
					|hand|
					playLoop(player, hand)
				}
		}

		@game.endRound
		self.printState(true)	
	end

	def playLoop(player, hand)
		while true do

			begin
				self.play(player, hand)
			rescue PlayerLostHandException => e
				puts hand.to_s
				puts "You went over 21! (value of hand: " + e.data[:hand].possibleValues.to_a.to_s + ")"
				puts ""
				break
			rescue PlayerStayException
				puts "You are staying your hand"
				puts ""
				break
			rescue PlayerSplitException
				puts "You decided to split"
				puts ""
			rescue PlayerDoubleDownException
				puts "You decided to double-down"
				puts ""
			end

			self.printState
		end
	end


	def play(player, hand)
		puts player.to_s + "'s turn"
		
		option = nil

		unless player.numHands > 1
			option = prompt "Available options: "
		else
			option = prompt "Available options (currently playing Hand " + (player.hands.index(hand)+1).to_s + "): "
		end
			case option
			when 'h'
				@game.dealToPlayer(player, hand) 
			when 's'
				raise PlayerStayException.new({:player=>player, :hand=>hand}), "Player stayed this hand"
			when 'sp'
				@game.splitHand(player)
				raise PlayerSplitException.new({:player=>player, :hand=>hand}), "Player split this hand"
			when 'd'
				@game.doubleDown(player, hand)
				raise PlayerDoubleDownException.new({:player=>player, :hand=>hand}), "Player doubled-down"
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


	def printState(round_end=false)
		puts "DEALER" 
		puts "-----"
		puts @dealer.hands.first.to_s
		puts NEWLINE
		@players.each { |player|
			puts player.to_s.upcase + " (Wallet: $" + player.score.to_s + ")"
			puts "-----"
			string = ""
			player.hands.each_with_index { |hand, i|
				string += "Hand "
				if player.numHands > 1
					string += (i+1).to_s
				end
				if hand.lost
					string += "(LOST)"
				end
				if round_end and !hand.lost
					string += "(WON)"
				end
				string += ": " + hand.to_s + NEWLINE
				string += "Bet Amount: $" + hand.bet.to_s + NEWLINE
			}
			string += NEWLINE	
			print string
		}
	end
end

f = FrontEnd.new