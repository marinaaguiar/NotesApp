
import UIKit
import CoreData

class NoteDetailViewController: UIViewController {

    private lazy var viewModel: NoteDetailViewModelProtocol = NoteDetailViewModel(delegate: self)

    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        viewModel.initializeCoreData()
        textView.attributedText = viewModel.getNote()
    }

    @IBAction func trashButtonPressed(_ sender: UIBarButtonItem) {
    }

    func setup(noteID: NSManagedObjectID) {
        let note = viewModel.setNote(noteID: noteID)
    }
}

//MARK: - UITextViewDelegate

extension NoteDetailViewController: UITextViewDelegate {

    func textViewDidEndEditing(_ textView: UITextView) {
        viewModel.saveNoteText(with: textView)
        viewModel.refreshItems()
        print("savedItems")
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

//MARK: - NoteDetailViewModelDelegate

extension NoteDetailViewController: NoteDetailViewModelDelegate {

    func didLoad() {
        //
    }
}
