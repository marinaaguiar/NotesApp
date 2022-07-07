//
//  StorageService.swift
//  MooskineNotebook
//
//  Created by Marina Aguiar on 7/1/22.
//

import Foundation
import CoreData

struct DataController {
    enum PersistentContainer: String {
        case mooskineNotebook = "MooskineNotebook"
    }

    private let persistentContainer: NSPersistentContainer

    init(persistentContainer: PersistentContainer) {
        self.persistentContainer = NSPersistentContainer(name: persistentContainer.rawValue)
    }

    func loadPersistentStores(completion: @escaping (Result<NSPersistentStoreDescription?, Error>) -> Void) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error {
                completion(.failure(error))
            }
            completion(.success(storeDescription))
        }
    }

    func performContainerAction(action: (NSPersistentContainer) throws -> Void) throws {
        try action(persistentContainer)
    }

    func saveContext() -> Result<Void, Error> {
        let context = persistentContainer.viewContext

        if context.hasChanges {
            return Result { try context.save() }
        }

        return .success(())
    }
}
