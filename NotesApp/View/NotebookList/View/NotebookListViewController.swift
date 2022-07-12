
import UIKit
import CoreData

class NotebookListViewController: UIViewController {

    private lazy var viewModel: NotebookListViewModelProtocol = NotebookListViewModel(delegate: self)

    // MARK: Table
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortingButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        viewModel.initializeCoreData()
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
            sortingButton.tintColor = .systemGray4
            viewModel.switchSortingCondition(to: true)
            viewModel.initializeCoreData()
        } else {
            sortingButton.tintColor = .systemCyan
            viewModel.switchSortingCondition(to: false)
            viewModel.initializeCoreData()
        }
    }

    func setup() {
        title = "Notebooks"
        tableView.dataSource = self
        tableView.delegate = self
    }

    func cell(_ tableView: UITableView, indexpath: IndexPath, notebookCell: NotebookCell) -> UITableViewCell {

        let cell = tableView.dequeCell(NotebookViewCell.self, indexpath)
        cell.fill(notebookCell)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}
    //MARK: - Alerts

extension NotebookListViewController {

    func buildNotebookNameAlert(onSave: @escaping (String?) -> Void) -> UIAlertController {
        let alert = UIAlertController(
            title: "New Notebook 📕",
            message: "Create a new notebook title",
            preferredStyle: .alert
        )

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak alert] _ in
            if alert?.textFields?.first?.text != "" {
                onSave(alert?.textFields?.first?.text)
            } else {
                onSave("New Notebook")
            }
        }

        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)

        return alert
    }

    func buildDeleteAlert(onDelete: @escaping () -> Void) -> UIAlertController {
        let alert = UIAlertController(title: "All notes will be deleted.", message: "Are you sure you want to delete this notebook permanently?", preferredStyle: .actionSheet
        )

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak alert] _ in
            onDelete()
        }

        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        return alert
    }

    func buildEditAlert(onEdit: @escaping (String?) -> Void) -> UIAlertController {
        let alert = UIAlertController(title: "Edit Notebook Title", message: "", preferredStyle: .alert
        )

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak alert] _ in
            onEdit(alert?.textFields?.first?.text)
        }

        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)

        return alert
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

        let deleteAlert = buildDeleteAlert {
            self.viewModel.deleteNotebook(atIndexPath: indexPath)
            self.viewModel.refreshItems()
        }

        let editAlert = buildEditAlert { text in
            guard let notebookName = text else { return }
            self.viewModel.editNotebook(for: notebookName, atIndexPath: indexPath)
            self.viewModel.refreshItems()
        }

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            self.present(deleteAlert, animated: true)
        }

        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, completionHandler) in
            self.present(editAlert, animated: true)
        }

        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let notebookID = viewModel.objectID(forNotebookAt: indexPath.row) else {
            return
        }
        viewModel.displayNotes(notebookID: notebookID)
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

    func displayNotes(notebookID: NSManagedObjectID) {
        let notesVC = storyboard?.instantiateViewController(withIdentifier: "NotesListViewController") as? NotesListViewController
        guard let notesVC = notesVC else { return }
        notesVC.setup(notebookID: notebookID)
        navigationController?.pushViewController(notesVC, animated: true)
    }

    func didLoadWithError() {
        //
    }
}
