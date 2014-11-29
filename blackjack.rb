#Implement a simple game of blackjack. It should employ a basic command-line interface. The program should begin by asking how many players are at the table, start each player with $1000, and allow the players to make any integer bet for each deal.
#The program must implement the core blackjack rules, i.e. players can choose to hit until they go over 21, the dealer must hit on 16 and stay on 17, etc. It must also support doubling-down and splitting. You are welcome but not required to add functionality on top of these basics. We are most interested in seeing a clean codebase that we can readily understand.

###BEGIN BY RUNNING "ruby blackjack.rb"####


require './Player'

#Method to ask for bets from current players
def placeBets(dealer)
    for player in dealer.players
        puts "========================================"
        player.clearHands
        player.setBet
    end
end

#Method implementing player turn action
def playAction(dealer, hand)
    player = hand.player
    continue = true
    begin
        3.times{ puts "========================================"}
        if (hand[0][1] == hand[1][1] || 
        hand.cardValue(hand[0]) == hand.cardValue(hand[1])) && player.money >= hand.bet
        puts "#{player.name}, you can split! Would you like to split? (Y/N)"
        choice = gets.chomp.downcase
        split = (choice == "yes" || choice == "y")
        if split #deal with the split hand
            newHand = player.splitHand(hand)
            puts "For the regular hand..."
            dealer.passCards(hand)
            puts "Press enter to continue"
            gets
            puts "New Hand..."
            dealer.passCards(newHand)
        end

        puts "#{player.name}, choose from the following options:"
        puts "Check Hand (C), Hit(H), Stay (S), Double Down (D), Check Money (M)"
        action = gets.chomp
        case action

        ###DEBUGGING COMMANDS###
        when "DECK!"
            dealer.checkDeck
        when "ADMIN"
            puts "#{dealer.players} list of players"

        ###ACTIONS###
        when "M" #Check Money
            player.checkBet(hand)
        when "C" #Check Cards
            hand.checkCards
        when "H" #Hit
            continue = dealer.passCards(hand)
        when "S" #Stay
            continue = false 
        when "D" #Double Down
            if player.doubleHand(hand)
                puts "Good Luck!"
                dealer.passCards(hand)
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

    ###Obtain bets from all remaining players###
    placeBets(dealer)

    #Pass out cards to all remaining players
    for player in dealer.players
        puts "========================================"
        puts "#{player.name}, Here are your cards"
        2.times{ dealer.passCards(player.mainHand) }
    end

    #Dealer Draws Hand - If Jackpot, then Dealer wins#
    if !dealer.firstHand 
        return false
    end

    #Game flow for each player
    for player in dealer.players
        for hand in player.player_hands
            3.times{ puts "========================================"}
            split = false
            puts "#{player.name}, what would you like to do?"
            playAction(dealer, hand) 
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
def payoff(dealer, player)
    for hand in player.playerHands
        if hand.busted
            next 
        end
        puts "Checking hand for #{player.name}..."

        if dealer.busted || hand.handVal > dealer.handValue #Winning case
            puts "#{player.name}, you've beat the dealer!"
            puts "You've won #{hand.bet}!"
            player.win(hand)
        elsif dealer.handValue > hand.handVal #Losing Case
            puts "Dealer hand is greater than #{player.name}..."
        else #Tie case
            puts "It's a tie between Dealer and #{player.name}."
            player.tie(hand)
        end
        puts "#{player.name}, you have #{player.money} dollars left."
        puts "\nPress enter to continue..."
        gets
    end
end

#Method to check payoffs for all players with valid hands
def endGame(dealer)
    dealer.dealerRound
    puts "_______________________________"
    for i in dealer.players
        payoff(dealer, i)
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

