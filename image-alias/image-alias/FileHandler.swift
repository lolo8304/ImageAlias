//
//  FileHandler.swift
//  image-alias
//
//  Created by Lorenz Hänggi on 25.02.17.
//  Copyright © 2017 Lorenz Hänggi. All rights reserved.
//

import Foundation

public class FileReference: NSObject {
    
    public let url: URL
    public let values: URLResourceValues
    
    public init(url: URL, values: URLResourceValues) {
        self.url = url
        self.values = values
    }
    public func path() -> String {
        return self.url.deletingLastPathComponent().path
    }
    public func ext() -> String {
        return self.url.pathExtension
    }
    public func fileName() -> String {
        return self.url.lastPathComponent
    }
    
    public func log() {
        print(self.fileName(), self.ext(), self.values.creationDate!, self.values.fileSize ?? 0)
    }
}

public class FileHandler: NSObject {
    
    public override init() {
        
    }
    public func iterateDocuments() {
        do {
            let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            self.iterate(root: documentsURL, ext: ["*"])
        } catch {
            print(error)
        }
    }
    public func iterateHome() {
        let homeURL: URL? = URL.init(fileURLWithPath: NSHomeDirectory())
        self.iterate(root: homeURL!, ext: ["*"])
    }
    public func iterateDropbox(ext: [String]) {
        var dropboxURL: URL? = URL.init(fileURLWithPath: NSHomeDirectory())
        dropboxURL!.appendPathComponent("Dropbox")
        self.iterate(root: dropboxURL!, ext: ext)
    }
    
    public func iterate(root: URL, ext: [String]) {
        do {
            let resourceKeys : [URLResourceKey] = [.creationDateKey, .fileSizeKey]
            let enumerator = FileManager.default.enumerator(at: root,
                                                            includingPropertiesForKeys: resourceKeys,
                                                            options: [.skipsHiddenFiles], errorHandler: { (url, error) -> Bool in
                                                                print("directoryEnumerator error at \(url): ", error)
                                                                return true
            })!
            
            let filemanager = FileManager.default
            var dirs = [URL]()
            var files = [FileReference]()
            for case let fileURL as URL in enumerator {
                var isDir : ObjCBool = false
                if (filemanager.fileExists(atPath: fileURL.path, isDirectory: &isDir)) {
                    if isDir.boolValue {
                        dirs.append(fileURL)
                    } else if (ext.contains(fileURL.pathExtension)) {
                        let resourceValues = try fileURL.resourceValues(forKeys: Set(resourceKeys))
                        let fileRef = FileReference(url: fileURL, values: resourceValues)
                        files.append(fileRef)
                    }
                }
            }
            if (files.count > 0) {
                print("directory \(root) -----------------------------------------")
                for file in files {
                    file.log()
                }
            }
            for dirURL in dirs {
                self.iterate(root: dirURL, ext: ext)
            }
        } catch {
            print(error)
        }
    }
}
