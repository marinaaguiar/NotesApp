
import UIKit

protocol NotebookListViewModelProtocol: AnyObject {
    var isSortingByOldest: Bool { get }
    func switchSortingCondition(to sortByOldest: Bool)
    func initializeCoreData()
    func saveNewNotebook(name: String)
    func deleteNotebook(atIndexPath indexPath: IndexPath) 
    func refreshItems()
    func numberOfRows() -> Int
    func fillCell(atIndexPath indexPath: Int) -> NotebookCell
    func displayNotes(notebook: String)
    func transporter(index: Int) -> String
}

protocol NotebookListViewModelDelegate: AnyObject {
    func didLoad()
    func displayNotes(notebook: String)
    func didLoadWithError()
}
