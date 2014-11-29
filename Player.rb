require './Hand'

class Player
    attr_reader :name, :money, :player_hands

    def initialize(name_player, mon)
        @name = name_player
        @money = mon

        ######## Hand Variables ##########
        @player_hands = []
    end

    ################ METHODS FOR GAME PLAY ##########################

    #Method to begin split when there are duplicates in value
    def splitHand(hand)
        @money -= hand.bet
        @player_hands << hand.splitAction
    end

    def mainHand
        return @player_hands[0]
    end

    def doubleHand(hand)
        if @money >= hand.bet
            @money -= hand.bet
            hand.double
            return true
        else
            return false
        end
    end

    def checkBet(hand)
        puts "#{name}, this hand's bet is #{hand.bet}"   
        puts "#{name}, you have #{money} left as of this turn!"
    end


    #################### METHODS TO DEAL WITH BET #####################

    #Method to take bets from player via input
    #Returns bet amount
    def setBet
        puts "#{@name}, you have #{@money} dollars right now."
        puts "========================================"
        begin
            puts "#{@name}, How much money do you wish to bet this round?"
            amount = gets.chomp.to_i
            puts "Are you sure you want to bet #{amount}? (Y/N)"
            verify = gets.chomp.downcase
            if amount <= 0 #Does not allow negative bets
                puts "That's not valid, sorry!"
                verify = false
            end
            if(amount > @money) #Does not allow over-betting
                puts "Sorry, you don't have money for this bet!"
                verify = false
            end
        end while verify != "y" && verify != "yes"

        puts "You have bet #{amount}!"
        @player_hands << Hand.new(self, amount)
    end

    ############### METHODS TO DEAL WITH PAYOFF #################

    #Method that pays off bet, called in a Win
    def win(hand)
        @money += 2*hand.bet
    end

    #Method that returns bet money, called in Ties
    def tie(hand)
        @money += hand.bet
    end

    ################ HELPER METHODS ###################

    #Helper method to clear variables for player
    def clearHands
        #Clears regular variables
        @player_hands = []
    end

end

class Dealer < Player

    attr_accessor :actives, :players

    ####Initializes the Dealer object to hold a deck
    #players - list of players
    #actives - list of active players before dealer round
    def initialize
        super("Dealer", 1000)
        @deck = []#Holds Deck
        @players = []
        @actives = []
        @main_hand = nil
    end

    ############# METHODS TO START EACH ROUND ##############
    
    #Method to create a new Deck
    def createDeck
        @deck = []
        cardType =["Hearts", "Clubs", "Spades", "Diamonds"]
        cardVal = ['A', 2, 3, 4, 5, 6, 7, 8, 9, 10, 'J', 'Q', 'K']
        for t in cardType
            for v in cardVal 
               @deck.push([t, v])
            end
        end
    end

    #Method to Shuffle Deck
    def shuffle
        for i in 0..(@deck.length - 1)
            swap = rand(@deck.length)
            @deck[swap], @deck[i] = @deck[i], @deck[swap]
        end
    end

    def handValue
        return @main_hand.handVal
    end

    #Method for dealer to draw hand
    #Returns True if dealer does not win
    def firstHand
        @main_hand = Hand.new(self, 1000)
        puts "========================================"
        @main_hand.receive(@deck.pop())
        @main_hand.receive(@deck.pop(), true)
        if @main_hand.handVal == 21
            puts "Dealer has drawn a JackPot!"
            puts "Dealer shows second card: #{@player_hands[1][1]} of #{@player_hands[1][0]}  "
            return false
        end
        return true
    end

    ################# METHODS FOR GAMEPLAY ####################

    #Method to take the card on top of deck and pass card to current player
    #Returns true if player is allowed to continue - not allowed if hand is greater than 21
    def passCards(hand)
        hand.receive(@deck.pop())#Pass out card
        puts "#{hand.player}"
        if hand.player.name != "Dealer"
            if hand.busted
                puts "========================================"
                puts "Sorry! You've bust!"
                return false
            end
        end
        return true
    end


    #Method for Dealer's turn - Show hand and will not hit if hand > 16
    #Returns the value of the Dealer's hand
    def dealerRound
        if @actives.length < 1
            return
        end
        puts "Dealer shows second card: #{@player_hands[1][1]} of #{@player_hands[1][0]}  "
        while(@main_hand.handVal < 17) do #Dealer will not hit over 16
            puts "Press enter to continue..."
            gets
            passCards(@main_hand)
        end
        puts "Dealer hand is #{@player_handsVal}"
        return @main_hand.handVal
    end


    #####################DEBUGGING####################
    #Prints the deck
    def checkDeck
        puts "#{@deck} and Length is #{@deck.length}"
    end
end
