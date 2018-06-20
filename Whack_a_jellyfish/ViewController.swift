//
//  ViewController.swift
//  Whack a jellyfish
//
//  Created by Julian Lechuga Lopez on 19/6/18.
//  Copyright © 2018 Julian Lechuga Lopez. All rights reserved.
//

import UIKit
import ARKit
import Each
class ViewController: UIViewController {
    
    var timer = Each(1).seconds
    var countdown = 10
   
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var play: UIButton!
    @IBOutlet weak var sceneView: ARSCNView!
    
    let configuration = ARWorldTrackingConfiguration()
    override func viewDidLoad() {
        super.viewDidLoad()
//        Commented this line because it creates a bug since hitTest detects succes when tapping any axis of the world origin
//        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        self.sceneView.session.run(configuration)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        // Do any additional setup after loading the view, typically from a nib.
    }

//    Play button
    @IBAction func play(_ sender: Any) {
        self.addNode()
        self.play.isEnabled = false
        self.setTimer()
    }
//    Restart button of the game
    @IBAction func reset(_ sender: Any) {
        self.timer.stop()
        self.restoreTimer()
        self.timerLabel.text = "Let's play"
        self.play.isEnabled = true
        
        sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
    }
//    This adds a new node for a Jellyfish in a random position
    func addNode(){
        let jellyFishScene = SCNScene(named: "art.scnassets/Jellyfish.scn")
        let jellyFishNode = jellyFishScene?.rootNode.childNode(withName: "Jellyfish", recursively: false)
        let x = randomNumbers(firstNum: -1, secondNum: 1)
        let y = randomNumbers(firstNum: -0.5, secondNum: 0.5)
        let z = randomNumbers(firstNum: -1, secondNum: 1)
        jellyFishNode?.position = SCNVector3(x,y,z)
        self.sceneView.scene.rootNode.addChildNode(jellyFishNode!)
    }
//    This function detects and handles a tapping in the screen and a SCNNode in the ARSceneKitView
    @objc func handleTap(sender: UITapGestureRecognizer){
        let sceneViewTappedOn = sender.view as! SCNView
        let touchCoordinates = sender.location(in:sceneViewTappedOn)
        let hitTest = sceneViewTappedOn.hitTest(touchCoordinates)
//        This should be updated to detect only the jellyfish-type node so that if anything else is in the view and you tap it it won't be accounted as success
        if hitTest.isEmpty == false{
            if countdown > 0 {
                let results = hitTest.first!
                let node = results.node
                if node.animationKeys.isEmpty{
                    SCNTransaction.begin()
                    self.animateNode(node: node)
                    SCNTransaction.completionBlock = {
                        node.removeFromParentNode()
                        self.addNode()
                        self.restoreTimer()
                    }
                    SCNTransaction.commit()
                }
            }
        }
    }
    
//    Basic animation function for the node, 
    func animateNode(node: SCNNode){
        let spin = CABasicAnimation(keyPath: "position")
        let nodePosition = node.presentation.position
        spin.fromValue = nodePosition
        spin.toValue = SCNVector3(nodePosition.x - 0.2,nodePosition.y - 0.2,nodePosition.z - 0.2)
        spin.duration = 0.1
        spin.autoreverses = true
        spin.repeatCount = 3
        node.addAnimation(spin, forKey: "position")
    }
    
    func randomNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    func setTimer(){
        self.timer.perform { () -> NextStep in
            self.countdown -= 1
            self.timerLabel.text = String(self.countdown)
            if self.countdown == 0 {
                self.timerLabel.text = "Time's up!"
                return .stop
            }
            return .continue
        }
    }
    
    func restoreTimer(){
        self.countdown = 10
        self.timerLabel.text = String(countdown)
    }
}



