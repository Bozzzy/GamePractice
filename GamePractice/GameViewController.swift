//
//  GameViewController.swift
//  GamePractice
//
//  Created by Валерий Богунов on 05.10.2020.
//  Copyright © 2020 Валерий Богунов. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {

    // create a new scene
//    let scene = SCNScene(named: "art.scnassets/ship.scn")!

    // MARK: - Outlets
    var label = UILabel()
    
    // MARK: - Properies
    var ship: SCNNode!
    var duration: TimeInterval = 5
    var score  = 0 {
        didSet {
            label.frame = CGRect(x: 0, y: 0, width: scnView.frame.width, height: 100)
            label.text = "Score: \(score)"
        }
    }
    var state = 0 {
        didSet {
            if state == 1 {
                score = 0
                // add ship
                ship = getShip()
                // get ship
                addShip()
            }
            if state == 2 {
                label.frame = CGRect(x: 0, y: 0, width: scnView.frame.width, height: scnView.frame.height)
                self.label.text = "Score: \(score)\n\nG A M E   O V E R\n\nTap to try again"
                state = 0
            }
        }
    }
    
    // MARK: - Methods
    
    func addLabel() {
        label.text = "* * *"
        label.frame = CGRect(x: 0, y: 0, width: scnView.frame.width, height: scnView.frame.height)
        label.font = UIFont.systemFont(ofSize: 30)
        label.numberOfLines = 7
        label.textAlignment = .center
        scnView.addSubview(label)
    }
    
    
    func spanShip () {
        ship = SCNScene(named: "art.scnassets/ship.scn")!.rootNode.clone()
    }

    func addShip() {
        let x = Int.random(in: -25...25)
        let y = Int.random(in: -25...25)
        let z = -105
        
        ship.position = SCNVector3(x, y, z)
        // look to given point
        ship.look(at: SCNVector3(2*x, 2*y, 2*z))
        // animate the ship
        //ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
        ship.runAction(.move(to: SCNVector3(), duration: duration)) {
            self.state = 2
            self.ship.removeFromParentNode()
            print(#line, #function, "game over killed by ship \(self.score)")
        }
        
        // retrieve sceene
        scnView.scene?.rootNode.addChildNode(ship)
            
    }
  
    func getShip() -> SCNNode {
        // get scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        // get node
        let ship = scene.rootNode.childNode(withName: "ship", recursively: true)!.clone()
        return ship
    }
    
    func removeShip() {
        scnView.scene?.rootNode.childNode(withName: "ship", recursively: true)!.removeFromParentNode()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // retrieve the ship node
//        let ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
        // animate the 3d object
//        ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
                
        removeShip()
        // add score panel

        addLabel()
        label.text = "\n\nC L E A R   S K Y\n\nTap to start "
        state = 0
   }
     
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 && self.state == 1 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.2
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
            //    SCNTransaction.begin()
            //    SCNTransaction.animationDuration = 0.5
            //    material.emission.contents = UIColor.black
            //    SCNTransaction.commit()
                self.score += 1
                self.ship.removeFromParentNode()
                print(#line, #function, "ship \(self.score) has been shot")
                
                self.duration *= 0.95
                self.ship = self.getShip()
                self.addShip()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
        if self.state == 0 {
            self.state = 1
        }
    }
    // MARK: - Computed properties
    
    var scnView: SCNView {
        return self.view as! SCNView
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

}
