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


struct  CollisionCategory: OptionSet {
    public let rawValue: Int
    
    public static let laser = CollisionCategory(rawValue: 1 << 1)
    public static let fighter = CollisionCategory(rawValue: 1 << 2)
}

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {

    @IBOutlet var sceneView: ARSCNView!

    public var tieFighter: SCNNode = SCNScene(named: "art.scnassets/Tie.scn")!.rootNode.childNodes[0]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the view's delegate
        sceneView.delegate = self

        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true

        // Set the scene to the view
        sceneView.scene = SCNScene()
        sceneView.autoenablesDefaultLighting = true
        
        sceneView.scene.physicsWorld.contactDelegate = self
        addNewTieFighter()
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        contact.nodeA.removeFromParentNode()
        contact.nodeB.removeFromParentNode()
        playExplosionSound()
        
        addNewTieFighter()
    }

    func addNewTieFighter() {
        let fighter = tieFighter.clone()
        let posX = Float.random(in: -1...1)
        let posY = Float.random(in: -1...1)
        fighter.position = SCNVector3(posX, posY, -10)
        
        fighter.physicsBody = SCNPhysicsBody.dynamic()
        fighter.physicsBody?.isAffectedByGravity = false
        fighter.physicsBody?.categoryBitMask = CollisionCategory.fighter.rawValue
        fighter.physicsBody?.contactTestBitMask = CollisionCategory.laser.rawValue

        sceneView.scene.rootNode.addChildNode(fighter)
        animate(fighter: fighter)
    }

    func playLazerSound() {
        Sound.play(file: "Laser.mp3")
    }
    
    func playExplosionSound() {
        Sound.play(file: "Explosion.mp3")
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
        
        laser.physicsBody?.categoryBitMask = CollisionCategory.laser.rawValue
        laser.physicsBody?.contactTestBitMask = CollisionCategory.fighter.rawValue
        laser.physicsBody?.collisionBitMask = CollisionCategory.fighter.rawValue
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

    private func animate(fighter: SCNNode) {
        var targetPosition = fighter.position
        targetPosition.z = -1
        let action = SCNAction.move(to: targetPosition, duration: 1)
        action.timingMode = .easeInEaseOut
        fighter.runAction(action)
        fighter.opacity = 0
        fighter.runAction(SCNAction.fadeOpacity(to: 1, duration: 1))
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
