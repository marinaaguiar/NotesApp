
import UIKit
import CoreData

class NotebookListViewModel: NotebookListViewModelProtocol {

    private weak var delegate: NotebookListViewModelDelegate?
    private var notebooks: [Notebook]?

    // MARK: Services
    private let storageService = DataController(persistentContainer: .mooskineNotebook)

    init(delegate: NotebookListViewModelDelegate?) {
        self.delegate = delegate
    }

    func initializeCoreData() {
        storageService.loadPersistentStores { result in
            switch result {
            case .success:
                print("loaded stores successfully")
                //Get Notebooks from Core Data
                self.refreshItems()
            case .failure:
                print("failed to load stores, gosh darn it.")
            }
        }
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

    func refreshItems() {
        let request: NSFetchRequest<Notebook> = Notebook.fetchRequest()

        let sort = NSSortDescriptor(key: "creationDate", ascending: false)
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
        let notebookCreationDate = "Created at \(convertDateToString(date: notebook.creationDate))"
        let notebookPageCount = convertPageToString(for: notebook.notes?.count )

        return NotebookCell(notebookName: notebookName!, creationDate: notebookCreationDate, pageCount: notebookPageCount)
    }

    func convertDateToString(date: Date?) -> String{

        guard let date = date else {
            print("Unable to get the date")
            return ""
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm - MMM d, yyyy"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }

    func convertPageToString(for pageCount: Int?) -> String {
        guard let count = pageCount else {
            print("Unable to get the pageCount")
            return ""
        }
        let pageString = count == 1 ? "page" : "pages"
        let pageCountString = "\(count) \(pageString)"
        return pageCountString
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

    func displayNotes(notebook: String) {
        delegate?.displayNotes(notebook: notebook)
    }

    func transporter(index: Int) -> String {
        notebooks![index].name!
    }
}
