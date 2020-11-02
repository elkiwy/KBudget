//
//  CalendarView.swift
//  KHabit
//
//  Created by Stefano Bertoli on 29/06/2020.
//  Copyright © 2020 elkiwy. All rights reserved.
//

import SwiftUI


struct Arc: Shape {
    var startAngle: Double
    var endAngle: Double
    var clockwise: Bool
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2, startAngle: .degrees(startAngle), endAngle: .degrees(endAngle), clockwise: clockwise)
        return path
    }
    var animatableData: AnimatablePair<Double, Double> {
        get { return AnimatablePair(startAngle, endAngle) }
        set { startAngle = newValue.first; endAngle = newValue.second }
    }
}



struct CalendarHeader: View{
    var name: String
    var body: some View{
        Text(self.name).frame(maxWidth: .infinity, maxHeight: 32).font(.headline)
    }
}





struct CalendarCell: View{
    //Logic
    @State var value:Float = 0
    @Binding var selectedDate:Date
    var date: Date
    @Binding var updater:String?
    var month:Int

    //Theme
    @Environment(\.colorScheme) var cs
    
    //Animation stuff
    @State var animValue: Double = 0.0
    @State var startAngle: Double = 0
    var animation = Animation.easeInOut(duration: 1)

    var dateInCurrentMonth:Bool = true
    
    ///Init
    init(updater:Binding<String?>, date:Date, selectedDate:Binding<Date>, month:Int) {
        _selectedDate = selectedDate
        self.date = date
        self.month = month
        _updater = updater
        self.dateInCurrentMonth = Calendar.current.component(.month, from: self.date) == self.month

    }
    
    func f(_ d:Date)->String{
        let df = DateFormatter()
        df.dateFormat = "dd - MM"
        return df.string(from: d)
    }
    
    ///Body
    var body: some View{
        //Listen for updates on selectedDate and updates the animation
        let _ = Binding<Bool>(get: { () -> Bool in
            let selected = Calendar.current.isDate(self.selectedDate, inSameDayAs: self.date)
            DispatchQueue.main.async {
                withAnimation(animation){
                    self.animValue = selected ? 360 : 0
                    self.startAngle = selected ? 180 : 0
                }
                self.value = DataManager.shared.getValueOfDay(date)
            }
            return selected
        }) { (sel) in }
                
        //Check if i'm in the correct month or i'm an outsider
        //let dateInCurrentMonth = Calendar.current.component(.month, from: self.date) == self.month
        //print("Update of \(self.date) \(dateInCurrentMonth)")
        
        //Actual body
        return Button(action: {
            withAnimation(Animation.easeInOut(duration: 0.25)){
                self.selectedDate = self.date
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }) {
            VStack{
                Text("\(Calendar.current.component(.day, from: self.date))").font(.headline)
                Text("\(valWithCurr(self.value, withDecimals: false))").font(.caption)
                    .opacity(self.value == 0 ? 0 : 1)
            }
            .opacity(dateInCurrentMonth ? 1 : 0.25)
        }
        .buttonStyle(PlainButtonStyle())
        .frame(height: 48)
        .frame(maxWidth: .infinity)
        .overlay(
            Arc(startAngle: self.startAngle, endAngle: self.startAngle + self.animValue, clockwise: false)
                .stroke(ColorNames.Gray.ToColor(theme: cs), lineWidth: 2)
        )
        .onAppear(perform: {
            self.value = DataManager.shared.getValueOfDay(self.date)
        })

    }
}




let h24:TimeInterval = 24*60*60
let d7:TimeInterval = h24*7
struct CalendarView: View {
    @State var date:Date
    @State private var firstOfTheMonth:Date!
    @State private var startingDate:Date!
    @State private var monthName:String!
    @Binding var selectedDate:Date

    init(date:Date, selectedDate:Binding<Date>) {
        _selectedDate = selectedDate
        _date = State(initialValue: date)
        let comps = Calendar.current.dateComponents([.month, .year], from: self.date)
        _firstOfTheMonth = State(initialValue: Calendar.current.date(from: comps))
        let weekday = Calendar.current.component(.weekday, from: self.firstOfTheMonth)
        let offset:TimeInterval = Double((weekday + 7 - 2) % 7) * h24 * -1
        _startingDate = State(initialValue: self.firstOfTheMonth.addingTimeInterval(offset))
        let df = DateFormatter(); df.dateFormat = "LLLL"
        _monthName = State(initialValue: df.string(from: self.date))
    }
    
