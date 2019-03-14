//
//  ViewController.swift
//  My3dGame
//
//  Created by Adil Bougamza on 14/03/2019.
//  Copyright © 2019 Adil Bougamza. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import SwiftySound

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
//        scene.rootNode.position.z = -10 // 10 meteres down
        
//        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = SCNScene()
    }
    
    func playLazerSound() {
        Sound.play(file: "Laser.mp3")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
//        let touch = touches.first!
//        let location = touch.location(in: view)
        
        let node = SCNNode()
        
        let box = SCNBox(width: 0.1, height: 0.1, length: 2, chamferRadius: 0)
        box.firstMaterial?.diffuse.contents = UIColor.red
        box.firstMaterial?.lightingModel = .constant
        
        node.geometry = box
        node.opacity = 0.5
        
        if let pov = sceneView.pointOfView {
            node.position = pov.position
            node.position.y -= 0.3
            node.eulerAngles = pov.eulerAngles
        }
        
        
        addPhysics(node)
        animate(laser: node)
        playLazerSound()
        sceneView.scene.rootNode.addChildNode(node)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            node.removeFromParentNode()
        }
    }
    
    private func addPhysics(_ laser: SCNNode) {
        let shape = SCNPhysicsShape(geometry: laser.geometry!, options: nil)
        laser.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        laser.physicsBody?.isAffectedByGravity = false
    }
    
    private func animate(laser: SCNNode) {
        guard let frame = self.sceneView.session.currentFrame else {
            return
        }
        
        let matrix = SCNMatrix4(frame.camera.transform)
        let speed: Float = -5
        let direction = SCNVector3(speed * matrix.m31, speed * matrix.m32, speed * matrix.m33)
        laser.physicsBody?.applyForce(direction, asImpulse: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
