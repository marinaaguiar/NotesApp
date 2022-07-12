
import UIKit
import CoreData

protocol NotebookListViewModelProtocol: AnyObject {
    var isSortingByOldest: Bool { get }
    func switchSortingCondition(to sortByOldest: Bool)
    func initializeCoreData()
    func saveNewNotebook(name: String)
    func editNotebook(for newName: String, atIndexPath indexPath: IndexPath) 
    func deleteNotebook(atIndexPath indexPath: IndexPath)
    func refreshItems()
    func numberOfRows() -> Int
    func fillCell(atIndexPath indexPath: Int) -> NotebookCell
    func displayNotes(notebookID: NSManagedObjectID)
    func objectID(forNotebookAt index: Int) -> NSManagedObjectID?
}

protocol NotebookListViewModelDelegate: AnyObject {
    func didLoad()
    func displayNotes(notebookID: NSManagedObjectID)
    func didLoadWithError()
}

class NotebookListViewModel: NotebookListViewModelProtocol {

    private weak var delegate: NotebookListViewModelDelegate?
    private var notebooks: [Notebook]?
    private let storageService = DataController.shared
    internal var isSortingByOldest: Bool = false

    private var date = { (date: Date?) -> String in
        guard let date = date else {
            print("Unable to get the date")
            return ""
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }

    private var pageCount = { (page: Int?) -> String in
        guard let count = page else {
            print("Unable to get the pageCount")
            return ""
        }
        let pageString = count == 1 ? "page" : "pages"
        let pageCountString = "\(count) \(pageString)"
        return pageCountString
    }

    init(delegate: NotebookListViewModelDelegate?) {
        self.delegate = delegate
    }

    func switchSortingCondition(to sortByOldest: Bool) {
        isSortingByOldest = sortByOldest
    }

    func initializeCoreData() {
        storageService.loadPersistentStores { result in
            switch result {
            case .success:
                print("Loaded stores successfully")
                //Get Notebooks from Core Data
                self.refreshItems()
            case .failure:
                print("Failed to load stores")
            }
        }
    }

    func refreshItems() {
        let request: NSFetchRequest<Notebook> = Notebook.fetchRequest()

        let sort = NSSortDescriptor(key: "creationDate", ascending: isSortingByOldest)
        request.sortDescriptors = [sort]

        do {
            try storageService.performContainerAction { container in
                let context = container.viewContext
                let objects = try context.fetch(request)
                self.notebooks = objects
                self.delegate?.didLoad()
            }
        } catch {
            print("Error fetching data from context \(error)")
        }
    }

    func numberOfRows() -> Int {
        return notebooks?.count ?? 0
    }

    func fillCell(atIndexPath indexPath: Int) -> NotebookCell {

        guard let notebooks = notebooks else {
            return NotebookCell(notebookName: "", creationDate: "", pageCount: "")
        }

        let notebook = notebooks[indexPath]
        let notebookName = notebook.name
        let notebookCreationDate = "Created at \(date(notebook.creationDate))"
        let notebookPageCount = pageCount(notebook.notes?.count)

        return NotebookCell(notebookName: notebookName, creationDate: notebookCreationDate, pageCount: notebookPageCount)
    }

    func saveNewNotebook(name: String) {
            do {
                try storageService.performContainerAction { container in
                    let context = container.viewContext

                    // Create a Note object
                    let newNotebook = Notebook(context: context)
                    newNotebook.name = name
                    newNotebook.creationDate = Date()
                    // Save the data
                    context.insert(newNotebook)
                    try context.save()
                }
            } catch {
                print(error.localizedDescription)
            }
    }

    func deleteNotebook(atIndexPath indexPath: IndexPath) {
        guard let notebooks = notebooks else { return }

        do {
            try storageService.performContainerAction { container in

                let context = container.viewContext
                context.delete(notebooks[indexPath.row])
                try context.save()
            }
        } catch {
            print("Could not delete \(error.localizedDescription)")
        }
    }

    func editNotebook(for newName: String, atIndexPath indexPath: IndexPath) {
        guard let notebooks = notebooks else { return }
        do {
            try storageService.performContainerAction { container in

                let context = container.viewContext
                notebooks[indexPath.row].name = newName
                try context.save()
            }
        } catch {
            print("Could not delete \(error.localizedDescription)")
        }
    }

    func objectID(forNotebookAt index: Int) -> NSManagedObjectID? {
        return notebooks?[index].objectID
    }

    func displayNotes(notebookID: NSManagedObjectID) {
        delegate?.displayNotes(notebookID: notebookID)
    }
}
