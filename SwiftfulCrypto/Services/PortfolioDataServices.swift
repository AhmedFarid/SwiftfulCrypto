//
//  PortfolioDataServices.swift
//  SwiftfulCrypto
//
//  Created by Farido on 14/09/2024.
//

import Foundation
import CoreData

class PortfolioDataServices {
    private let container: NSPersistentContainer
    private let containerName: String = "ProtfolioContainer"
    private let entityName: String = "ProtfolioEntity"

    @Published var savedEntities: [ProtfolioEntity] = []

    init() {
        self.container = NSPersistentContainer(name: containerName)
        container.loadPersistentStores { [weak self] _, error in
            guard let self = self else {return}
            if let error = error {
                print("Error Loading coreDate! \(error)")
            }
            self.getPortfolio()
        }
    }

    func updatePortfolio(coin: Coin, amount: Double) {
        if let entity = savedEntities.first(where: {$0.coinID == coin.id}) {
            if amount > 0 {
                update(entity: entity, amount: amount)
            } else {
                delete(entity: entity)
            }
        } else {
            add(coin: coin, amount: amount)
        }


    }

    private func getPortfolio() {
        let request = NSFetchRequest<ProtfolioEntity>(entityName: entityName) 
        do {
            savedEntities = try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching Portfolio Data! \(error)")
        }
    }

    private func add(coin: Coin, amount: Double) {
        let entity = ProtfolioEntity(context: container.viewContext)
        entity.coinID = coin.id
        entity.amount = amount
        applyChanges()
    }

    private func update(entity: ProtfolioEntity, amount: Double) {
        entity.amount = amount
        applyChanges()
    }

    private func delete(entity: ProtfolioEntity) {
        container.viewContext.delete(entity) 
        applyChanges()
    }

    private func save() {
        do {
            try container.viewContext.save()
        } catch let error {
            print("Error saving Data! \(error)")
        }
    }

    private func applyChanges() {
        save()
        getPortfolio()
    }

}
