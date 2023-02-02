//
//  ContentView.swift
//  MemorizeView
//
//  Created by Guru Mahan on 20/12/22.
//

import SwiftUI



struct EmojiCardView: View {
    
   
@ObservedObject var  viewModel = EmojiCardViewModel()
    @Namespace private var dealingNameSpace
   
    var body: some View {
    
        VStack{
            gameBody
            deckBody
            
                .padding()
            Spacer(minLength: 20)
            ZStack {
                VStack{
                    TextField("Enter card No", text: $viewModel.cardText, onEditingChanged: { status in
                        
                        print("onEditingChanged")
                    }, onCommit: {
                      
                        print("onCommit:\($viewModel.cardText)")
                    })
                    .onChange(of: viewModel.cardText, perform: { newValue in
                       
                    })
                    .frame(width: 60,height: 40)
                        
                    HStack{
                        restart
                        Spacer()
                        shuffle
                    }
                    .padding(.horizontal)
                
            }
//                HStack {
//
//                    Button {
//                        //viewModel.subractCard()
//                    } label: {
//                        Image(systemName: "minus.circle")
//                            .font(.largeTitle)
//
//                    }
//                    Spacer()
//                    Button {
//                        // viewModel.addCard()
//                    } label: {
//                        Image(systemName: "plus.circle")
//                            .font(.largeTitle)
//                    }
//                }
//                .padding(.horizontal)
            }
        }
    
   
    }
   
    var gameBody: some View {
        AspetVGrid(items: viewModel.cards, aspectRatio: 2/3) {card in
            if viewModel.isUndealt(card) || (card.isMatched && !card.isFaceUp){
                Color.clear
            }else{
                cardView(card:card)
                    .matchedGeometryEffect(id: card.id, in: dealingNameSpace)
                    .padding(4)
                  
                    .transition(AnyTransition.asymmetric(insertion:.identity, removal: .opacity))
                    .zIndex(viewModel.zIndex(of: card))
                    .onTapGesture {
                        withAnimation{
                            viewModel.choose(card)
                        }

                       
                    }
            }
            
        }
        .foregroundColor(.red)
    }
    var  deckBody: some View{
        ZStack{
            ForEach(viewModel.cards.filter(viewModel.isUndealt)){card in
                cardView(card: card)
                    .matchedGeometryEffect(id: card.id, in: dealingNameSpace)
                    .transition(AnyTransition.asymmetric(insertion: .opacity, removal: .identity))
            }
        }
        .frame(width: CardContants.undealtWidth,height: CardContants.undealtHeight)
        .foregroundColor(CardContants.color)
        .onTapGesture{
           
                for card in viewModel.cards{
                    withAnimation( viewModel.dealAnimation(for:card)){
                        viewModel.deal(card)
                }
            }
        }
    }
   
    var shuffle: some View{
        Button("shuffle"){
            withAnimation{
                viewModel.shuffle()
            }
           
        }
        .font(.largeTitle)

    }
    
    var restart: some View{
        Button("Restart"){
            withAnimation{
                viewModel.dealt = []
                viewModel.restart()
            }
        }
        .font(.largeTitle)
    }
    
    @State var animatedBonusRemaining: Double = 0
    
    struct cardView: View{
        let card: EmojiCardLoginModel<String>.Card
        
        var body: some View{
            
            VStack {
                GeometryReader{ geometry in
                    VStack{
                        ZStack{
                            Group{
                                if EmojiCardViewModel().isConsumingBonusTime{
                                    EmojiCardViewModel.Pie(startAngel: Angle(degrees: 0-90), endAngle: Angle(degrees: (1-EmojiCardView().animatedBonusRemaining)*360-90))
                                        .onAppear{
                                            EmojiCardView().animatedBonusRemaining = EmojiCardViewModel().bonusRemaining
                                            withAnimation(.linear(duration: EmojiCardViewModel().bonusTimeRemaining)){
                                                EmojiCardView().animatedBonusRemaining = 0
                                            }
                                        }
                                }else{
                                    EmojiCardViewModel.Pie(startAngel: Angle(degrees: 0-90), endAngle: Angle(degrees: (1-EmojiCardViewModel().bonusTimeRemaining)*360-90))
                                }
                                
                               
                            }
                                .padding(5).opacity(0.5)
                           
                            Text(card.content).rotationEffect(Angle(degrees: card.isMatched ? 360 : 0)).animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
                                .padding(5)
                                .font(Font.system(size: DrawingConstant().fontSize))
                                .scaleEffect(EmojiCardViewModel().scale(thatFits: geometry.size))
                        }
                        
                        .cardify(isFaceUp: card.isFaceUp)
                        Spacer()
                    }
                }
            }
        }
       
       
    }
    
@ViewBuilder var actionView: some View{
    
        Button {
            
        } label: {
            Text("add")
        }

    }
    
   
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiCardView()
    }
}

  
    
