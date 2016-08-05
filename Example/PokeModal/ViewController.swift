//
//  ViewController.swift
//  PokeModal
//
//  Created by Leonardo Borges Avelino on 08/04/2016.
//  Copyright (c) 2016 Leonardo Borges Avelino. All rights reserved.
//

import UIKit
import PokeModal

class ViewController: UIViewController, PokeModalDelegate {

    var modal: PokeModal? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modal = PokeModal(view: self.view)
        modal?.titleText = "HI ASH"
        modal?.contentText = "I wanna be the very best. Like no one ever was. To catch them is my real test. To train them is my cause"
        modal?.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pokeModalWillHide() {
        print("Hiding modal")
    }
    
    @IBAction func pokebalTapped(sender: AnyObject) {
        modal?.showMenu()
    }
    
}
