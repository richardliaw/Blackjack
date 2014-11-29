class Hand
    attr_reader :player, :bust
    attr_accessor :hasAce

    def initialize(ownPlayer, initbet, split=false)
        @player = ownPlayer
        @bet = initbet
        @cards = []
        @cardVals = 0
        @hasAce = false
        @split = split
        @bust = false
    end

    def splitHand
        splitBet
        splitHand = Hand.new(@player, bet, true)
        splitHand.receive(@cards.pop) #TODO: Check if this updates handValue and hasAce
        @player_handVal = 0
        @player_handVal = cardValue(@cards[0])
        # puts "#{@player_handVal} and #{@splitHandList} and @player"
        # @splitHasAce = @hasAce
    end

    def checkHand
        puts "You have the following cards:"

        for card in hand
            puts "#{card[1]} of #{card[0]}"
        end
        puts "Your hand value is #{val}"
    end

    def checkBet 
        puts "#{name}, your current bet is #{player_bet}"
        puts "#{name}, you have #{money} left as of this turn!"
    end
    def receive(card)
        @player_hand << card
        cardVal = cardValue(card)
        if (((@player_handVal + cardVal) > 21) && @hasAce)
            @player_handVal -= 10
            @hasAce = false
        end
        @player_handVal += cardValue(card)

    end

    def cardValue(card)
    end

    def 

end

class Player
    attr_reader :player_handVal, :name, :money, :player_bet, :player_hand, :split, :split_bet, :split_val

    def initialize(name_player, mon)
        @name = name_player
        @money = mon

        ######## Hand Variables ##########
        @player_bet = 0
        @player_hand = []
        @player_handVal = 0 
        @hasAce = false

        ######## Split Hand Variables ##########
        @split = false
        @splitHandList = []
        @splitHandValue = 0
        @splitHasAce = false
        @split_bet = 0
    end


    ################ METHODS FOR GAME PLAY ##########################

    #Method to begin split when there are duplicates in value
    def splitHand
        splitBet
        @split = true
        @splitHandList.push(@player_hand.pop)
        @player_handVal = 0 #Will reset value in case of Ace
        @player_handVal = cardValue(@splitHandList[0])
        # puts "#{@player_handVal} and #{@splitHandList} and @player"
        @splitHasAce = @hasAce
        @splitHandValue = @player_handVal
    end


    #Method that checks value and cards in hand
    def checkHand(split=false)
        hand = @player_hand
        val = handValue(split)
        if split
            hand = @splitHandList
        end

        puts "You have the following cards:"

        for card in hand
            puts "#{card[1]} of #{card[0]}"
        end
        puts "Your hand value is #{val}"
    end

    #Method that checks money and current bet
    def checkBet(split=false)
        if split
            puts "#{name}, your current split bet is #{split_bet}"
        else
            puts "#{name}, your current bet is #{player_bet}"
        end
        puts "#{name}, you have #{money} left as of this turn!"
    end

    #Method for Split hand receiving cards
    def split_receive(card)
        puts "#{name} draws a #{card[1]} of #{card[0]}..."
        @splitHandList << card
        cardVal = cardValue(card)
        if (((@splitHandValue + cardVal) > 21) && @splitHasAce)
            @splitHandValue -= 10
            @splitHasAce = false
        end
        @splitHandValue += cardValue(card)
    end

    #Method for regular hand receiving cards
    def receive(card, dealerShow=false)
        if dealerShow
            puts "#{name} draws a hidden card..."
        else
            puts "#{name} draws a #{card[1]} of #{card[0]}..."
        end
        @player_hand << card
        cardVal = cardValue(card)
        if (((@player_handVal + cardVal) > 21) && @hasAce)
            @player_handVal -= 10
            @hasAce = false
        end
        @player_handVal += cardValue(card)
    end

    #Method to check handValue
    def checkBust(split=false)
        return handValue(split) > 21
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
        @money -= amount
        @player_bet += amount
        return @player_bet
    end

    #Method to create a betting pool for the split hand
    #Returns false if not enough money to split hand
    def splitBet
        @money -= @player_bet
        @split_bet = @player_bet
    end

    #Method to evaluate double downs for regular or split hand
    #Returns false if not enough money to double pot
    def doubleBet(split=false)
        # puts "TEST: doubleBet"
        play_bet = @player_bet
        if split
            play_bet = @split_bet
        end

        if @money < play_bet
            puts "Sorry, you don't have money for this bet!"
            return false
        end
        @money -= play_bet
        if split
            @split_bet += play_bet
        else
            @player_bet += play_bet
        end
        return @player_bet
    end

    ############### METHODS TO DEAL WITH PAYOFF #################

    #Method that pays off bet, called in a Win
    def win(split=false)
        if split
            @money += 2*@split_bet
        else
            @money += 2*@player_bet 
        end
    end

    #Method that returns bet money, called in Ties
    def tie(split=false)
        if split
            @money += @split_bet
        else
            @money += @player_bet
        end
    end

    ################ HELPER METHODS ###################
    
    #Helper method to evaluate value of cards at hand
    #returns value of hand or split hand
    def handValue(split=false)
        if split 
            return @splitHandValue
        else
            return @player_handVal
        end
    end

    #Helper method to clear variables for player
    def clearHand
        #Clears regular variables
        @player_hand = []
        @player_handVal = 0
        @hasAce = false
        @player_bet = 0

        ##Clears split variables
        @split = false
        @splitHandList = []
        @splitHandValue = 0
        @splitHasAce = false
        @split_bet = 0
    end

    #Helper function to check the value of the card in hand - deals with the Ace and the 11/1 switching
    def cardValue(card, split=false)
        handVal = handValue(split)
        royals = ['J', 'Q', 'K']
        val = card[1]
        if val == 'A'
            if (handVal > 10)
                return 1
            else
                if split 
                    @splitHasAce = true
                else
                    @hasAce = true
                end
                return 11
            end
        elsif (royals.include? val)
            val = 10
        end
        return val
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

    #Method for dealer to draw hand
    #Returns True if dealer does not win
    def firstHand
        puts "========================================"
        receive(@deck.pop())
        receive(@deck.pop(), true)
        if @player_handVal == 21
            puts "Dealer has drawn a JackPot!"
            puts "Dealer shows second card: #{@player_hand[1][1]} of #{@player_hand[1][0]}  "
            return false
        end
        return true
    end

    ################# METHODS FOR GAMEPLAY ####################

    #Method to take the card on top of deck and pass card to current player
    #Returns true if player is allowed to continue - not allowed if hand is greater than 21
    def passCards(player, split=false)
        if split 
            player.split_receive(@deck.pop())
        else
            player.receive(@deck.pop())#Pass out card
        end
        if player.name != "Dealer"
            if player.checkBust(split)
                puts "========================================"
                puts "Sorry! You've bust!"
                return false
            end
        # elsif player.handValue(split) == 21
        #     puts "Jackpot!!!!!!!!!!"
        #     return false
        end
        return true
    end


    #Method for Dealer's turn - Show hand and will not hit if hand > 16
    #Returns the value of the Dealer's hand
    def dealerRound
        if @actives.length < 1
            return
        end
        puts "Dealer shows second card: #{@player_hand[1][1]} of #{@player_hand[1][0]}  "
        while(@player_handVal < 17) do #Dealer will not hit over 16
            puts "Press enter to continue..."
            gets
            passCards(self)
        end
        puts "Dealer hand is #{@player_handVal}"
        return @player_handVal
    end


    #####################DEBUGGING####################
    #Prints the deck
    def checkDeck
        puts "#{@deck} and Length is #{@deck.length}"
    end
end
