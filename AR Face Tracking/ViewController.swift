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
    
    let noseOptions = ["👃🏼", "🐽", "💧", " "]
    let eyeOptions = ["👁", "🌕", "🌟", "🔥", "⚽️", "🔎", " "]
    let mouthOptions = ["👄", "👅", "❤️", " "]
    let hatOptions = ["🎓", "🎩", "🧢", "⛑", "👒", " "]
    
    let features = ["nose", "leftEye", "rightEye", "mouth", "hat"]
    let featureIndices = [[9], [1064], [42], [24,25], [20]]
    
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
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: sceneView)
        
        let results = sceneView.hitTest(location, options: nil)
        
        if let result = results.first , let node = result.node as? EmojiNode {
            node.next()
        }
    }
    
    
    func updateFeatures(for node: SCNNode, using anchor: ARFaceAnchor) {
        for (feature,indices) in zip(features, featureIndices) {
        let child = node.childNode(withName: feature, recursively: false) as? EmojiNode
            let vertices = indices.map { anchor.geometry.vertices[$0] }
        
        child?.updatePosition(for: vertices)
            
            switch feature{
            case "leftEye":
                let scaleX = child?.scale.x ?? 1.0
                let eyeBlinkValue = anchor.blendShapes[.eyeBlinkLeft]?.floatValue ?? 0.0
                child?.scale = SCNVector3(scaleX, 1.0 - eyeBlinkValue, 1.0)
            case "rightEye":
                let scaleX = child?.scale.x ?? 1.0
                let eyeblinkValue = anchor.blendShapes[.eyeBlinkRight]?.floatValue ?? 0.0
                child?.scale = SCNVector3(scaleX, 1.0 - eyeblinkValue, 1.0)
            case "mouth":
                let jawOpenValue = anchor.blendShapes[.jawOpen]?.floatValue ?? 0.2
                child?.scale = SCNVector3(1.0, 0.8 + jawOpenValue, 1.0)
            default:
                break
            }
        }
    }
}


extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let faceAnchor = anchor as? ARFaceAnchor, let device = sceneView.device else { return nil }
        
        let faceGeometry = ARSCNFaceGeometry(device: device)
        let node = SCNNode(geometry: faceGeometry)
        node.geometry?.firstMaterial?.fillMode = .lines
        node.geometry?.firstMaterial?.transparency = 0.0
        
        let noseNode = EmojiNode(with: noseOptions)
        noseNode.name = "nose"
        node.addChildNode(noseNode)
        
        let leftEyeNode = EmojiNode(with: eyeOptions)
        leftEyeNode.name = "leftEye"
        leftEyeNode.rotation = SCNVector4(0, 1, 0, GLKMathDegreesToRadians(180.0))
        node.addChildNode(leftEyeNode)
        
        let rightEyeNode = EmojiNode(with: eyeOptions)
        rightEyeNode.name = "rightEye"
        node.addChildNode(rightEyeNode)
        
        let mouthNode = EmojiNode(with: mouthOptions)
        mouthNode.name = "mouth"
        node.addChildNode(mouthNode)
        
        let hatNode = EmojiNode(with: hatOptions)
        hatNode.name = "hat"
        node.addChildNode(hatNode)
        
        updateFeatures(for: node, using: faceAnchor)
        
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        guard let faceAnchor = anchor as? ARFaceAnchor else { return  }
            guard let faceGeometry = node.geometry as? ARSCNFaceGeometry else { return  }
    
    
      faceGeometry.update(from: faceAnchor.geometry)
        updateFeatures(for: node, using: faceAnchor)
}

}


