
import UIKit
import CoreData

protocol NotesListViewModelProtocol: AnyObject {
    func initializeCoreData()
    func setNotebook(notebookID: NSManagedObjectID) -> Notebook
    func saveNewNote()
    func refreshItems()
    func numberOfRows() -> Int
    func fillCell(atIndexPath indexPath: Int) -> NoteCell
    func getNotebook() -> Notebook
}


protocol NotesListViewModelDelegate: AnyObject {
    func didLoad()
    func displayNotes(noteID: NSManagedObjectID)
}

class NotesListViewModel: NotesListViewModelProtocol {

    private weak var delegate: NotesListViewModelDelegate?
    private var notebook: Notebook!
    private var notes: [Note]?

    private var date = { (date: Date?) -> String in
        guard let date = date else {
            print("Unable to get the date")
            return ""
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a MMM d, yyyy"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }

    // MARK: Services
    private let storageService = DataController.shared

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

    func saveNewNote() {
        do {
            try storageService.performContainerAction { container in
                let context = container.viewContext

                // Create a Note object
                let newNote = Note(context: context)
                newNote.text = "New Note"
                newNote.creationDate = Date()
                newNote.notebook = notebook

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

        let predicate = NSPredicate(format: "notebook = %@", notebook)
        request.predicate = predicate

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

    func fillCell(atIndexPath indexPath: Int) -> NoteCell {


        guard let notes = notes else {
            return NoteCell(noteName: "", creationDate: "")
        }

        let note = notes[indexPath]
        let noteName = note.text
        let noteCreationDate = date(note.creationDate)

        return NoteCell(noteName: noteName, creationDate: noteCreationDate)
    }

    func setNotebook(notebookID: NSManagedObjectID) -> Notebook {
        try! storageService.performContainerAction { container in
            let context = container.viewContext
            let notebook = context.object(with: notebookID) as! Notebook

            self.notebook = notebook
        }

        return notebook
    }

    func getNotebook() -> Notebook {
        return notebook
    }

    func transporter(index: Int) -> String {
        notes![index].text!
    }
}
