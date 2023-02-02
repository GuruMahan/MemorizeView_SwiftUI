

import SwiftUI

class EmojiCardViewModel: ObservableObject {
    
    var loginModelDrawContent = DrawingConstant()
    @Published var cardText:String =  ""
    var matchCard = EmojiCardLoginModel<String>.Card(content: "", id: 0)
 private static var emojIs = ["🚀","🏍","😈","🎃","✈️","🏎","🚒","🚜","🚁","⛵️","🚓","🚑","🛶","🚌","🛵","🛸","🚝","🚚","🚂","🚨","🚔","🚍","🚘","🚖","🚡","🚠","🚟","🚃","🚋","⭐️","🌕","🌍"]
    @Published var emojicount = 4
    
   private static func createModel() ->EmojiCardLoginModel<String>{
        
       EmojiCardLoginModel<String>(numberOfPairsOfCards:10)
        { pairIndex in emojIs[pairIndex]
            
        }
      // Int(String(describing: EmojiCardViewModel().cardText)) ?? 1
    }
    
 @Published var model:EmojiCardLoginModel<String> = createModel()
    
//    func addCard(){
//        if emojicount <  EmojiCardViewModel().emojIs.count {
//            emojicount += 1
//        }
//    }
//
//    func subractCard(){
//        if emojicount > 1{
//            emojicount -= 1
//        }
//    }
    
    var cards: Array<EmojiCardLoginModel<String>.Card>{
        model.cards
    }
    
    func choose( _ card:EmojiCardLoginModel<String>.Card) {
        model.choose(card)
        print(cards)
    }
    
    struct Pie: Shape{
        
        var startAngel: Angle
        var endAngle: Angle
        var clockWise:Bool = false
        
        var animatableData: AnimatablePair<Double,Double>{
            get{
                AnimatablePair(startAngel.radians, endAngle.radians)
            }
            set{
                startAngel = Angle.radians(newValue.first)
                endAngle = Angle.radians(newValue.second)
            }
            
        }
        
        
        func path(in rect: CGRect) -> Path {
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let radius = min(rect.width,rect.height) / 2
            let start = CGPoint(
                x: center.x + radius * CGFloat(cos(startAngel.radians)),
                y: center.y + radius * CGFloat(cos(endAngle.radians))
            )
            var p = Path()
            p.move(to: center)
            p.addLine(to: start)
            p.addArc(center: center,
                     radius: radius,
                     startAngle: startAngel,
                     endAngle: endAngle,
                     clockwise: !clockWise)
            p.addLine(to: center)
            return p
            
        }
    }
  func font(in size: CGSize) -> Font{
      Font.system(size: min(size.width, size.height) * loginModelDrawContent.fontScale)
    }
    
    func shuffle(){
        model.shuffle()
    }
    
    func restart(){
        model = EmojiCardViewModel.createModel()
    }
    func scale(thatFits size: CGSize) -> CGFloat {
        min(size.width,size.height) / (DrawingConstant().fontSize / DrawingConstant().fontScale)
    }
    
    @Published var dealt = Set<Int>()
     
    func deal(_ card: EmojiCardLoginModel<String>.Card){
         dealt.insert(card.id)
     }
     
     func isUndealt(_ card: EmojiCardLoginModel<String>.Card) -> Bool{
         !dealt.contains(card.id)
         
     }
    func dealAnimation(for card:EmojiCardLoginModel<String>.Card) -> Animation{
        var delay = 0.0
        if let index = cards.firstIndex(where: {$0.id == card.id}){
            delay =  Double(index) * (CardContants.totalDealDuration / Double(cards.count))
        }
        return Animation.easeInOut(duration: CardContants.dealDuration).delay(delay)
    }
    func zIndex(of card:EmojiCardLoginModel<String>.Card) -> Double{
        -Double(cards.firstIndex(where: {$0.id == card.id}) ?? 0)
    }
  
