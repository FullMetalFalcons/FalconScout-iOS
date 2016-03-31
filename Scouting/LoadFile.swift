//
//  LoadFile.swift
//  InterfaceConstruction
//
//  Created by Alex DeMeo on 1/5/16.
//  Copyright © 2016 Alex DeMeo. All rights reserved.
//

import UIKit


struct FileUtil {
    internal static var fileContents: String! = ""
    internal static var fileContentsTrimmed: [String]! = [String]()
    internal static var allKeys: [String] = [String]()

    static func loadFileToString() {
        let path = NSBundle.mainBundle().pathForResource("config", ofType: "txt")
        var str: NSString!
        do {
            str = try NSString(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
        } catch {
            print(error)
        }
        FileUtil.fileContents = "\(str)"
        FileUtil.trimFileContents(FileUtil.fileContents)
        FileUtil.createKeysList()
        
    }
    
    private static func createKeysList() {
        for line in FileUtil.fileContentsTrimmed {
            if !(line.hasPrefix("SPACE") || line.hasPrefix("LABEL")) {
                let parts = line.componentsSeparatedByString(";;")
                let key = parts[parts.endIndex.predecessor()].trim()
                FileUtil.allKeys.append(key)
            }
        }
    }
    
    private static func trimFileContents(contents: String) {
        let lines = contents.componentsSeparatedByString("\n")
        var trimmedLines: [String]! = [String]()
        
        for line in lines {
            if !line.hasPrefix("##") && !line.isEmpty && !line.hasPrefix("@"){
                trimmedLines.append(line)
            }
        }
        FileUtil.fileContentsTrimmed = trimmedLines
    }
}
