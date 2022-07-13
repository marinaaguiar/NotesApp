
import UIKit
import CoreData

class NoteDetailViewController: UIViewController {

    private lazy var viewModel: NoteDetailViewModelProtocol = NoteDetailViewModel(delegate: self)

    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        textView.attributedText = viewModel.getNote()
        addDoneButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        viewModel.initializeCoreData()
    }

    @IBAction func trashButtonPressed(_ sender: UIBarButtonItem) {

        let alert = buildDeleteAlert {
            self.viewModel.deleteNote()
            self.navigationController?.popViewController(animated: true)
        }
        self.present(alert, animated: true)
    }

    func buildDeleteAlert(onDelete: @escaping () -> Void) -> UIAlertController {
        let alert = UIAlertController(title: "Delete Note 👀", message: "Do you want to delete this note?", preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak alert] _ in
            onDelete()
        }

        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        return alert
    }

    func setup(noteID: NSManagedObjectID) {
        let note = viewModel.setNote(noteID: noteID)
    }

    func addDoneButton() {
        let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
        let flexSpace = UIBarButtonItem(barButtonSystemItem:    .flexibleSpace, target: nil, action: nil)
        let doneButton: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissMyKeyboard))
        toolbar.setItems([flexSpace, doneButton], animated: false)
        toolbar.sizeToFit()
        self.textView.inputAccessoryView = toolbar
    }

    @objc func dismissMyKeyboard() {
        view.endEditing(true)
    }
}

//MARK: - UITextViewDelegate

extension NoteDetailViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        viewModel.saveNoteText(with: textView)
        print("Items Saved")
    }
}


//MARK: - NoteDetailViewModelDelegate

extension NoteDetailViewController: NoteDetailViewModelDelegate {

    func didLoad() {
        //
    }
}
