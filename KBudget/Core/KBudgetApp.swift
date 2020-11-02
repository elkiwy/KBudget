//
//  KBudgetApp.swift
//  KBudget
//
//  Created by Stefano Bertoli on 07/10/20.
//

import SwiftUI

var fgCol = Color(UIColor.white)
var bgCol = Color(UIColor.systemBackground)

@main
struct KBudgetApp: App {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some Scene {
        //Force init datamanager first
        let dataManager = DataManager.shared
        
        return WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataManager.context)
        }
    }
}



struct ContentView: View {
    @Environment(\.colorScheme) var cs
    
    var body: some View {
        TabView{
            MainView()
            .tabItem {
                VStack {
                    Image(systemName: "square.and.pencil")
                    Text("New")
                }
            }
            .tag(0)
            
            CategoriesView()
            .tabItem {
                VStack {
                    Image(systemName: "folder")
                    Text("Categories")
                }
            }
            .tag(1)
            
            HistoryView()
            .tabItem {
                VStack {
                    Image(systemName: "calendar")
                    Text("History")
                }
            }
            .tag(1)
            
            LogView()
            .tabItem {
                VStack {
                    Image(systemName: "list.bullet")
                    Text("Log")
                }
            }
            .tag(2)
        }
        .accentColor(ColorNames.foregroundColor(theme: cs))
    }
}








struct test: View {
    var c:Color
    var body: some View {
        Text("   ").padding(32).background(c)
    }
}


struct App_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().colorScheme(.dark)

    }
}
