//
//  CoreDataObjects.swift
//  KBudget
//
//  Created by Stefano Bertoli on 07/10/20.
//

import Foundation


extension CDCategory{
    func getNetTotal(lastNDays n:Int = -1)->Float{
        let refDate = n == -1 ? Date.distantPast : Date(timeIntervalSinceNow: -60*60*24*Double(n))
        if let ts = self.transactions?.allObjects as? [CDTransaction]{
            return ts.reduce(0, { (curr, next) -> Float in
                return curr + ( next.date!.timeIntervalSince(refDate) > 0 ? next.value : 0)
            })
        }else{return 0}
    }

    
    func getTransactionsOfLastNDays(_ n:Int)->[CDTransaction]{
        let refDate = n == -1 ? Date.distantPast : Date(timeIntervalSinceNow: -60*60*24*Double(n))
        if let ts = self.transactions?.allObjects as? [CDTransaction]{
            return ts.filter { (t) -> Bool in
                return t.date!.timeIntervalSince(refDate) > 0
            }
        }else{return []}
    }
    
    func cd_sync(){
        
    }
}

extension CDTransaction{
    
}
