//
//  CardModel.swift
//  MemorizeView
//
//  Created by Guru Mahan on 20/12/22.
//

import Foundation
import SwiftUI

struct EmojiCardLoginModel<cardContent> where cardContent:Equatable {
    
    private (set) var cards: [Card]
    
    private var indexOfTheOneAndOnlyFaceUpCard: Int?{
        
        get { cards.indices.filter({cards[$0].isFaceUp }).oneAndOnly}
        set { cards.indices.forEach({cards[$0].isFaceUp = ($0 == newValue)})
                                      
        }
    }
    
    mutating func choose(_ card:Card){
        if let chosenIndex = cards.firstIndex(where: {$0.id == card.id}),
           !cards[chosenIndex].isFaceUp,
           !cards[chosenIndex].isMatched{
            if let potentialMatchIndex = indexOfTheOneAndOnlyFaceUpCard{
                if cards[chosenIndex].content == cards[potentialMatchIndex].content{
                    cards[chosenIndex].isMatched = true
                    cards[potentialMatchIndex].isMatched = true
                }
                cards[chosenIndex].isFaceUp = true
            }else{
                indexOfTheOneAndOnlyFaceUpCard = chosenIndex
            }
            
            
        }
       
        
    }
  mutating  func shuffle(){
        cards.shuffle()
    }
    
    init(numberOfPairsOfCards:Int ,createCardContent:(Int) -> cardContent){
        
        cards = []
        for pairIndex in 0..<numberOfPairsOfCards {
            let content = createCardContent(pairIndex)
            cards.append(Card(content:content, id: pairIndex*2))
            cards.append(Card(content:content, id: pairIndex*2+1))
        }
        cards.shuffle()
        
    }
  
    
    struct Card: Identifiable{
        var isFaceUp: Bool = false{
            didSet{
                if isFaceUp{
                    EmojiCardViewModel().startUsingBonusTime()
                }else{
                    EmojiCardViewModel().stopUsingBonusTime()
                }
            }
        }
        
        var isMatched: Bool = false{
            didSet{
                EmojiCardViewModel().stopUsingBonusTime()
            }
        }
        var content:cardContent
        var id: Int
    }
    
  
}


struct CardContants{
    
    static let color = Color.red
    static let aspectRatio: CGFloat = 2/3
    static let dealDuration:Double = 0.5
    static let totalDealDuration: Double = 2
    static let undealtHeight: CGFloat = 90
    static let undealtWidth = undealtHeight * aspectRatio
  
}
struct DrawingConstant {
 let cornerRadius: CGFloat = 10
 let lineWidth:CGFloat = 3
 let fontSize:CGFloat = 32
 let fontScale: CGFloat = 0.9
 }



extension Array{
    var oneAndOnly: Element? {
     if count == 1{
      return first
    }else{
      return nil
    }
  }
}

