//
//  ViewController.swift
//  Razzle
//
//  Created by Renata Faria on 04/12/19.
//  Copyright © 2019 Renata Faria. All rights reserved.
//

import UIKit
import Vision
import AVKit
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    var model = animais().model
    var player: AVAudioPlayer?
    var canDetect = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let captureSession = AVCaptureSession()
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        view.layer.addSublayer(previewLayer)
        let newView = UIView()
        newView.frame = self.view.frame
        newView.layer.addSublayer(previewLayer)
        self.view.addSubview(newView)
        self.view.bringSubviewToFront(self.view.viewWithTag(1)!)
        
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
               
               guard let model = try? VNCoreMLModel(for: model) else { return }
               let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
               guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
               guard let firstObservation = results.first else { return }
                   
                let name: String = firstObservation.identifier
                let acc: Int = Int(firstObservation.confidence * 100)
                
                   DispatchQueue.main.async {
                        if acc > 98 && self.canDetect {
                            self.canDetect = false
                            let imagem = UIImage(named: name)
                            self.playSound(name: name)
                            self.showAlert(name: name, image: imagem)
                        }
                   }
                   
               }
               
               try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    
    func playSound(name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else { return }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }

            player.prepareToPlay()
            player.play()

        } catch let error as NSError {
            print(error.description)
        }
    }

    func showAlert(name: String, image: UIImage?=nil) {
        let nameLocalized = animaisNomes[name]?.localized.capitalized ?? "nada"
        let messageLocalized = som[name]?.localized ?? "nada"
        let message = "\(nameLocalized) \(messageLocalized) !!!"
        let showAlert = UIAlertController(title:nameLocalized, message: message, preferredStyle: .alert)

        let imageView = UIImageView(frame: CGRect(x: 10, y: 70, width: 250, height: 200))
        imageView.image = image
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleToFill
        showAlert.view.addSubview(imageView)
        let height = NSLayoutConstraint(item: showAlert.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 350)
        let width = NSLayoutConstraint(item: showAlert.view!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 250)
        showAlert.view.addConstraint(height)
        showAlert.view.addConstraint(width)
        
        showAlert.addAction(UIAlertAction(title: "Próximo animal!".localized, style: .default, handler: { action in
            self.canDetect = true
            showAlert.dismiss(animated: true)
        }))
        self.present(showAlert, animated: true, completion: nil)
    }
    

}
