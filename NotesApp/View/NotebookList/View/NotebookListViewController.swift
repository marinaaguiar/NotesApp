
import UIKit
import CoreData

class NotebookListViewController: UIViewController {

    private lazy var viewModel: NotebookListViewModelProtocol = NotebookListViewModel(delegate: self)

    // MARK: Table
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortingButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.initializeCoreData()
        setup()
    }

    @IBAction func addNotebookButtonPressed(_ sender: UIBarButtonItem) {
        let alert = buildNotebookNameAlert { text in
            guard let notebookName = text else { return }
            self.viewModel.saveNewNotebook(name: notebookName)
            self.viewModel.refreshItems()
        }
        present(alert, animated: true)
    }

    @IBAction func sortButtonPressed(_ sender: UIBarButtonItem) {
        if viewModel.isSortingByOldest == false {
            sortingButton.tintColor = .gray
            viewModel.switchSortingCondition(to: true)
            viewModel.initializeCoreData()
        } else {
            sortingButton.tintColor = .systemBlue
            viewModel.switchSortingCondition(to: false)
            viewModel.initializeCoreData()
        }
    }

    func setup() {
        title = "Notebooks"
//        tableView.register(NotebookViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self
    }

    func buildNotebookNameAlert(onSave: @escaping (String?) -> Void) -> UIAlertController {
        let alert = UIAlertController(
            title: "New Notebook 📕",
            message: "Create a new notebook title",
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

    func buildDeleteAlert(onDelete: @escaping () -> Void) -> UIAlertController {
        let alert = UIAlertController(title: "Delete Note 👀", message: "Are you sure you want to delete this note permanently?", preferredStyle: .alert
        )

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak alert] _ in
            onDelete()
        }

        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        return alert
    }

    func cell(_ tableView: UITableView, indexpath: IndexPath, notebookCell: NotebookCell) -> UITableViewCell {

        let cell = tableView.dequeCell(NotebookViewCell.self, indexpath)
        cell.fill(notebookCell)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

    //MARK: - TaleViewDataSource

extension NotebookListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cell(tableView, indexpath: indexPath, notebookCell: viewModel.fillCell(atIndexPath: indexPath.row))
    }
}
    //MARK: - TableViewDelegate

extension NotebookListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let alert = buildDeleteAlert {
            self.viewModel.deleteNotebook(atIndexPath: indexPath)
            self.viewModel.refreshItems()
        }

        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            self.present(alert, animated: true)
        }

        return UISwipeActionsConfiguration(actions: [action])
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.displayNotes(notebook: viewModel.transporter(index: indexPath.row))
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


    //MARK: - Delegate

extension NotebookListViewController: NotebookListViewModelDelegate {

    func didLoad() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }

    func displayNotes(notebook: String) {
        let notesVC = storyboard?.instantiateViewController(withIdentifier: "NotesListViewController") as? NotesListViewController
        guard let notesVC = notesVC else { return }
        notesVC.setup(notebook)
        navigationController?.pushViewController(notesVC, animated: true)
    }

    func didLoadWithError() {
        //
    }
}
