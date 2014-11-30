class Hand
    attr_reader :player, :bet, :handVal, :handNumber, :cards

    def initialize(ownPlayer, initbet, number)
        @player = ownPlayer
        @handNumber = number
        @bet = initbet
        @cards = []
        @handVal = 0
        @hasAce = false
    end

    #Method to deal with splitting hands
    #Returns new hand
    def splitAction
        newHand = Hand.new(@player, @bet, (@player.player_hands).length+1)
        newHand.receive(@cards.pop(), false, true)
        @handVal = 0
        @hasAce = false
        @handVal = cardValue(@cards[0])
        return newHand
    end

    #Method for double down - doubles the bet amount
    def double
        @bet *= 2
    end

    #Method that checks value and cards in hand
    #Allows for correct dialogue if checking all hands
    def checkCards(all=false)
        if all
            puts "For hand #{handNumber}..."
        else
            puts "This is hand #{handNumber}"
        end
        puts "It has the following cards:"
        for card in cards
            puts "#{card[1]} of #{card[0]}"
        end
        puts "This hand value is #{@handVal}"
    end

    #Method checking whether hand is busted
    def busted
        return @handVal > 21
    end

    #Method for adding card to hand
    #Will allow for proper dialogue for dealer and no dialogue needed
    def receive(card, dealerShow=false, mute=false)
        if dealerShow
            puts "#{@player.name} draws a hidden card..."
        elsif !mute
            puts "#{@player.name} draws a #{card[1]} of #{card[0]}..."
        end
        @cards << card
        cardVal = cardValue(card)
        if (((@handVal + cardVal) > 21) && @hasAce)
            @handVal -= 10
            @hasAce = false
        end
        @handVal += cardVal
    end

    #Method for determining the appropriate value of the card in context of hand
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
