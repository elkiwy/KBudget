//
//  LogView.swift
//  KBudget
//
//  Created by Stefano Bertoli on 07/10/20.
//

import SwiftUI
import CoreData

enum LogPeriod:String, CaseIterable {
    case days   = "days"
    case weeks  = "weeks"
    case months = "months"
    case years  = "years"
    
    static func withTag(_ t:Int)->LogPeriod{
        switch t {
        case 0: return .days
        case 1: return .weeks
        case 2: return .months
        case 3: return .years
        default: return .days
        }
    }
    
    func groupTitleFromDate(_ d:Date)->String{
        let df = DateFormatter()
        if self == .years{
            return "Year \(Calendar.current.component(.year, from: d))"
            
        }else if self == .months{
            df.dateFormat = "MMMM yyyy"
            return df.string(from: d)
            
        }else if self == .weeks{
            df.dateFormat = "dd/MM/yy"
            let c = Calendar.current.dateComponents([.weekOfYear, .day, .month, .year], from: d)
            let mon = Calendar.current.date(from: DateComponents(year: c.year, month: c.month, weekday: 2, weekOfYear: c.weekOfYear))!
            let sun = Calendar.current.date(from: DateComponents(year: c.year, month: c.month, weekday: 1, weekOfYear: c.weekOfYear!+1))!
            return "\(df.string(from: mon)) - \(df.string(from: sun))"
            
        }else if self == .days{
            df.dateFormat = "EEE, d MMM yyyy"
            return df.string(from: d)

        }else{
            return "Error"
        }
    }
}


struct LogGroup{
    var title:String
    var transactions:[CDTransaction]
}


struct LogCell:View{
    @Environment(\.colorScheme) var cs

    var group:LogGroup
    @State private var expanded:Bool = false
    private let df: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd MMM yyyy - HH:mm"
        return f
    }()

    @ViewBuilder
    var body: some View{
        Button(action: {
            withAnimation(Animation.easeInOut(duration: 0.25)){
                if self.group.transactions.count>0{
                    self.expanded.toggle()
                }
            }
        }, label: {
            VStack{
                //Normal cell header
                HStack{
                    Text(group.title)
                        .font(Font.body.monospacedDigit())
                    Spacer()
                    Text("\(valWithCurr(group.transactions.reduce(0, { (curr, next) -> Float in return curr+next.value})))")
                        .font(.title3).bold()
                }
                
                //Expanded details
                if self.expanded{
                    ForEach(group.transactions){ t in
                        HStack{
                            //Note and Date
                            VStack(alignment:.leading){
                                Text(t.note ?? "")
                                    .font(.headline)
                                    .foregroundColor(ColorNames(rawValue: t.category!.color!)!.ToColor(theme: cs))

                                Text(df.string(from: t.date!)).font(.subheadline)
                            }
                            Spacer()
                            
                            //Single transaction Value
                            Text("\(valWithCurr(t.value))")
                                .foregroundColor(ColorNames(rawValue: t.category!.color!)!.ToColor(theme: cs))
                        }.padding(.vertical, 2)
                    }
                }
            }
            .padding()
            .background(Color(white: 0.5, opacity: 0.1))
            .addBorder(Color(white: 0.5, opacity: 0.5), width: 1, cornerRadius: 10)
            .cornerRadius(10)
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        })
        .buttonStyle(PlainButtonStyle())
        
    }
}

struct LogView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var dataManager = DataManager.shared
    @Environment(\.colorScheme) var cs

    private let df: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd MMM yyyy - HH:mm"
        return f
    }()
    
    @State private var selectedPeriod = 1
    @State private var groups:[LogGroup] = []
    
    func updateGroups(withPeriod p:LogPeriod, data:[CDTransaction])->[LogGroup]{
        var dic:[String:[CDTransaction]] = [:]
        for t in data{
            let id = p.groupTitleFromDate(t.date!)
            var transactions = dic[id] ?? []
            transactions.append(t)
            dic[id] = transactions}
        var updatedGroups:[LogGroup] = []
        for grp in zip(dic.keys, dic.values){
            let g = LogGroup(title: grp.0, transactions: grp.1)
            updatedGroups.append(g)}
        updatedGroups.sort { (a, b) -> Bool in
            return a.transactions.first!.date! < b.transactions.first!.date!
        }
        return updatedGroups
    }
    
    
    
    init() {
        _groups = State(initialValue: self.updateGroups(withPeriod: LogPeriod.withTag(self.selectedPeriod), data: dataManager.transactions))
    }
    
    
    
    var body: some View {
        let bind = Binding<Int> { () -> Int in
            return self.selectedPeriod
        } set: {
            self.selectedPeriod = $0
            self.groups = updateGroups(withPeriod: LogPeriod.withTag($0) , data: dataManager.transactions)
        }

        return NavigationView{
            ScrollView{
                VStack{
                    //Period selector
                    Picker(selection: bind, label: Text("Picker"), content: {
                        Text(LogPeriod.days.rawValue).tag(0)
                        Text(LogPeriod.weeks.rawValue).tag(1)
                        Text(LogPeriod.months.rawValue).tag(2)
                        Text(LogPeriod.years.rawValue).tag(3)
                    })
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 48)
                    .padding(.vertical, 16)
                    
                    //Group list
                    ForEach(self.groups, id:\.title){ g in
                        LogCell(group: g)
                    }
                }
            }
            .navigationTitle("Log")
        }
    }
}


struct LogView_Previews: PreviewProvider {
    static var previews: some View {
        
        LogView().environment(\.managedObjectContext, DataManager.shared.context).colorScheme(.dark)
    }
}
