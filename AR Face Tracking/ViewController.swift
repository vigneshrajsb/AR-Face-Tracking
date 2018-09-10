//
//  ViewController.swift
//  AR Face Tracking
//
//  Created by Vigneshraj Sekar Babu on 9/10/18.
//  Copyright © 2018 Vigneshraj Sekar Babu. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {
    
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        guard ARFaceTrackingConfiguration.isSupported else {
            fatalError("Face Tracking not supported")
        }
        sceneView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let configuration = ARFaceTrackingConfiguration()
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        sceneView.session.pause()
    }
}


extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let device = sceneView.device else { return nil }
        
        let faceGeometry = ARSCNFaceGeometry(device: device)
        let node = SCNNode(geometry: faceGeometry)
        node.geometry?.firstMaterial?.fillMode = .lines
        print(node)
        return node
    }
    
}