    //MARK: -Bonus
    var bonusTimeLimit: TimeInterval = 6

    private var faceUpTime: TimeInterval{
        if let lastFaceUpDate = self.lastFaceUpDate{
            return pastFaceUpTime + Date().timeIntervalSince(lastFaceUpDate)
        }else{
            return pastFaceUpTime
        }
    }

    var lastFaceUpDate: Date?

    var pastFaceUpTime: TimeInterval = 0

    var bonusTimeRemaining: TimeInterval{
        max(0, bonusTimeLimit - faceUpTime)
    }

    var bonusRemaining: Double{
        (bonusTimeLimit > 0 && bonusTimeRemaining > 0) ? bonusTimeRemaining/bonusTimeLimit:0
    }

    var hasEarnedBonus: Bool{
        matchCard.isMatched &&  bonusTimeRemaining > 0
    }

    var isConsumingBonusTime: Bool{
        matchCard.isFaceUp && !matchCard.isMatched && bonusTimeRemaining > 0
    }

     func startUsingBonusTime(){
        if isConsumingBonusTime, lastFaceUpDate == nil{
            lastFaceUpDate = Date()
        }
    }

    func stopUsingBonusTime(){
        pastFaceUpTime = faceUpTime
        self.lastFaceUpDate = nil
    }
}
struct AspetVGrid<Item, ItemView>: View where ItemView:View,Item:Identifiable {
    var items: [Item]
    var aspectRatio: CGFloat
    var content:(Item) -> ItemView
    
    init(items: [Item], aspectRatio: CGFloat,@ViewBuilder content: @escaping (Item) -> ItemView) {
        self.items = items
        self.aspectRatio = aspectRatio
        self.content = content
    }
    
    var body: some View{
        GeometryReader{ geometry in
            let width: CGFloat = widthThatFits(itemCount: items.count, in: geometry.size, itemAspecRatio: aspectRatio)
            LazyVGrid(columns: [adaptiveGridItem(width: width)],spacing: 0){
                
                ForEach(items) { item in
                    content(item).aspectRatio(aspectRatio,contentMode: .fit)
                }
            }
        }
        
    }
    
    private func adaptiveGridItem(width: CGFloat) -> GridItem{
        var gridItem = GridItem(.adaptive(minimum: width))
        gridItem.spacing = 0
        return gridItem

    }
    
  private  func widthThatFits(itemCount: Int, in size:CGSize,itemAspecRatio:CGFloat) -> CGFloat{
        var columnCount = 1
        var rowCount = itemCount
        repeat{
            let itemWidth = size.width / CGFloat(columnCount)
            let itemHeight = itemWidth / itemAspecRatio
            if CGFloat(rowCount) * itemHeight < size.height{
                break
            }
            columnCount += 1
            rowCount = (itemCount + (columnCount - 1)) / columnCount
        } while columnCount < itemCount
        if columnCount > itemCount {
            columnCount = itemCount
        }
        return floor(size.width / CGFloat(columnCount))
    }
    
}

struct Cardify: AnimatableModifier{
    
    
    init(isFaceUp:Bool){
        rotation = isFaceUp ? 0 : 180
    }
    var animatableData: Double{
        get{rotation}
        set{rotation = newValue}
    }
    var rotation:Double
    
    func body(content: Content) -> some View {
        ZStack{
            
            let shape = RoundedRectangle(cornerRadius: DrawingConstant().cornerRadius)
            if rotation < 90 {
                
                shape.fill().foregroundColor(.white)
                shape.strokeBorder(lineWidth: DrawingConstant().lineWidth)
               
            }else {
                    
                    shape.fill()
                }
            content
                .opacity(rotation < 90 ? 1:0)
                
            }
        .rotation3DEffect(Angle.degrees(rotation), axis: (0, 1, 0))
        }
     
    }


extension View{
    
    func cardify(isFaceUp:Bool) -> some View{
        self.modifier(Cardify(isFaceUp: isFaceUp))
        
    }
}



