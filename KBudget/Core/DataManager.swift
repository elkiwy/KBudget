//
//  DataManager.swift
//  KBudget
//
//  Created by Stefano Bertoli on 07/10/20.
//

import Foundation
import UIKit
import CoreData
import SwiftUI
import Combine



var currency = "€"
func valWithCurr(_ v:Float, withDecimals:Bool = true)->String{
    return String(format: (withDecimals ? "%.2f" : "%.0f"), v) + " " + currency
}

func getTodayIncomes(data: [CDTransaction])->Float{
    let todays = data.filter { (t) -> Bool in return Calendar.current.isDateInToday(t.date!)}
    return todays.reduce(0) { (curr, next) -> Float in return curr + (next.value > 0 ? next.value : 0)}
}

func getTodayExpenses(data: [CDTransaction])->Float{
    let todays = data.filter { (t) -> Bool in return Calendar.current.isDateInToday(t.date!)}
    return todays.reduce(0) { (curr, next) -> Float in return curr + (next.value < 0 ? next.value : 0)}
}



enum IncomeOrExpense: String {
    case income = "income"
    case expense = "expense"
}



enum ColorNames:String, CaseIterable{
    case Gray = "Gray"
    case Blue = "Blue"
    case Green = "Green"
    case Indigo = "Indigo"
    case Orange = "Orange"
    case Pink = "Pink"
    case Purple = "Purple"
    case Red = "Red"
    case Teal = "Teal"
    case Yellow = "Yellow"
    
    static func foregroundColor(theme:ColorScheme)->Color{
        return theme == .dark ? Color.white : Color.black
    }

    static func backgroundColor(theme:ColorScheme)->Color{
        return theme == .light ? Color.white : Color.black
    }

    
    func ToColor(theme:ColorScheme)->Color{
        var c = UIColor.systemGray
        switch self {
        case .Gray:   c = UIColor.systemGray;break;
        case .Blue:   c = UIColor.systemBlue;break;
        case .Green:  c = UIColor.systemGreen;break;
        case .Indigo: c = UIColor.systemIndigo;break;
        case .Orange: c = UIColor.systemOrange;break;
        case .Pink:   c = UIColor.systemPink;break;
        case .Purple: c = UIColor.systemPurple;break;
        case .Red:    c = UIColor.systemRed;break;
        case .Teal:   c = UIColor.systemTeal;break;
        case .Yellow: c = UIColor.systemYellow;break;
        }
        
        if (theme == .dark){
            return Color(c.modified(sat: -0.25, bri: 0.3))
        }else{
            return Color(c.modified(sat: 0.05, bri: -0.15))
        }
    }
}

enum IconNames:String, CaseIterable{
    case pencil = "pencil"
    case trash = "trash"
    case paperplane = "paperplane"
    case doc = "doc"
    case calendar = "calendar"
    case book = "book"
    case rosette = "rosette"
    case person = "person"
    case person2 = "person.2"
    case globe = "globe"
    case sparkles = "sparkles"
    case keyboard = "keyboard"
    case exclamationmark = "exclamationmark.triangle"
    case speaker = "speaker.2"
    case note = "music.note"
    case heart = "heart"
    case bolt = "bolt"
    case phone = "phone"
    case envelope = "envelope"
    case bag = "bag"
    case cart = "cart"
    case house = "house"
    case tv = "tv"
    case car = "car"
    case hare = "hare"
    case sportscourt = "sportscourt"
    case gamecontroller = "gamecontroller"
}








///Main class for handling data
class DataManager:ObservableObject{
    let objectWillChange = ObservableObjectPublisher()

    ///Singleton shared instance
    static let shared = DataManager()
    var container:NSPersistentCloudKitContainer! = nil
    var context:NSManagedObjectContext! = nil

    ///Main tasks categories
    @Published var categories:[CDCategory] = []
    
    ///Main transactions categories
    @Published var transactions:[CDTransaction] = []
    
