#Implement a simple game of blackjack. It should employ a basic command-line interface. The program should begin by asking how many players are at the table, start each player with $1000, and allow the players to make any integer bet for each deal.
#The program must implement the core blackjack rules, i.e. players can choose to hit until they go over 21, the dealer must hit on 16 and stay on 17, etc. It must also support doubling-down and splitting. You are welcome but not required to add functionality on top of these basics. We are most interested in seeing a clean codebase that we can readily understand.

###BEGIN BY RUNNING "ruby blackjack.rb"####


require './Player'

#Method to ask for bets from current players
def placeBets(dealer)
    for player in dealer.players
        puts "========================================"
        player.clearHand
        player.setBet
    end
end

#Method implementing player turn action
def playAction(dealer, player, split=false)
    continue = true
    begin
        3.times{ puts "========================================"}
        puts "#{player.name}, choose from the following options:"
        if split
            puts "Dealing split hand..."
        end
        puts "Check Hand (C), Hit(H), Stay (S), Double Down (D), Check Money (M)"
        action = gets.chomp
        case action

        ###DEBUGGING COMMANDS###
        when "DECK!"
            dealer.checkDeck
        when "ADMIN"
            puts "#{dealer.actives} ++++++++++++++++++++++++++++++++"
            puts "#{dealer.players} list of players"

        ###ACTIONS###
        when "M" #Check Money
            player.checkBet(split)
        when "C" #Check Cards
            player.checkHand(split)
        when "H" #Hit
            continue = dealer.passCards(player, split)
        when "S" #Stay
            continue = false 
        when "D" #Double Down
            if player.doubleBet(split)
                puts "Good Luck!"
                dealer.passCards(player, split)
                continue = false
            end
        else #Bad Command
            puts "I don't recognize your action"
        end
    end while continue
end

###
def play(dealer)
    #Initialize Round - Dealer will create a new deck, shuffle the deck, reset variables

    dealer.createDeck
    dealer.shuffle
    dealer.clearHand
    dealer.actives = []

    ###Obtain bets from all remaining players###
    placeBets(dealer)

    #Pass out cards to all remaining players
    for player in dealer.players
        puts "========================================"
        puts "#{player.name}, Here are your cards"
        2.times{ dealer.passCards(player) }
    end

    #Dealer Draws Hand - If Jackpot, then Dealer wins#
    if !dealer.firstHand 
        return false
    end

    #Game flow for each player
    for player in dealer.players
        3.times{ puts "========================================"}
        split = false
        puts "#{player.name}, what would you like to do?"

        #Checks if 2 cards have same value or type AND if player can affort to split
        if (player.player_hand[0][1] == player.player_hand[1][1] || 
            player.cardValue(player.player_hand[0]) == player.cardValue(player.player_hand[1])) && player.money >= player.player_bet
            puts "#{player.name}, you can split! Would you like to split? (Y/N)"
            choice = gets.chomp.downcase
            split = (choice == "yes" || choice == "y")
            if split #deal with the split hand
                player.splitHand
                playAction(dealer, player, split)
            end
        end

        playAction(dealer, player) #regular hand action
        if !player.checkBust(split) || !player.checkBust #if either split hand or regular hand nonbust
            dealer.actives << player
        end
    end
end

#Method to remove bankrupt players
def checkPlayers(dealer)
    remaining = []
    for player in dealer.players
        if player.money <= 0 #Bankrupt case - Player does not continue
            puts "Sorry, #{player.name}! You're out of money! Try again next time."
        else 
            remaining << player #Add player to next round
        end
    end
    dealer.players = remaining
end

#Method to evaluate hands and handle the payoff
def payoff(dealer, i, split=false)
    if split
        puts "Checking split hand for #{i.name}..."
    else
        puts "Checking hand for #{i.name}..."
    end

    if dealer.checkBust || i.handValue(split) > dealer.handValue #Winning case
        puts "#{i.name}, you've beat the dealer!"
        puts "You've won #{i.player_bet}!"
        i.win(split)
    elsif dealer.handValue > i.handValue(split) #Losing Case
        puts "Dealer hand is greater than #{i.name}..."
    else #Tie case
        puts "It's a tie between Dealer and #{i.name}."
        i.tie(split)
    end
    puts "#{i.name}, you have #{i.money} dollars left."
    puts "\nPress enter to continue..."
    gets
end

#Method to check payoffs for all players with valid hands
def endGame(dealer)
    dealer.dealerRound
    puts "_______________________________"
    for i in dealer.actives
        if i.split && !i.checkBust(i.split) #Check the split hand
            payoff(dealer, i, i.split)
        end
        payoff(dealer, i) #Check regular hand
    end
end

#Main game function
def main
    puts "Welcome to the casino!"
    players = 0

    dealer = Dealer.new

    #Asks how many players at the table - Made sure there is at most 12 or else run risk of burning out the deck
    while true
        puts "How many players are there?"
        players = gets.chomp.to_i
        if (players > 0 && players < 13)
            break
        else
            puts "Not a valid number of players"
        end
    end

    #Asks all players for their names
    for i in 1..players
        puts "Player #{i}, what is your name?"
        name = gets.chomp
        p = Player.new(name, 1000)
        dealer.players << p
        puts "Hello, #{name}"
    end

    #Begin rounds, ends when players decide not to play OR all players are bankrupt
    begin
        if play(dealer)
            endGame(dealer)
        end
        puts "Would you like to play another round? (Y/N)"
        cont = gets.chomp.downcase
        checkPlayers(dealer)
    end while (cont == "y" || cont == "yes") && dealer.players.length > 0
    puts "Thanks for playing!"
end

####RUN GAME####
main

