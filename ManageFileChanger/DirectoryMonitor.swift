import UIKit


protocol DirectoryMonitorDelegate: class {
    func directoryMonitorDidObserveChange(_ directoryMonitor: DirectoryMonitor)
}

class DirectoryMonitor: NSObject {
    static let sharedInstance: DirectoryMonitor = {
        return DirectoryMonitor()
    }()
    
    weak var delegate: DirectoryMonitorDelegate?
    var monitoredDirectoryFileDescriptor: CInt = -1
    let directoryMonitorQueue = DispatchQueue.global(qos: .background)
    var directoryMonitorSource: DispatchSourceFileSystemObject?
    
    private override init() {
        super.init()
    }
    
    func startMonitoring(_ path: String) {
        if directoryMonitorSource == nil && monitoredDirectoryFileDescriptor == -1 {
            monitoredDirectoryFileDescriptor = open(path, O_EVTONLY)
            directoryMonitorSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: monitoredDirectoryFileDescriptor, eventMask: [.write, .extend, .delete, .all], queue: directoryMonitorQueue)
            directoryMonitorSource?.setEventHandler(qos: .background, flags: .enforceQoS, handler: {
                self.delegate?.directoryMonitorDidObserveChange(self)
            })
            directoryMonitorSource?.setCancelHandler(handler: {
                close(self.monitoredDirectoryFileDescriptor)
                self.monitoredDirectoryFileDescriptor = -1
                self.directoryMonitorSource = nil
            })
            
            directoryMonitorSource?.resume()
        }
    }
    
    func stopMonitoring() {
        if directoryMonitorSource != nil {
            directoryMonitorSource?.cancel()
        }
    }
}
