//
//  NewCategoryView.swift
//  KBudget
//
//  Created by Stefano Bertoli on 12/10/20.
//

import SwiftUI

struct ColorSelector: View{
    @Binding var colorBind:String
    
    @Environment(\.colorScheme) var cs
    private let columns = [GridItem(.adaptive(minimum: 60))]
    private let circleSize:CGFloat = 50
    
    var body: some View{
        LazyVGrid(columns:columns){
            ForEach(ColorNames.allCases, id:\.rawValue){col in
                Circle()
                    .frame(width: circleSize, height: circleSize)
                    .foregroundColor(col.ToColor(theme:cs))
                    .addBorder(col.rawValue == colorBind ? ColorNames.foregroundColor(theme: cs) : .gray, width: col.rawValue == colorBind ? 5 : 1, cornerRadius: circleSize/2)
                    .onTapGesture(count: 1, perform: {
                        withAnimation(Animation.easeInOut(duration: 0.4)) {
                            self.colorBind = col.rawValue
                        }
                    })
            }
        }
        .padding()
    }
}






struct IconSelector: View{
    @Binding var iconBind:String
    @Binding var colorBind:String
    
    @Environment(\.colorScheme) var cs
    private let columns = [GridItem(.adaptive(minimum: 60))]
    private let circleSize:CGFloat = 50
    
    var body: some View{
        LazyVGrid(columns:columns){
            ForEach(IconNames.allCases, id:\.rawValue){icon in
                Image(systemName: icon.rawValue)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(0.5)
                    .opacity(icon.rawValue == iconBind ? 1 : 0.5)
                    .frame(width: circleSize, height: circleSize)
                    .addBorder(icon.rawValue == iconBind ? Color.white : .gray, width: icon.rawValue == iconBind ? 3 : 0, cornerRadius: circleSize/2)
                    .colorMultiply(icon.rawValue == iconBind ? ColorNames(rawValue: colorBind)!.ToColor(theme:cs) : .white)
                    .onTapGesture(count: 1, perform: {
                        withAnimation(Animation.easeInOut(duration: 0.4)) {
                            self.iconBind = icon.rawValue
                        }
                    })
            }
        }
        .padding()
    }
}





struct NewCategoryView: View {
    @Binding var bind:Bool
    var existingCategory:CDCategory? = nil
    
    @State private var name:String = ""
    @State private var color:String = ColorNames.allCases[0].rawValue
    @State private var icon:String = IconNames.allCases[0].rawValue

    @State private var nameAlertShown:Bool = false
    @Environment(\.colorScheme) var cs
    
    init(bind:Binding<Bool>, existingCategory:CDCategory? = nil) {
        _bind = bind
        self.existingCategory = existingCategory
        
        if let c = existingCategory{
            _name = State(initialValue: c.name!)
            _color = State(initialValue: c.color!)
            _icon = State(initialValue: c.icon!)
        }
    }
    
    var body: some View {
        NavigationView{
            ScrollView{
                VStack(alignment:.leading){
                    
                    //Note text field
                    Text("Name:").font(.title2).bold().padding(.top, 32).padding(.horizontal)
                    TextField("My Category", text: self.$name)
                        .font(.title)
                        .frame(maxWidth:.infinity, maxHeight:64)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 16)
                    
                    Text("Color:").font(.title2).bold().padding(.horizontal)
                    ColorSelector(colorBind: self.$color)

                    Text("Icon:").font(.title2).bold().padding(.horizontal)
                    IconSelector(iconBind: self.$icon, colorBind: self.$color)

                    
                    
                    //Save button
                    Button(action: {
                        if self.name.isEmpty {
                            self.nameAlertShown = true
                        }else{
                            if self.existingCategory == nil{
                                DataManager.shared.addCategory(name: self.name, color: self.color, icon: self.icon)
                            }else{
                                self.existingCategory?.name = self.name
                                self.existingCategory?.color = self.color
                                self.existingCategory?.icon = self.icon
                                do{ try DataManager.shared.context.save()
                                    DataManager.shared.forceRefresh()
                                }catch{print("CD ERROR: failed to sync updated category information")}
                            }
                            self.bind.toggle()
                        }
                    }){
                        Text("Save")
                            .font(.headline)
                            .frame(maxWidth:.infinity, minHeight:64)
                            .background(ColorNames(rawValue: self.color)!.ToColor(theme:cs))
                            .cornerRadius(10)
                            .foregroundColor(bgCol)
                    }
                    .padding()
                    .buttonStyle(PlainButtonStyle())
                }
                .alert(isPresented: self.$nameAlertShown, content: {
                    Alert(title: Text("Warning"), message: Text("Please insert a name for this category"), dismissButton: .default(Text("Ok")))
                })
                .navigationTitle(self.existingCategory == nil ? "New Category" : "Edit Category")
            }
        }
    }
}








#if DEBUG
struct NewCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            NewCategoryView(bind: .constant(true)).colorScheme(.dark)
            NewCategoryView(bind: .constant(true))
        }
    }
}
#endif
