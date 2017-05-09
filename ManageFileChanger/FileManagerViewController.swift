
import UIKit

protocol ChangingValueTableView: class {
    func reloadTableViewCell()
}


class FileManagerViewController: UIViewController {
    @IBOutlet weak var pathLabel: UILabel!
    @IBOutlet weak var directoryTableView: UITableView!
    var directories: [String]?
    var mainDirectory: URL?
    weak var nextController: FileManagerViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pathLabel.text = Directories.sharedInstance.currentDirectory
        directories = Directories.sharedInstance.getContentFolders(URL(string: Directories.sharedInstance.currentDirectory!)!, appendingPath: "")
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name("reload"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DirectoryMonitor.sharedInstance.delegate = self
    }
    
    deinit {
        Directories.sharedInstance.goBackward()
        NotificationCenter.default.removeObserver(self)
    }
    
    func reloadData() {
        directories = Directories.sharedInstance.mainDirectory
        directoryTableView.reloadData()
    }
}

extension FileManagerViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return (directories?.count)!
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FolderTableViewCell
        cell.pathLabel?.text = directories?[indexPath.row]
        cell.nameCell = pathLabel.text
        let stringFollowed = pathLabel.text! + (directories?[indexPath.row])!
        if stringFollowed == UserDefaults.standard.string(forKey: "follow") {
            cell.switchFolder?.setOn(true, animated: true)
        } else {
            cell.switchFolder?.setOn(false , animated: true)
        }
        cell.delegate = self
        return cell
    }
}

extension FileManagerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        nextController = storyboard.instantiateViewController(withIdentifier: "fileManager") as? FileManagerViewController
        print( Directories.sharedInstance.currentDirectory!)
        guard   let directoriesList = Directories.sharedInstance.getContentFolders(URL(string: Directories.sharedInstance.currentDirectory!)!, appendingPath: (directories?[indexPath.row])!) else { return }
        if directoriesList.count < 1 {
            let alert = UIAlertController(title: "Warning", message: "Next folder doesn't have any directories", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        nextController?.directories = directoriesList
        self.navigationController?.pushViewController(nextController!, animated: true)
    }
    
}

extension FileManagerViewController: ChangingValueTableView {
    func reloadTableViewCell() {
        reloadData()
    }
}

extension FileManagerViewController: DirectoryMonitorDelegate {
    func directoryMonitorDidObserveChange(_ directoryMonitor: DirectoryMonitor) {
        let notification = UILocalNotification()
        notification.alertAction = "Go back to App"
        notification.alertBody = "Directory was changed"
        UIApplication.shared.scheduleLocalNotification(notification)
    }
}
