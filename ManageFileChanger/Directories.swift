
import UIKit

class Directories: NSObject {
    static let sharedInstance: Directories = {
        return Directories()
    }()
    var currentDirectory: String?
    var directoryUrl:[URL] {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    }
    var mainDirectory: [String]?
    var lastFolder: [String]?
    
    private override init() {
        super.init()
        lastFolder = Array<String>()
        do {
            mainDirectory = try FileManager.default.contentsOfDirectory(atPath: (directoryUrl.first?.path)!)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        currentDirectory =  directoryUrl.first?.path
    }
    
    func goForward(_ nameFolder: String) {
        if !nameFolder.isEmpty {
            lastFolder?.append("/" + nameFolder)
            currentDirectory = currentDirectory?.appending(lastFolder!.last!)
            mainDirectory = getContentFolders(URL(string: currentDirectory!)!, appendingPath: "")
        }
    }
    
    func goBackward() {
        if (lastFolder?.count)! > 0 {
            currentDirectory = currentDirectory?.components(separatedBy: lastFolder!.last!).first
            lastFolder?.remove(at: (lastFolder?.count)! - 1)
        }
        mainDirectory = getContentFolders(URL(string: currentDirectory!)!, appendingPath: "")
        NotificationCenter.default.post(name: NSNotification.Name("reload"), object: nil)
    }
    
    func getContentFolders(_ directory: URL, appendingPath: String) -> [String]? {
        do {
            let directory:[String] = try FileManager.default.contentsOfDirectory(atPath: (directory.appendingPathComponent(appendingPath).path))
            goForward(appendingPath)
            return directory
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return nil
    }
}
