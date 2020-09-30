//
//  ViewController.swift
//  ARObjectSorting
//
//  Created by Abdelrahman Sobhy on 9/30/20.
//  Copyright © 2020 Abdelrahman Sobhy. All rights reserved.
//

import UIKit
import RealityKit
import Combine

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    
    var teapot : Entity?
    var cup : Entity?
    
    var xEps = Float(0.05)
    var yEps = Float(0.5)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let horAnchor = AnchorEntity(plane: .horizontal, minimumBounds: [0.2 , 0.2])
        arView.scene.addAnchor(horAnchor)
        
        
        var cancellable: AnyCancellable? = nil
        
        cancellable = ModelEntity.loadModelAsync(named: "teapot")
            .append(ModelEntity.loadModelAsync(named: "cup_saucer_set"))
            .collect()
            .sink(receiveCompletion: { (error) in
            print(error)
            cancellable?.cancel()
        }, receiveValue: { (entities) in
            var objects = [ModelEntity] ()
            for (index,entity) in entities.enumerated() {
                entity.setScale(SIMD3<Float> (0.004,0.004,0.004), relativeTo: horAnchor)
                entity.generateCollisionShapes(recursive: true)
                entity.position = [Float( index % 2) * 0.5,Float( index % 2) * 0.5,0.1]
                objects.append(entity)
                horAnchor.addChild(entity)
            }
            
            
            self.teapot = objects[0]
            self.cup = objects[1]
            
            
//            entity.setScale(SIMD3<Float> (0.004,0.004,0.004), relativeTo: horAnchor)
//            entity.generateCollisionShapes(recursive: true)
//            entity.position = [0.1,0,0.1]
//            horAnchor.addChild(entity)
        })
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.alertWith(title: "تحدي", message: "تعرف تصب الشاي؟؟!")
        
    }
    
    
    var selectedObject : Entity?
    
    func checkIfWin() -> Bool {
        guard let teapot = self.teapot , let cup = self.cup else {
            return false
        }
        return (cup.position.x - teapot.position.x <= xEps) && (cup.position.x - teapot.position.x >= 0)
        &&  (teapot.position.y - cup.position.y <= yEps) && (teapot.position.y - cup.position.y >= 0)
    }
    @IBAction func handlePan(_ panGesture: UIPanGestureRecognizer) {
        let panLocation = panGesture.location(in: arView)
        
        switch panGesture.state {
        case .began:
            if let object = arView.entity(at: panLocation){
                self.selectedObject = object
                print("object selected!!")
            }
        case .changed:
            let translation = panGesture.translation(in: arView)
            if let object = selectedObject {
                print("object should move!")
                object.position.x += Float(translation.x * 0.0001)
                object.position.y -= Float(translation.y * 0.0001)
                panGesture.reset()
            }
            print(teapot?.position)
            print(cup?.position)
            if checkIfWin() {
                self.alertWith(title: "مبروك", message: "صبيت الشاااي!")
            }
        case .ended:
            self.selectedObject = nil
            
        default:
            break
        }
        
        
        
        
    }
}
