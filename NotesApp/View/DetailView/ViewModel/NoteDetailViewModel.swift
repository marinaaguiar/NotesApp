
import UIKit
import CoreData

protocol NoteDetailViewModelProtocol: AnyObject {

    func initializeCoreData()
    func refreshItems()
    func saveNoteText(with content: UITextView)
    func objectID(forNoteAt index: Int) -> NSManagedObjectID?
    func setNote(noteID: NSManagedObjectID) -> Note
    func getNote() -> NSAttributedString
}

protocol NoteDetailViewModelDelegate: AnyObject {
    func didLoad()
}

class NoteDetailViewModel: NoteDetailViewModelProtocol {

    private weak var delegate: NoteDetailViewModelDelegate?
    private var note: Note!
    private var notes: [Note]?
    private let storageService = DataController.shared

    init(delegate: NoteDetailViewModelDelegate?) {
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

    func refreshItems() {
        let request: NSFetchRequest<Note> = Note.fetchRequest()

        do {
            try storageService.performContainerAction { container in
                let context = container.viewContext
                let object = try context.fetch(request)
                self.notes = object
                self.delegate?.didLoad()
            }
        } catch {
            print("Error fetching data from context \(error)")
        }
    }

    func saveNoteText(with content: UITextView) {

        do {
            try storageService.performContainerAction { container in

                let context = container.viewContext
                note.attributedText = content.attributedText
                try context.save()
            }
        } catch {
            print("Error saving the note content \(error.localizedDescription)")
        }
    }

    func getNote() -> NSAttributedString {
        print(note.attributedText?.string ?? "")
        return note.attributedText ?? NSAttributedString(string: "")
    }

    func objectID(forNoteAt index: Int) -> NSManagedObjectID? {
        return notes?[index].objectID
    }

    func setNote(noteID: NSManagedObjectID) -> Note {
        try! storageService.performContainerAction { container in
            let context = container.viewContext
            let note = context.object(with: noteID) as! Note
            self.note = note
        }
        return note
    }
}
