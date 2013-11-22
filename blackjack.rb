require_relative "game"
require_relative "exceptions"

class FrontEnd
	NEWLINE = "\n"

	def initialize
		self.printStatusMsg "Welcome to BlackJack!"
		numPlayers = prompt "How many players?", "int"
		@game = Game.new(numPlayers)
		self.startGame
	end

	def startGame

		@dealer = @game.dealer
		@players = @game.players
		@currPlayer = @players.first

		while @players.any? {|player| player.score > 0} do
			@game.nextRound
			self.playRound
		end

		self.printStatusMsg "Y'all are broke, bye bye!"
	end


	def playRound
		self.printStatusMsg "---------------\nSTART ROUND\n---------------"
		self.getBets

		@players.each {
			|player|
			@currPlayer = player
			self.printState
				player.hands.each {
					|hand|
					playLoop(player, hand)
				}
		}

		@game.endRound
		self.printState(true)
		brokePlayers = @players.select{|player| player.score <= 0 }
		brokePlayers.each {
			|brokePlayer|
			self.printStatusMsg brokePlayer.to_s + " is broke, removing from game"
			@players.delete(brokePlayer)
		}
	end

	def playLoop(player, hand)
		while true do

			begin
				self.play(player, hand)
			rescue PlayerLostHandException
				self.printPlayer(player)
				self.printStatusMsg "Your hand went over 21"
				break
			rescue PlayerStayException
				self.printPlayer(player)
				self.printStatusMsg "You are staying your hand"
				break
			rescue PlayerSplitException
				self.printPlayer(player)
				self.printStatusMsg "Hand split"
			rescue PlayerDoubleDownException
				self.printPlayer(player)
				self.printStatusMsg "You doubled-down"
			rescue CannotSplitError
				self.printStatusMsg "You cannot split this hand"
			rescue CannotDoubleDownError 
				self.printStatusMsg "You cannot double-down now"
			rescue HandDoubledDownException
				# Hand is doubled down, so skip this hand
				break
			rescue PlayerHit21Exception
				self.printPlayer(player)
				self.printStatusMsg "You hit 21!"
				break
			else
				self.printPlayer(player)
			end

		end
	end

	def getBets
		for player in @players
			amt = nil
			while true
				amt = prompt player.to_s + " (Wallet: $" + player.score.to_s + "), place your bet: ", "int"
				begin
					@game.placeBet(player, amt)
				rescue NoMoneysError => e
					puts e.message
					next
				rescue MinBetError => mbe
					self.printStatusMsg "You must place the minimum bet of $" + mbe.data[:min_bet].to_s
					next
				end

				self.printStatusMsg "You bet $" + amt.to_s
				break
			end
		end
	end

	def play(player, hand)
		# This hand was a blackjack, move onto the next hand
		if hand.blackjack
			raise PlayerHit21Exception.new({:player=>player, :hand=>hand})
		end
		# This hand is doubled-down, and so finished
		if hand.isDoubledDown
			raise HandDoubledDownException.new({:player=>player, :hand=>hand})	
		end

		self.printStatusMsg player.to_s + "'s turn"
		
		option = nil

		unless player.numHands > 1
			option = prompt "Available options: " + self.getAvailableOptions(player, hand)
		else
			option = prompt "Available options (currently playing Hand " + (player.hands.index(hand)+1).to_s + "): " \
						 + self.getAvailableOptions(player, hand)
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
			when 'v'
				puts ""
				self.printDealer
			else
				self.printStatusMsg "Invalid command, try again?"
			end
	end

	def getAvailableOptions(player, hand)
		string = "(h)it, (s)tand"
		if @game.canDoubleDown(player)
			string += ", (d)ouble-down"
		end
		if @game.canSplit(player)
			string += ", (sp)lit"
		end
		string += ", (v)iew hand"
		return string
	end


	def prompt(string, readAs="string")
		val = nil
		while true
			puts string
			print "> "
			begin
				case readAs
				when "int"
					val = Integer(gets.chomp)
					if val <=0
						self.printStatusMsg "Needs to be positive number"
						next
					end
				when "string"	
					val = gets.chomp
				end
			rescue ArgumentError
				self.printStatusMsg "Couldn't parse that response, try again"
				next
			end
			break
		end
		return val
	end

	def printStatusMsg(msg)
		puts ""
		puts msg
		puts ""
	end


	def printState(round_end=false)
		if round_end
			self.printStatusMsg "---------------\nRESULTS\n---------------" 
		end
		self.printDealer
		if round_end
			@players.each {
				|player|
				self.printPlayer(player, round_end)	
			}
		else
			self.printPlayer(@currPlayer, round_end)
		end
	end

	def printDealer
		puts "DEALER" 
		puts "-----"
		puts @dealer.hands.first.to_s
	end

	def printPlayer(player, round_end=false)
		puts ""
		puts player.to_s.upcase + " (Wallet: $" + player.score.to_s + ")"
		puts "-----"
		string = ""
		player.hands.each_with_index { |hand, i|

			if hand.lost
				string += "*LOST* "
			elsif round_end and !hand.lost
				string += "*WON* "
			end

			string += "Hand "

			if player.numHands > 1
				string += (i+1).to_s
			end

			string += "(Bet: $" + hand.bet.to_s + ")"
			string += ": " + hand.to_s + NEWLINE

		}

		string += NEWLINE	
		print string
	end
end

f = FrontEnd.new