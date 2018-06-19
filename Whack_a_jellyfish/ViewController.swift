//
//  ViewController.swift
//  Whack_a_jellyfish
//
//  Created by Julian Lechuga Lopez on 19/6/18.
//  Copyright © 2018 Julian Lechuga Lopez. All rights reserved.
//

import UIKit
import ARKit
class ViewController: UIViewController {

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
    }
    @IBAction func reset(_ sender: Any) {
    }
    func addNode(){
        let node = SCNNode(geometry: SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0))
        node.position = SCNVector3(0,0,-1)
        self.sceneView.scene.rootNode.addChildNode(node)
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
            let geometry = results.node.geometry
            print(geometry)
        }
        
    }
}

