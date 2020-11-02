//
//  CategoriesView.swift
//  KBudget
//
//  Created by Stefano Bertoli on 12/10/20.
//

import SwiftUI








struct CategoryCell:View{
    //States
    @ObservedObject var cat:CDCategory
    @State private var expanded:Bool = false
    @State private var showingEditSheet = false
    @State private var showingActionSheet = false
    @State private var deleteAlertShown = false

    //Constants
    private var days:Int = -1
    @Environment(\.colorScheme) var cs
    private let iconSize:CGFloat = 30
    private let df: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd MMM yyyy - HH:mm"
        return f
    }()
    
    //Init
    init(cat:CDCategory, period:Int) {
        self.cat = cat
        self.days = period
    }
    
    @ViewBuilder
    var body: some View{
        if cat.id == nil {
            EmptyView()
        }else{
            Button(action: {
                //Empty here, moved to onTapGesture to work with long press
            }, label: {
                VStack{
                    //Main cell
                    HStack{
                        //Icon
                        Image(systemName: cat.icon ?? "")
                            .resizable()
                            .renderingMode(.template)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: iconSize, height: iconSize)
                            .foregroundColor(ColorNames(rawValue: cat.color!)!.ToColor(theme: cs))
                        
                        //Category name
                        Text(cat.name!).font(.title2).bold().foregroundColor(ColorNames(rawValue: cat.color!)!.ToColor(theme: cs))
                        Spacer()
                        
                        //Total value
                        Text("\(valWithCurr(self.cat.getNetTotal(lastNDays: self.days)))").font(.title2).bold()
                    }
                    
                    //Expanded transactions detail
                    if self.expanded{
                        ForEach(cat.getTransactionsOfLastNDays(days), id:\.id){ t in
                            HStack{
                                //Note and Date
                                VStack(alignment:.leading){
                                    Text(t.note ?? "").font(.headline)
                                    Text(df.string(from: t.date!)).font(.subheadline)
                                }
                                Spacer()
                                
                                //Single transaction Value
                                Text("\(valWithCurr(t.value))")
                            }.padding(.vertical, 2)
                        }
                    }
                }
                .padding(12)
                .background(Color(white: 0.5, opacity: 0.1))
                .addBorder(ColorNames(rawValue: cat.color!)!.ToColor(theme: cs), width: 1, cornerRadius: 20)
                .padding(.horizontal, 16)
                .padding(.vertical, 1)
                .onTapGesture(count: 1, perform: {
                    //Expand transactions action
                    withAnimation(Animation.easeInOut(duration: 0.25)) {
                        if cat.getTransactionsOfLastNDays(days).count == 0{
                            self.expanded = false
                        }else{
                            self.expanded.toggle()
                        }
                    }
                })
                .onLongPressGesture(minimumDuration: 0.5) {self.showingActionSheet.toggle()}
            })
            .buttonStyle(PlainButtonStyle())
            
            //Edit category sheet
            .sheet(isPresented: self.$showingEditSheet, content: {
                NewCategoryView(bind:self.$showingEditSheet, existingCategory:self.cat)
            })
            
            //Edit/delete action sheet
            .actionSheet(isPresented: $showingActionSheet) {
                ActionSheet(title: Text("\(cat.name!)"), buttons: [
                    ActionSheet.Button.default(Text("Edit Category"), action: {self.showingEditSheet.toggle()}),
                    ActionSheet.Button.destructive(Text("Delete category"), action: {self.deleteAlertShown.toggle()}),
                    ActionSheet.Button.cancel()
                ])
            }
            
            //Delete alert
            .alert(isPresented: self.$deleteAlertShown, content: {
                Alert(title: Text("Are you sure you want to delete this category and all its transactions?"), message: Text("This action is permanent and cannot be reversed."),
                      primaryButton: Alert.Button.destructive(Text("Yes"), action: {
                        DataManager.shared.deleteCategory(cat: cat)
                      }), secondaryButton: Alert.Button.default(Text("No")))
            })
        }
        
    }
}





struct CategoriesView: View {
    //States
    @ObservedObject var man = DataManager.shared
    @State private var newCategorySheet = false
    @State private var selectedPeriod = 1
    
    //Constants
    @Environment(\.colorScheme) var cs
    private let periods = [(1, "1 day"),(7, "7 days"),(30, "30 days"),(365, "1 year")]

    var body: some View {
        NavigationView{
            ScrollView{
                VStack{
                    //Period selector
                    Picker(selection: self.$selectedPeriod, label: Text("Picker"), content: {
                        Text(periods[0].1).tag(0)
                        Text(periods[1].1).tag(1)
                        Text(periods[2].1).tag(2)
                        Text(periods[3].1).tag(3)
                    })
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 48)
                    .padding(.vertical, 16)
                    
                    //Categories
                    ForEach(man.categories){cat in
                        CategoryCell(cat: cat, period: periods[self.selectedPeriod].0)
                    }
                    
                    //New category button
                    Button(action:{
                        self.newCategorySheet = true
                    }){
                        Text("Add new Category")
                            .font(.headline)
                            .frame(maxWidth:.infinity, minHeight: 60)
                            .background(Color(white: 0.5, opacity: 0.1))
                            .addBorder(ColorNames.foregroundColor(theme:cs), width: 1, cornerRadius: 20)
                            .padding(.vertical,64)
                            .padding(.horizontal)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .sheet(isPresented: self.$newCategorySheet, content: {
                        NewCategoryView(bind:self.$newCategorySheet)
                    })
                }
            }
            .navigationTitle("Categories")
        }
    }
}




#if DEBUG
struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesView().colorScheme(.dark)
    }
}
#endif
