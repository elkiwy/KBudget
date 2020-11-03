//
//  NewTransactionView.swift
//  KBudget
//
//  Created by Stefano Bertoli on 07/10/20.
//

import SwiftUI



struct newTransactionButton:View{
    @Binding var bind:Bool
    
    private var totalFunc:([CDTransaction])->Float
    private var type:IncomeOrExpense
    private var col:ColorNames
    private var icon:String
    
    @ObservedObject var man:DataManager = DataManager.shared
    private let imageSize:CGFloat = 64
    @Environment(\.colorScheme) var cs

    
    init(type:IncomeOrExpense, bind:Binding<Bool>) {
        self.type = type
        _bind = bind
        if type == .expense{
            self.col = ColorNames.Red
            self.icon = "tray.and.arrow.up"
            self.totalFunc = getTodayExpenses
        }else{
            self.col = ColorNames.Green
            self.icon = "tray.and.arrow.down"
            self.totalFunc = getTodayIncomes
        }
    }
    
    var body: some View{
        HStack{
            //Left Summary
            VStack(alignment: .leading){
                Text("New \(type.rawValue)").font(.title).bold().padding(.bottom).foregroundColor(col.ToColor(theme: cs))
                Text("Today's \(type.rawValue)s:").font(.title3)
                Text("\(valWithCurr(abs((type == .expense ? -1 : 1) * totalFunc(man.transactions))))").font(.title).bold()
            }.padding()
            Spacer()
            
            //Button
            Button(action: {
                self.bind.toggle()
            }, label: {
                
                //Icon
                Image(systemName: icon)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(col.ToColor(theme: cs))
                    .aspectRatio(contentMode: .fit)
                    .frame(width: imageSize, height: imageSize)
                    .padding(16)
            })
            .buttonStyle(PlainButtonStyle())
        }
        .padding(4)
        .background(Color(white: 0.5, opacity: 0.1))
        .addBorder(col.ToColor(theme: cs), width: 1, cornerRadius: 20)
        .padding(4)
    }
}







struct MainView: View {
    @ObservedObject var man = DataManager.shared

    @State var newExpense:Bool = false
    @State var newIncome:Bool = false
    @State var infoAlertShown:Bool = false

    var body: some View {
        NavigationView{
            VStack(alignment:.center){
                //Total
                Text("Today's total").font(.title2)
                Text("\(valWithCurr(getTodayIncomes(data: man.transactions) + getTodayExpenses(data: man.transactions)))").font(.title).bold()
                    .padding(.bottom)
                Spacer()
                
                //Transactions count
                Text("Transactions count").font(.title2)
                Text("\(man.transactions.filter({ (t) -> Bool in return Calendar.current.isDateInToday(t.date!) }).count)").font(.title).bold()
                Spacer()
                
                //New Expense
                newTransactionButton(type: .expense, bind:self.$newExpense)
                    .sheet(isPresented: $newExpense) {NewTransactionView(type:.expense, bind:self.$newExpense)}
                Spacer()
                
                //New income
                newTransactionButton(type: .income, bind:self.$newIncome)
                    .sheet(isPresented: $newIncome) {NewTransactionView(type:.income, bind:self.$newIncome)}
                Spacer()
            }
            .toolbar(content: {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {self.infoAlertShown.toggle()}, label: {
                        Text("Info")
                    })
                }
            })
            //Delete alert
            .alert(isPresented: self.$infoAlertShown, content: {
                Alert(title: Text("Info"), message:Text("If you are reading this, you have probably just started using KBudget.\n\nTo register a new expense or income, tap the icons in the main view.\n\nTo create your custom categories go into the second page.\n\nTo review and analyse your data check third and fourth page."))
            })
            .padding()
            .navigationTitle("KBudget")
        }
    }
}














#if DEBUG
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().colorScheme(.dark)

        //TabView{
        //
        //    MainView().environment(\.managedObjectContext, DataManager.shared.context)
        //}.colorScheme(.dark)
    }
}
#endif
