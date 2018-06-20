//
//  ViewController.swift
//  Whack_a_jellyfish
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
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        self.sceneView.session.run(configuration)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func play(_ sender: Any) {
        self.addNode()
        self.play.isEnabled = false
        self.setTimer()
    }
    @IBAction func reset(_ sender: Any) {
    }
    
    func addNode(){
        let jellyFishScene = SCNScene(named: "art.scnassets/Jellyfish.scn")
        let jellyFishNode = jellyFishScene?.rootNode.childNode(withName: "Jellyfish", recursively: false)
        let x = randomNumbers(firstNum: -1, secondNum: 1)
        let y = randomNumbers(firstNum: -0.5, secondNum: 0.5)
        let z = randomNumbers(firstNum: -1, secondNum: 1)
        jellyFishNode?.position = SCNVector3(x,y,z)
        self.sceneView.scene.rootNode.addChildNode(jellyFishNode!)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer){
        let sceneViewTappedOn = sender.view as! SCNView
        let touchCoordinates = sender.location(in:sceneViewTappedOn)
        let hitTest = sceneViewTappedOn.hitTest(touchCoordinates)
        if hitTest.isEmpty{
            print("Didnt touch anything")
        }
        else{
            let results = hitTest.first!
            let node = results.node
            if node.animationKeys.isEmpty{
                SCNTransaction.begin()
                self.animateNode(node: node)
                SCNTransaction.completionBlock = {
                    node.removeFromParentNode()
                    self.addNode()
                }
                SCNTransaction.commit()
            }
        }
        
    }
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
            return .continue
        }
    }
}



