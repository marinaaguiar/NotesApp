
import UIKit
import CoreData

class NotesListViewController: UIViewController {

    private lazy var viewModel: NotesListViewModelProtocol = NotesListViewModel(delegate: self)

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyNotesMessageLabel: UILabel!

    // MARK: Services
    let storageService = DataController.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        navigationItem.rightBarButtonItem = editButtonItem
        updateEditButtonState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        viewModel.initializeCoreData()
        viewModel.refreshItems()
        tableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }

    @IBAction func addNoteButtonPressed(_ sender: Any) {

        viewModel.saveNewNote()
        viewModel.refreshItems()
        let noteID = viewModel.objectID()
        viewModel.displayNoteDetail(noteID: noteID)
    }

    func setup(notebookID: NSManagedObjectID) {
        let notebook = viewModel.setNotebook(notebookID: notebookID)
        navigationController?.navigationBar.prefersLargeTitles = true
        title = notebook.name
    }

    func emptyNotesMessage() {
        if viewModel.numberOfRows() == 0 {
            tableView.isHidden = true
            title = ""
            emptyNotesMessageLabel.text = "Oh no! 👀 There is no notes created yet... \n \n Please add a new note right there 👇🏽"
        } else {
            title = viewModel.getNotebook().name
            emptyNotesMessageLabel.text = ""
            tableView.isHidden = false
        }
    }

    func cell(_ tableView: UITableView, indexPath: IndexPath, noteCell: NoteCell) -> UITableViewCell {

        let cell = tableView.dequeCell(NoteViewCell.self, indexPath)
        cell.fill(noteCell)
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func buildDeleteAlert(onDelete: @escaping () -> Void) -> UIAlertController {
        let alert = UIAlertController(title: "Delete Note", message: "Are you sure you want to delete this note permanently?", preferredStyle: .actionSheet
        )

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak alert] _ in
            onDelete()
        }

        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        return alert
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }

    func updateEditButtonState() {
        editButtonItem.isEnabled = viewModel.numberOfRows() == 0 ? false : true
    }
}

//MARK: - TableViewDelegate

extension NotesListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        return cell(tableView, indexPath: indexPath, noteCell: viewModel.fillCell(atIndexPath: indexPath.row))
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        let alert = buildDeleteAlert {
            self.viewModel.deleteNotes(atIndexPath: indexPath)
            self.viewModel.refreshItems()
        }

        switch editingStyle {
        case .delete:
            self.present(alert, animated: true)
        default: () // Unsupported
        }
    }
}

//MARK: - TableViewDelegate

extension NotesListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let noteID = viewModel.objectID(forNoteAt: indexPath.row) else {
            return
        }
        viewModel.displayNoteDetail(noteID: noteID)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


//MARK: - NotesListViewModelDelegate

extension NotesListViewController: NotesListViewModelDelegate {

    func didLoad() {
        emptyNotesMessage()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
            self.updateEditButtonState()
        }
    }

    func displayNoteDetail(noteID: NSManagedObjectID) {
        let noteDetailVC = storyboard?.instantiateViewController(withIdentifier: "NoteDetailViewController") as? NoteDetailViewController
        guard let noteDetailVC = noteDetailVC else { return }
        noteDetailVC.setup(noteID: noteID)
        navigationController?.pushViewController(noteDetailVC, animated: true)
    }
}

