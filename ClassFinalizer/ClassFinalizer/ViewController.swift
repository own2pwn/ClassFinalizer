//
//  ViewController.swift
//  ClassFinalizer
//
//  Created by Evgeniy on 03.06.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Cocoa

final class ViewController: NSViewController {

    // MARK: - Outlets
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScreen()
    }
    
    // MARK: - Members
    
    // MARK: - Methods
    
    private func setupScreen() {
        setup()
    }
    
    private func setup() {
        let setup = [setColors]
        setup.forEach { $0() }
    }
    
    private func setColors() {
    }
}