    func update(){
        let comps = Calendar.current.dateComponents([.month, .year], from: self.date)
        self.firstOfTheMonth = Calendar.current.date(from: comps)
        let weekday = Calendar.current.component(.weekday, from: self.firstOfTheMonth)
        let offset:TimeInterval = Double((weekday + 7 - 2) % 7) * h24 * -1
        self.startingDate = self.firstOfTheMonth.addingTimeInterval(offset)
        let df = DateFormatter()
        df.dateFormat = "LLLL"
        self.monthName = df.string(from: self.date)
        
        let tmp = self.selectedDate
        self.selectedDate = Date.distantFuture
        self.selectedDate = tmp
    }
    

    var body: some View {
        VStack{
            HStack{
                Button(action: {
                    //withAnimation(.easeInOut(duration:0.25)){
                        self.date = Calendar.current.date(byAdding: .month, value: -1, to: self.date)!
                        self.update()
                    //}
                }) {
                    Image(systemName: "chevron.left")
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width:32, height: 32)
                        .foregroundColor(fgCol)
                }
                Spacer()
                Text(monthName + " " + String(Calendar.current.component(.year, from: self.date))).font(.title)
                Spacer()
                Button(action: {
                    //withAnimation(.easeInOut(duration:0.25)){
                        self.date = Calendar.current.date(byAdding: .month, value: 1, to: self.date)!
                        self.update()
                    //}
                }) {
                    Image(systemName: "chevron.right")
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width:32, height: 32)
                        .foregroundColor(fgCol)
                }
            }
            .padding()
            HStack(spacing:0){
                CalendarHeader(name:"Mon")
                CalendarHeader(name:"Tue")
                CalendarHeader(name:"Wed")
                CalendarHeader(name:"Thu")
                CalendarHeader(name:"Fri")
                CalendarHeader(name:"Sat")
                CalendarHeader(name:"Sun")
            }
            ForEach(Range(0...5)){ i in
                HStack(spacing:0){
                    ForEach(Range(0...6)){j in
                        CalendarCell(updater: self.$monthName,
                                     date: self.startingDate.addingTimeInterval(d7*Double(i) + h24 * Double(j)),
                                     selectedDate: self.$selectedDate,
                                     month: Calendar.current.component(.month, from: self.date))
                    }
                }
            }
        }
        .gesture(
            DragGesture(minimumDistance: 50, coordinateSpace: .global)
                .onChanged({ (v) in
                    print(v.translation.width)
                })
                .onEnded({ (v) in
                    if (v.translation.width > 0){
                        self.date = Calendar.current.date(byAdding: .month, value: -1, to: self.date)!
                    }else{
                        self.date = Calendar.current.date(byAdding: .month, value:  1, to: self.date)!
                    }
                    self.update()
                })
        )
    }
}




///Main view
struct HistoryView: View {
    //States
    @State var selectedDate:Date = Date()
    @ObservedObject private var man = DataManager.shared

    @Environment(\.colorScheme) var cs
    private let df: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd MMM yyyy - HH:mm"
        return f
    }()
    
    
    var body: some View {
        NavigationView{
            ScrollView{
                VStack{
                    //Calendar
                    CalendarView(date: Date(), selectedDate: self.$selectedDate)
                    
                    
                    ForEach(man.getTransactionsOfDay(selectedDate), id:\.id){ t in
                        HStack{
                            Image(systemName: t.category!.icon!)
                                .renderingMode(.template)
                                .foregroundColor(ColorNames(rawValue: t.category!.color!)!.ToColor(theme:cs))
                            
                            VStack(alignment:.leading){
                                Text(t.note ?? "").font(.headline)
                                Text(df.string(from: t.date!)).font(.subheadline)
                            }
                            
                            Spacer()
                            Text("\(valWithCurr(t.value))").font(.title2).bold()
                        }.padding(.vertical, 2)
                    }
                }
            }
            .padding(.horizontal)

            .listStyle(PlainListStyle())
            
            //View title
            .navigationBarTitle("History")            
        }
    }
}




#if DEBUG
struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            HistoryView()
        }.colorScheme(.dark)
    }
}
#endif


