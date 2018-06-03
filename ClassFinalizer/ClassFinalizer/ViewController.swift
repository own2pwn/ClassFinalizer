//
//  ViewController.swift
//  ClassFinalizer
//
//  Created by Evgeniy on 03.06.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Cocoa

public typealias JSON = [String: Any]
public typealias JSONDict = [String: JSON]

public final class FClass {

    // MARK: - Interface
    
    public let name: String
    
    public let isFinal: Bool
    
    public var childs: [FClass] = []
    
    // MARK: - Init
    
    public init(name: String, isFinal: Bool) {
        self.name = name
        self.isFinal = isFinal
    }
}

public typealias ClassMapping = [String: FClass]

final class ViewController: NSViewController {

    // MARK: - Outlets
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScreen()
    }
    
    // MARK: - Members
    
    private var mapping: ClassMapping = [:]
    
    // MARK: - Methods
    
    private func setupScreen() {
        setup()
    }
    
    private func setup() {
        let setup = [testFinalizer]
        setup.forEach { $0() }
    }
    
    private func testFinalizer() {
        let json = parseJson()
        
        let files: [JSON] = json.map { $0.values.first! }
        for file in files {
            processFile(file)
        }
        
        let final = mapping.values.filter { !$0.isFinal && $0.childs.isEmpty }
        print("we can make \(final.count) classess final! / total: \(mapping.count)")
    }
    
    private func processFile(_ file: JSON) {
        if let fs = file["key.substructure"] as? [JSON] {
            for se in fs {
                processFS(se)
            }
        }
    }
    
    private func processFS(_ fs: JSON) {
        // TODO: ignore NSObject, UIViewController, etc
        
        guard
            let kind = fs["key.kind"] as? String,
            let className = fs["key.name"] as? String,
            kind == "source.lang.swift.decl.class" else { return }
        
        let isFinal = isClassFinal(fs)
        
        guard
            let inheritanceArrray = fs["key.inheritedtypes"] as? NSArray,
            let inheritedTypeDict = inheritanceArrray.firstObject as? [String: String],
            let inheritedType = inheritedTypeDict.values.first else {
            
            let baseClass = FClass(name: className, isFinal: isFinal)
            mapping[className] = baseClass
            
            return
        }
        
        let child = FClass(name: className, isFinal: isFinal)
        let parent: FClass
        
        if let parentClass: FClass = mapping[inheritedType] {
            parent = parentClass
        } else {
            parent = FClass(name: inheritedType, isFinal: false)
            mapping[inheritedType] = parent
        }
        
        parent.childs.append(child)
        mapping[className] = child
    }
    
    private func isClassFinal(_ c: JSON) -> Bool {
        guard
            let attributes = c["key.attributes"] as? NSArray,
            let attributesDict = attributes as? Array<JSON> else { return false }
        
        for attribute in attributesDict {
            guard
                let finalAttribute = attribute["key.attribute"] as? String else { continue }
            
            if finalAttribute == "source.decl.attribute.final" { return true }
        }
        
        return false
    }
    
    private func parseJson() -> [JSONDict] {
        let filePath = "/Dev/source-kitten-doc.json"
        guard
            let url = URL(string: "file://\(filePath)"),
            let data = try? Data(contentsOf: url),
            let object = try? JSONSerialization.jsonObject(with: data, options: []),
            let json = object as? [JSONDict] else { fatalError() }
        
        return json
    }
}
