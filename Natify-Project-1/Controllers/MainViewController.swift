//
//  MainViewController.swift
//  Natify-Project-1
//
//  Created by Nazar on 17.02.2026.
//


import UIKit
import GoogleMaps

class MainViewController: UIViewController {
    
    private var places: [Place] = []
    private var currentLocation: CLLocation?
    
    private let apiKey = "AIzaSyBtQ6Gy68SsOIvWdsfhm7EvWTHSfaG-XmQ"
  
    
    init() {
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}
