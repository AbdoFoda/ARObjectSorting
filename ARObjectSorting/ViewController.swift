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
    
    var objects = [Entity]()
    let minDisDiff = Float(0.3)
    let xSpace = Float(0.5)
    let ySpace = Float(0.05)
    let zSpace = Float(0.05)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let horAnchor = AnchorEntity(plane: .horizontal, minimumBounds: [0.2 , 0.2])
        arView.scene.addAnchor(horAnchor)
        
        
        let board = MeshResource.generateBox(width: 1.5, height: 0.040, depth: 0.8)
        
        let boardMaterial = SimpleMaterial(color: .white , isMetallic: true)
        let boardModel = ModelEntity(mesh: board, materials: [boardMaterial])
        boardModel.position = [0,0,0]
        
        horAnchor.addChild(boardModel)
        
        var cancellable: AnyCancellable? = nil
        
        cancellable = ModelEntity.loadModelAsync(named: "1")
            .append(ModelEntity.loadModelAsync(named: "2"))
            .append(ModelEntity.loadModelAsync(named: "3"))
            .collect()
            .sink(receiveCompletion: { (error) in
            print(error)
            cancellable?.cancel()
        }, receiveValue: { (entities) in
            for (index,entity) in entities.enumerated() {
                entity.setScale(SIMD3<Float> (0.006,0.006,0.006), relativeTo: boardModel)
                entity.generateCollisionShapes(recursive: true)
                entity.position = [-0.5 + (Float( index) * 0.5)  ,0,0]
                self.objects.append(entity)
                boardModel.addChild(entity)
            }
            swap(&self.objects[0].position,&self.objects[2].position)
            
        })
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.alertWith(title: "تحدي", message: "رتب الأختراعات علي حسب تاريخها")
        
    }
    
    
    var selectedObject : Entity?
    func checkIfWin() -> Bool {
        guard self.objects.count > 1 else {
            return false
        }
        for idx in 1..<objects.count{
            let obj = objects[idx] , prevObj = objects[idx-1]
            let xDiff =  obj.position.x - prevObj.position.x
            let yDiff =  obj.position.y - prevObj.position.y
            let zDiff =  obj.position.z - prevObj.position.z
            print("X Diff\(idx)= \(xDiff)")
            print("Y Diff\(idx) = \(yDiff)")
            print("Z Diff\(idx) = \(zDiff)")

            if      xDiff < minDisDiff || xDiff > xSpace || abs(zDiff) > zDiff  {
                return false
            }
        }
        return true
        
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
                object.position.z += Float(translation.y * 0.0001)
                panGesture.reset()
            }
            if checkIfWin() {
                self.alertWith(title: "مبروك", message: "كسبت ٥٠٠ ميجا بايت من أورانج ان شاء الله")
            }
        case .ended:
            self.selectedObject = nil
            
        default:
            break
        }
        
        
        
        
    }
}
