
import UIKit

class NotesListViewController: UIViewController {

    private lazy var viewModel: NotesListViewModelProtocol = NotesListViewModel(delegate: self)

    @IBOutlet weak var tableView: UITableView!

    // MARK: Services
    let storageService = DataController(persistentContainer: .mooskineNotebook)

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.initializeCoreData()
        tableView.dataSource = self
//        tableView.delegate = self
    }

    @IBAction func addNoteButtonPressed(_ sender: Any) {
        
    }

    func setup(_ notebook: String) {
        navigationItem.title = notebook
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

