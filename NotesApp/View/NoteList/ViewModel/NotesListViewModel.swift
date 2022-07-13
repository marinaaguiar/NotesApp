
import UIKit
import CoreData

protocol NotesListViewModelProtocol: AnyObject {
    func initializeCoreData()
    func setNotebook(notebookID: NSManagedObjectID) -> Notebook
    func saveNewNote()
    func refreshItems()
    func numberOfRows() -> Int
    func fillCell(atIndexPath indexPath: Int) -> NoteCell
    func deleteNotes(atIndexPath indexPath: IndexPath)
    func getNotebook() -> Notebook
    func objectID(forNoteAt index: Int) -> NSManagedObjectID?
    func displayNoteDetail(noteID: NSManagedObjectID)
}

protocol NotesListViewModelDelegate: AnyObject {
    func didLoad()
    func displayNoteDetail(noteID: NSManagedObjectID)
}

class NotesListViewModel: NotesListViewModelProtocol {

    private weak var delegate: NotesListViewModelDelegate?
    private var notebook: Notebook!
    private var notes: [Note]?

    private var date = { (dateCreated: Date?, dateLastModified: Date?) -> String in
        guard let dateCreated = dateCreated, let dateLastModified = dateLastModified else {
            print("Unable to get the date")
            return ""
        }
        var dateString: String = ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy - hh:mm a"

        if dateCreated == dateLastModified {
            dateString = "Created at \(dateFormatter.string(from: dateCreated))"
        } else {
            dateString = "Last modified at \(dateFormatter.string(from: dateLastModified))"
        }

        return dateString
    }

    private var noteTitleString = { (note: NSAttributedString?) -> String in
        guard let note = note else {
            print("Unable to get the date")
            return "New Note"
        }
        let noteTitle = note.string
        return String(noteTitle)
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
                print("failed to load stores")
            }
        }
    }

    func saveNewNote() {
        do {
            try storageService.performContainerAction { container in
                let context = container.viewContext
                
                // Create a Note object
                let newNote = Note(context: context)
                newNote.title = "New Note"
                newNote.creationDate = Date()
                newNote.lastModifiedDate = newNote.creationDate
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

        let sort = NSSortDescriptor(key: "lastModifiedDate", ascending: false)
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
            return NoteCell(noteTitle: "", lastModifiedDate: "")
        }
        var noteTitle: String = ""

        let note = notes[indexPath]
        if note.attributedText == nil {
            noteTitle = "New Note"
        } else {
            noteTitle = noteTitleString(note.attributedText)
        }

        let noteDate = date(note.creationDate, note.lastModifiedDate)

        return NoteCell(noteTitle: noteTitle, lastModifiedDate: noteDate)
    }

    func setNotebook(notebookID: NSManagedObjectID) -> Notebook {
        try! storageService.performContainerAction { container in
            let context = container.viewContext
            let notebook = context.object(with: notebookID) as! Notebook

            self.notebook = notebook
        }
        return notebook
    }

    func deleteNotes(atIndexPath indexPath: IndexPath) {

        guard let notes = notes else { return }

        do {
            try storageService.performContainerAction { container in

                let context = container.viewContext
                context.delete(notes[indexPath.row])
                try context.save()
            }
        } catch {
            print("Could not delete \(error.localizedDescription)")
        }
    }

    func getNotebook() -> Notebook {
        return notebook
    }

    func transporter(index: Int) -> String {
        guard let notes = notes else {
            fatalError("Unable to fetch Notes")
            return ""
        }
        return notes[index].attributedText!.string
    }

    func objectID(forNoteAt index: Int) -> NSManagedObjectID? {
        return notes?[index].objectID
    }

    func displayNoteDetail(noteID: NSManagedObjectID) {
        delegate?.displayNoteDetail(noteID: noteID)
    }
}

