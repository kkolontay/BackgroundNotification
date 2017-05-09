
import UIKit

class FolderTableViewCell: UITableViewCell {
    @IBOutlet weak var pathLabel: UILabel?
    @IBOutlet weak var switchFolder: UISwitch?
    var nameCell: String?
    weak var delegate: ChangingValueTableView?
    
    @IBAction func needFollow(_ sender: Any) {
        if (switchFolder?.isOn)! {
            UserDefaults.standard.set(nameCell! + "/" + (pathLabel?.text)!, forKey: "follow")
            DirectoryMonitor.sharedInstance.stopMonitoring()
            DirectoryMonitor.sharedInstance.startMonitoring(UserDefaults.standard.string(forKey: "follow")!)
            delegate?.reloadTableViewCell()
            UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
            //MARK this part was created for test
//            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 6){
//                do {
//                    var url = URL(string: "file://" + UserDefaults.standard.string(forKey: "follow")!)
//                    url = url?.appendingPathComponent("/test.txt")
//                    try  "testing".write(to: url!, atomically: true, encoding: .utf8)
//                } catch let error as NSError {
//                    print( error.localizedDescription)
//                }
//            }
        } else {
            
            UserDefaults.standard.set(nil, forKey: "follow")
        }
    }
    
}
