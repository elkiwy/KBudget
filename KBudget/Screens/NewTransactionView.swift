//
//  NewTransactionView.swift
//  KBudget
//
//  Created by Stefano Bertoli on 12/10/20.
//

import SwiftUI



struct CategoryListView:View{
    @Binding var bind:CDCategory
    
    @ObservedObject private var man = DataManager.shared
    private let boldFont = Font.system(size: 20, weight: .bold)
    private let normFont = Font.system(size: 20, weight: .regular)
    @Environment(\.colorScheme) var cs

    
    init(bind:Binding<CDCategory>) {
        _bind = bind
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
        UITableView.appearance().tableFooterView = UIView()
    }
    
    var body: some View{
        VStack{
            //Section header
            HStack{Text("Categories").font(.title2).padding(.leading);Spacer()}.padding()
            
            //Categories
            VStack{
                ForEach(man.categories){ cat in
                    //Cell
                    HStack{
                        //Icon
                        Image(systemName: cat.icon!)
                            .renderingMode(.template)
                            .foregroundColor(ColorNames(rawValue: cat.color!)!.ToColor(theme:cs))
                            .padding(.trailing, 8)
                            .offset(x: -4)
                        
                        //Category name
                        Text(cat.name!)
                            .font(cat.id == self.bind.id ? boldFont : normFont)
                            .foregroundColor(ColorNames(rawValue: cat.color!)!.ToColor(theme:cs))
                            .opacity(cat.id == self.bind.id ? 1 : 0.5)
                        
                        //Checkmark
                        Spacer()
                        Image(systemName:"checkmark")
                            .opacity(cat.id == self.bind.id ? 1 : 0)
                    }
                    .padding(12)
                    .padding(.horizontal, 16)
                    .background(Color(white: 0.5, opacity:  cat.id == self.bind.id ? 0.1 : 0))
                    .cornerRadius(16)
                    .contentShape(Rectangle())
                    .onTapGesture(count: 1, perform: {
                        self.bind = cat
                    })
                }
            }
            .padding(8)
            .background(Color(white: 0.5, opacity: 0.15))
            .cornerRadius(20)
            .padding(.horizontal)
            .zIndex(-1)
            .offset(y:-16)
            //        .listStyle(InsetGroupedListStyle())
        }
    }
}



struct NewTransactionView:View {
    @ObservedObject var man = DataManager.shared
    
    var type:IncomeOrExpense
    @Binding var bind:Bool
    
    @State private var note:String = ""
    @State private var value:String = ""
    @State private var valueFocussed:Bool? = true
    @State private var catSelected:CDCategory = DataManager.shared.categories.first!
    @State private var withUnderline = false
    @Environment(\.colorScheme) var cs

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    
    var body: some View{
        NavigationView{
            ScrollView{
                VStack{
                    //Value
                    ZStack{
                        CustomTextField(text: self.$value, isResponder: self.$valueFocussed)
                            .frame(height:140)
                            .opacity(0)
                        
                        Text("\(valWithCurr((Float(self.value) ?? 0)/100))")
                            .font(.system(size: 72))
                            .underline(self.valueFocussed!)
                            .opacity(self.valueFocussed! && withUnderline ? 1 : 0.8)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                            .allowsTightening(true)
                            .onTapGesture(perform: {
                                self.valueFocussed = true
                            })
                    }
                    .frame(height: 140)
                    
                    //Note text field
                    TextField("Note", text: self.$note)
                        .font(.title)
                        .multilineTextAlignment(.center)
                    
                    //Categories
                    CategoryListView(bind:self.$catSelected)
                    
                    //Save button
                    Button(action: {
                        let v = (type == .expense ? -1 : 1) * (Float(self.value) ?? 0)/100
                        man.addTransaction(value: v, note: self.note, category: self.catSelected)
                        self.bind.toggle()
                    }){
                        Text("Save \(type.rawValue)")
                            .font(.headline)
                            .frame(maxWidth:.infinity, minHeight:64)
                            .background(type == .income ? ColorNames.Green.ToColor(theme:cs) : ColorNames.Red.ToColor(theme:cs))
                            .cornerRadius(10)
                            .foregroundColor(Color.black)
                    }
                    .padding()
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                }
            }
            .toolbar(content: {
                ToolbarItem(placement: .primaryAction) {
                    Button("Cancel") {
                        self.bind.toggle()
                    }
                }
            })
            .navigationTitle("New \(type.rawValue)")
            .onReceive(timer) { time in
                withAnimation(Animation.easeInOut(duration: 0.25)){
                    if Calendar.current.component(.second, from: time) % 2 == 0{
                        self.withUnderline.toggle()
                    }
                }
            }
        }
    }
}






#if DEBUG
struct NewTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            NewTransactionView(type: .expense, bind: Binding.constant(true))
        }.colorScheme(.dark)
    }
}
#endif
