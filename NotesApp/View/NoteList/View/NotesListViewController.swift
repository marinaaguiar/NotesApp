
import UIKit
import CoreData

class NotesListViewController: UIViewController {

    private lazy var viewModel: NotesListViewModelProtocol = NotesListViewModel(delegate: self)

    @IBOutlet weak var tableView: UITableView!

    // MARK: Services
    let storageService = DataController.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.initializeCoreData()
        tableView.dataSource = self
//        tableView.delegate = self

        navigationItem.rightBarButtonItem = editButtonItem

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    @IBAction func addNoteButtonPressed(_ sender: Any) {
        viewModel.saveNewNote()
        viewModel.refreshItems()
    }

    func setup(notebookID: NSManagedObjectID) {
        let notebook = viewModel.setNotebook(notebookID: notebookID)
        self.title = notebook.name
    }

    func addNote() {
        viewModel.saveNewNote()
        viewModel.refreshItems()
    }

    func cell(_ tableView: UITableView, indexPath: IndexPath, noteCell: NoteCell) -> UITableViewCell {

        let cell = tableView.dequeCell(NoteViewCell.self, indexPath)
        cell.fill(noteCell)
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
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
}

//MARK: - TableViewDelegate

extension NotesListViewController: NotesListViewModelDelegate {

    func didLoad() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }

    func displayNotes(noteID: NSManagedObjectID) {
//        delegate?.displayNotes(noteID: noteID)
    }
}

