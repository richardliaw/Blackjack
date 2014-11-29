class Hand
    attr_reader :player, :bet

    def initialize(ownPlayer, initbet, split=false)
        @player = ownPlayer
        @bet = initbet
        @cards = []
        @handVal = 0
        @hasAce = false
        @split = split
    end

    def splitHand
        newHand = Hand.new(@player, @bet, true)
        newHand.receive(@cards.pop())
        reAdd = @cards.pop
        @handVal = 0
        @hasAce = false
        @handVal = cardValue(@cards[0])
        return newHand
    end

    def double
        @bet *= 2
    end

    def checkHand
        puts "You have the following cards:"
        for card in cards
            puts "#{card[1]} of #{card[0]}"
        end
        puts "Your hand value is #{@handVal}"
    end

    def checkBet
        puts "#{@player.name}, this hand's bet is #{@bet}"   
        puts "#{@player.name}, you have #{@player.money} left as of this turn!"
    end


    def busted
        return @handVal > 21
    end

    def receive(card, dealerShow=false)
        if dealerShow
            puts "#{name} draws a hidden card..."
        else
            puts "#{name} draws a #{card[1]} of #{card[0]}..."
        end
        @cards << card
        cardVal = cardValue(card)
        if (((@handVal + cardVal) > 21) && @hasAce)
            @handVal -= 10
            @hasAce = false
        end
        @handVal += cardVal
    end

    def cardValue(card)
        royals = ['J', 'Q', 'K']
        val = card[1]
        if val == 'A'
            if (@handVal > 10)
                return 1
            else
                @hasAce = true
                return 11
            end
        elsif (royals.include? val)
            val = 10
        end
        return val
    end

end

class Player
    attr_reader :player_handsVal, :name, :money, :player_bet, :player_hands, :split, :split_bet, :split_val

    def initialize(name_player, mon)
        @name = name_player
        @money = mon

        ######## Hand Variables ##########
        # @player_bet = 0
        @player_hands = []

        # ######## Split Hand Variables ##########
        # @split = false
        # @splitHandList = []
        # @splitHandValue = 0
        # @splitHasAce = false
        # @split_bet = 0
    end


    ################ METHODS FOR GAME PLAY ##########################

    #Method to begin split when there are duplicates in value
    def splitHand(hand)
        splitBet(hand)
        @player_hands << hand.splitHand
    end

    def doubleHand(hand)
        @money -= hand.bet
        hand.double
    end


    #Method that checks value and cards in hand
    # def checkHand(split=false)
    #     hand = @player_hands
    #     val = handValue(split)
    #     if split
    #         hand = @splitHandList
    #     end

    #     puts "You have the following cards:"

    #     for card in hand
    #         puts "#{card[1]} of #{card[0]}"
    #     end
    #     puts "Your hand value is #{val}"
    # end

    # #Method that checks money and current bet
    # def checkBet(split=false)
    #     puts "#{name}, your current bet is #{player_bet}"   
    #     puts "#{name}, you have #{money} left as of this turn!"
    # end

    #Method for Split hand receiving cards
    # def split_receive(card)
    #     puts "#{name} draws a #{card[1]} of #{card[0]}..."
    #     @splitHandList << card
    #     cardVal = cardValue(card)
    #     if (((@splitHandValue + cardVal) > 21) && @splitHasAce)
    #         @splitHandValue -= 10
    #         @splitHasAce = false
    #     end
    #     @splitHandValue += cardValue(card)
    # end

    # #Method for regular hand receiving cards
    # def receive(card, dealerShow=false)
    #     if dealerShow
    #         puts "#{name} draws a hidden card..."
    #     else
    #         puts "#{name} draws a #{card[1]} of #{card[0]}..."
    #     end
    #     @player_hands << card
    #     cardVal = cardValue(card)
    #     if (((@player_handsVal + cardVal) > 21) && @hasAce)
    #         @player_handsVal -= 10
    #         @hasAce = false
    #     end
    #     @player_handsVal += cardValue(card)
    # end

    # #Method to check handValue
    # def checkBust(split=false)
    #     return handValue(split) > 21
    # end


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
    
    #REMOVE
    #Helper method to evaluate value of cards at hand
    #returns value of hand or split hand
    # def handValue(split=false)
    #     if split 
    #         return @splitHandValue
    #     else
    #         return @player_handsVal
    # end

    #Helper method to clear variables for player
    def clearHands
        #Clears regular variables
        @player_hands = []
    end

    #REMOVE
    # #Helper function to check the value of the card in hand - deals with the Ace and the 11/1 switching
    # def cardValue(card, split=false)
    #     handVal = handValue(split)
    #     royals = ['J', 'Q', 'K']
    #     val = card[1]
    #     if val == 'A'
    #         if (handVal > 10)
    #             return 1
    #         else
    #             if split 
    #                 @splitHasAce = true
    #             else
    #                 @hasAce = true
    #             end
    #             return 11
    #         end
    #     elsif (royals.include? val)
    #         val = 10
    #     end
    #     return val
    # end

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
        if @player_handsVal == 21
            puts "Dealer has drawn a JackPot!"
            puts "Dealer shows second card: #{@player_hands[1][1]} of #{@player_hands[1][0]}  "
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
        puts "Dealer shows second card: #{@player_hands[1][1]} of #{@player_hands[1][0]}  "
        while(@player_handsVal < 17) do #Dealer will not hit over 16
            puts "Press enter to continue..."
            gets
            passCards(self)
        end
        puts "Dealer hand is #{@player_handsVal}"
        return @player_handsVal
    end


    #####################DEBUGGING####################
    #Prints the deck
    def checkDeck
        puts "#{@deck} and Length is #{@deck.length}"
    end
end
