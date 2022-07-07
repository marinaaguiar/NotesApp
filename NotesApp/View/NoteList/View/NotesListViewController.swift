
import UIKit

class NotesListViewController: UIViewController {

    private lazy var viewModel: NotesListViewModelProtocol = NotesListViewModel(delegate: self)

    @IBOutlet weak var tableView: UITableView!

    // MARK: Services
    let storageService = DataController(persistentContainer: .notesApp)

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.initializeCoreData()
        tableView.dataSource = self
//        tableView.delegate = self
    }

    @IBAction func addNoteButtonPressed(_ sender: Any) {
        let alert = buildNoteNameAlert { text in
            guard let noteName = text else { return }
//            self.viewModel.saveNewNote(name: noteName)
//            self.viewModel.refreshItems()
        }
        present(alert, animated: true)
    }

    func setup(_ notebook: String) {
        navigationItem.title = notebook
    }

    func buildNoteNameAlert(onSave: @escaping (String?) -> Void) -> UIAlertController {
        let alert = UIAlertController(
            title: "New Note 📝",
            message: "Create a new note title",
            preferredStyle: .alert
        )

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak alert] _ in
            onSave(alert?.textFields?.first?.text)
        }

        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)

        return alert
    }

}

extension NotesListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        return viewModel.fillCell(for: cell, atIndexPath: indexPath.row)
    }
}

extension NotesListViewController: NotesListViewModelDelegate {

    func didLoad() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
}

