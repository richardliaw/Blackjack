class Hand
    attr_reader :player, :bet, :handVal

    def initialize(ownPlayer, initbet, split=false)
        @player = ownPlayer
        @bet = initbet
        @cards = []
        @handVal = 0
        @hasAce = false
        @split = split
    end

    def splitAction
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

    def checkCards
        puts "You have the following cards:"
        for card in cards
            puts "#{card[1]} of #{card[0]}"
        end
        puts "Your hand value is #{@handVal}"
    end


    def busted
        return @handVal > 21
    end

    def receive(card, dealerShow=false)
        if dealerShow
            puts "#{@player.name} draws a hidden card..."
        else
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