    ///Singleton private initializer
    private init() {
        print("Init DataManager")
        self.container = NSPersistentCloudKitContainer(name: "KBudget")
        self.context = self.container.viewContext
        
        //Load the container
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {fatalError("Unresolved error \(error), \(error.userInfo)")}
        })
        
        //Setup context to automatically updates itself when it sees a change
        container.viewContext.automaticallyMergesChangesFromParent = true

        //Load data
        do{ self.categories = try container.viewContext.fetch(CDCategory.fetchRequest())
            print("CD: Loaded \(self.categories.count) categories")
        }catch{print("CD ERROR: can't load categories")}
        do{ self.transactions = try container.viewContext.fetch(CDTransaction.fetchRequest())
            print("CD: Loaded \(self.transactions.count) transactions")
        }catch{print("CD ERROR: can't load transactions")}

        //Create the default category if i don't have any
        if self.categories.isEmpty{
            let defaultCategory = CDCategory(context: self.context)
            defaultCategory.id = UUID().uuidString
            defaultCategory.name = "Default"
            defaultCategory.color = ColorNames.Gray.rawValue
            defaultCategory.icon = IconNames.note.rawValue
            self.categories = [defaultCategory]
            do{try self.context.save();print("CD: Created default category")}catch{print("CD ERROR: couldn't save default category")}
        }
        
        print("CD STATUS: setup completed")
        
        
        #if targetEnvironment(simulator)
        self.loadTestData()
        #endif
    }

    
    
    
    func forceRefresh(){
        self.objectWillChange.send()
    }
    
    
    
    
    ///Special extra instance to handle previews
    func loadTestData(){
        let newCat0 = CDCategory(context: self.context)
        newCat0.id = "Cat0"
        newCat0.name = "Empty"
        newCat0.color = ColorNames.Blue.rawValue
        newCat0.icon = IconNames.globe.rawValue
        
        let newCat1 = CDCategory(context: self.context)
        newCat1.id = "Cat1"
        newCat1.name = "Income"
        newCat1.color = ColorNames.Green.rawValue
        newCat1.icon = IconNames.car.rawValue
        
        let newCat2 = CDCategory(context: self.context)
        newCat2.id = "Cat2"
        newCat2.name = "Food"
        newCat2.color = ColorNames.Yellow.rawValue
        newCat2.icon = IconNames.trash.rawValue
        
        let newTran1 = CDTransaction(context: self.context)
        newTran1.id = "Tran1"
        newTran1.category = newCat2
        newTran1.value = -24.99
        newTran1.date = Date()
        newTran1.note = "Giapponese"
        
        let newTran2 = CDTransaction(context: self.context)
        newTran2.id = "Tran2"
        newTran2.category = newCat2
        newTran2.value = -100
        newTran2.date = Date().addingTimeInterval(-2*24*60*60)
        newTran2.note = "Spesa"
        
        let newTran3 = CDTransaction(context: self.context)
        newTran3.id = "Tran3"
        newTran3.category = newCat1
        newTran3.value = 1300
        newTran3.date = Date().addingTimeInterval(-200*24*60*60)
        newTran3.note = "Stipendio"
        
        let newTran4 = CDTransaction(context: self.context)
        newTran4.id = "Tran4"
        newTran4.category = newCat2
        newTran4.value = -4.99
        newTran4.date = Date().addingTimeInterval(-60*60)
        newTran4.note = "Altro giapponese un po piu lungo"

        self.categories = [newCat0, newCat1, newCat2]
        self.transactions = [newTran1, newTran2, newTran3, newTran4]
    }

    
    
    func getValueOfDay(_ d:Date)->Float{
        return getTransactionsOfDay(d).reduce(0) { (curr, next) -> Float in return curr+next.value}
    }
    
    func getTransactionsOfDay(_ d:Date)->[CDTransaction]{
        return self.transactions.filter { (t) -> Bool in return Calendar.current.isDate(t.date!, inSameDayAs: d)}
    }
    
    
        
    func addCategory(name:String, color:String, icon:String) {
        let c = CDCategory(context: self.context)
        c.id = name + "\(Date().timeIntervalSince1970)"
        c.name = name
        c.color = color
        c.icon = icon
        c.transactions = []
        self.categories.append(c)
        cd_save()
    }

    
    func deleteCategory(cat:CDCategory){
        self.categories.removeAll { (c) -> Bool in return c.id == cat.id}
        self.transactions.removeAll { (t) -> Bool in return t.category!.id == cat.id}
        
        for t in cat.transactions?.allObjects as! [CDTransaction]{self.context.delete(t)}
        self.context.delete(cat)
        
        cd_save()
    }
    
        
    func addTransaction(value:Float, note:String, category:CDCategory, date:Date = Date()) {
        let t = CDTransaction(context: self.context)
        t.id = note + "_\(date.timeIntervalSince1970)"
        t.note = note
        t.value = value
        t.category = category
        t.date = date
        self.transactions.append(t)
        cd_save()
    }

    
    
    func deleteTransaction(tran:CDTransaction){
        self.transactions.removeAll { (t) -> Bool in return tran.id == t.id}
        self.context.delete(tran)
        cd_save()
    }
    
    
    func cd_save(){
        do{try self.context.save();self.forceRefresh()
        }catch{let nsError = error as NSError;fatalError("CD ERROR: \(nsError), \(nsError.userInfo)")}
    }
    
}
