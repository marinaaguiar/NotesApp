
import UIKit
import CoreData

class NotesListViewModel: NotesListViewModelProtocol {

    private weak var delegate: NotesListViewModelDelegate?

    private var notes: [Note]?

    // MARK: Services
    private let storageService = DataController(persistentContainer: .notesApp)

    init(delegate: NotesListViewModelDelegate?) {
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


    func saveNewNote(name: String) {
        do {
            try storageService.performContainerAction { container in
                let context = container.viewContext

                // Create a Note object
                let newNote = Note(context: context)
//                newNote.attributedText = name
                newNote.creationDate = Date()
                // Save the data
                context.insert(newNote)
                try context.save()
            }
        } catch {
            print(error.localizedDescription)
        }
    }


    func refreshItems() {
        let request: NSFetchRequest<Note> = Note.fetchRequest()

        let sort = NSSortDescriptor(key: "creationDate", ascending: false)
        request.sortDescriptors = [sort]

        do {
            try storageService.performContainerAction { container in
                let context = container.viewContext
                let objects = try context.fetch(request)
                self.notes = objects
                self.delegate?.didLoad()
            }
        } catch {
            print("Error fetching data from context \(error)")
        }
    }

    func numberOfRows() -> Int {
        return notes?.count ?? 0
    }

    func fillCell(for cell: UITableViewCell,atIndexPath indexPath: Int) -> UITableViewCell {

        let note = self.notes![indexPath]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm - MMM d, yyyy"
        let dateString = dateFormatter.string(from: note.creationDate!)
        cell.textLabel?.text = note.attributedText as? String
        cell.detailTextLabel?.text = "Created at \(dateString)"

        return cell
    }
}
