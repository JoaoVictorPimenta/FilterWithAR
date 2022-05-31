//
//  ViewController.swift
//  FilterWithAR
//
//  Created by João Victor Ferreira Pimenta on 31/05/22.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var labelView: UIView!
    
    @IBOutlet weak var faceLabel: UILabel!
    //variável para popular a label
    var analysis = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //arrendonamento da Label
        labelView.layer.cornerRadius = 10
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        //verificação de aceso a camera e compatibilidade
        guard ARFaceTrackingConfiguration.isSupported
        else {
            fatalError("Facetracking não suportado.")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARFaceTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - func renderer com nodeFor
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        if let device = sceneView.device {
            let faceMeshGeometry = ARSCNFaceGeometry(device: device)
            let node = SCNNode(geometry: faceMeshGeometry)
            node.geometry?.firstMaterial?.fillMode = .lines
            //adicionar um node com imagem acima do node ja existe
            
            return node
        } else {
            fatalError("Nenhum dispositivo encontrado.")
        }
    }
    
    // MARK: - func renderer com didUpdate
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let faceAnchor = anchor as? ARFaceAnchor, let faceGeometry = node.geometry as? ARSCNFaceGeometry {
            faceGeometry.update(from: faceAnchor.geometry)
            
            expression(anchor: faceAnchor)
            DispatchQueue.main.async {
                self.faceLabel.text = self.analysis
            }
        }
        
        
    }
    //MANIPULAÇÃO DAS EXPRESSÕES
    func expression(anchor: ARFaceAnchor) {
        let cheekPuff = anchor.blendShapes[.cheekPuff]
        let tongue = anchor.blendShapes[.tongueOut]
        self.analysis = ""
        
        if let cheekPuffValeue = cheekPuff?.decimalValue {
            if cheekPuffValeue > 0.1 {
                self.analysis += "Bochechas, bochechas, bochechas."
            }
        }
        
        if let tongueValue = tongue?.decimalValue {
            if tongueValue > 0.1 {
                self.analysis += "línguas, línguas, línguas."
            }
        }
    }
}
