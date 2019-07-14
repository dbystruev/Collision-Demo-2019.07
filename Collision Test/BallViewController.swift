//
//  BallViewController.swift
//  Collision Test
//
//  Created by Denis Bystruev on 14/07/2019.
//  Copyright © 2019 Denis Bystruev. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class BallViewController: UIViewController {
    
    // MARK: - Properties
    static let ballInitialPosition = SCNVector3(x: 0, y: 2, z: 0)
    
    var sceneView: SCNView? {
        return view as? SCNView
    }
    
    var rootNode: SCNNode? {
        return sceneView?.scene?.rootNode
    }
    
    // MARK: - UIViewController Properties
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    // MARK: - UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a scene view
        createSceneView()
        
        // create and add a ball to the scene
        createBall()
        
        // create and add contact boxes to the scene
        createContactNode(named: "ContactBottom", y: -1)
        createContactNode(named: "ContactTop", y: 1)
        
        // create and add a camera to the scene
        createCamera(z: 5)
        
        // create and add lights to the scene
        createLights(x: 0, y: 10, z: 10)
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView?.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Custom Methods
    func createBall(at position: SCNVector3 = ballInitialPosition) {
        let ball = SCNSphere(radius: 0.25)
        ball.firstMaterial?.diffuse.contents = UIColor.orange
        let node = SCNNode(geometry: ball)
        node.name = "Ball"
        node.position = position
        rootNode?.addChildNode(node)
    }
    
    func createContactNode(named name: String, x: Float = 0, y: Float = 0, z: Float = 0) {
        let box = SCNBox(width: 1, height: 0.1, length: 1, chamferRadius: 1)
        let node = SCNNode(geometry: box)
        node.name = name
        node.opacity = 0.9999999
        node.position = SCNVector3(x, y, z)
        rootNode?.addChildNode(node)
        
        // add physics body
        let shape = SCNPhysicsShape(node: node)
        let body = SCNPhysicsBody(type: .static, shape: shape)
        body.categoryBitMask = 0
        body.contactTestBitMask = 1
        body.collisionBitMask = 1
        node.physicsBody = body
    }
    
    func createCamera(x: Float = 0, y: Float = 0, z: Float = 0) {
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        rootNode?.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: x, y: y, z: z)
    }
    
    func createLights(x: Float = 0, y: Float = 0, z: Float = 0) {
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: x, y: y, z: z)
        rootNode?.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        rootNode?.addChildNode(ambientLightNode)
    }
    
    func createSceneView() {
        // allows the user to manipulate the camera
        sceneView?.allowsCameraControl = true
        
        // configure the view
        sceneView?.backgroundColor = UIColor.black
        
        // create new scene
        let scene = SCNScene()
        scene.physicsWorld.contactDelegate = self
        sceneView?.scene = scene
        
        // show statistics such as fps and timing information
        sceneView?.showsStatistics = true
    }
    
    // MARK: - Actions
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // check what nodes are tapped
        let point = gestureRecognize.location(in: sceneView)
        guard let hitResult = sceneView?.hitTest(point).first else { return }
        guard let nodeName = hitResult.node.name else { return }
        
        switch nodeName {
            
        case "Ball":
            // retrieve the ball
            guard let ballNode = rootNode?.childNode(withName: "Ball", recursively: true) else { return }
            let shape = SCNPhysicsShape(node: ballNode)
            let body = SCNPhysicsBody(type: .dynamic, shape: shape)
            body.categoryBitMask = 1
            ballNode.physicsBody = body
            
            // move ball to the start after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                ballNode.physicsBody = nil
                ballNode.position = SCNVector3()
                ballNode.position = BallViewController.ballInitialPosition
            }
            
        case let name where name.hasPrefix("Contact"):
            // retrieve the contact node
            guard let contactNode = rootNode?.childNode(withName: name, recursively: true) else { return }
            contactNode.opacity = 1 - contactNode.opacity
            
        default:
            return
            
        }
    }
}

// MARK: - SCNPhysicsContactDelegate
extension BallViewController: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        print(#line, #function, contact.nodeA, contact.nodeB)
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didUpdate contact: SCNPhysicsContact) {
        print(#line, #function, contact.nodeA, contact.nodeB)
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        print(#line, #function, contact.nodeA, contact.nodeB)
    }
}
