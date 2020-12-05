//
//  Fact+CoreDataProperties.swift
//  NumberFactsApp
//
//  Created by Hashir Khan on 12/4/20.
//
//

import Foundation
import CoreData


extension Fact {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Fact> {
        return NSFetchRequest<Fact>(entityName: "Fact")
    }

    @NSManaged public var factText: String?
    @NSManaged public var genre: String?

}

extension Fact : Identifiable {

}
