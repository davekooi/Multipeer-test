//
//  ViewController.swift
//  Multipeer test
//
//  Created by David Kooistra on 1/7/18.
//  Copyright © 2018 David. All rights reserved.
//

import UIKit
import MultipeerConnectivity

extension UIView {
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
}

class ViewController: UIViewController, MCSessionDelegate, MCBrowserViewControllerDelegate {
    
    @IBOutlet weak var messageDisplayLabel: UITextView!
    
    @IBOutlet weak var messageInput: UITextField!
    
    var peerID:MCPeerID!
    var mcSession:MCSession!
    var mcAdvertiserAssistant:MCAdvertiserAssistant!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConnectivity()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func setupConnectivity() {
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clearChat(_ sender: Any) {
        self.messageDisplayLabel.text = "Chat:"
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        requestSendMessage(messageInput.text!)
        messageInput.text = ""
    }
    
    func requestSendMessage(_ message:String) {
        if mcSession.connectedPeers.count > 0 {
            if let myData = message.data(using: .utf8) {
                do {
                    try mcSession.send(myData, toPeers: mcSession.connectedPeers, with: .reliable)
                } catch {
                    fatalError("Could not send message")
                }
                messageDisplayLabel.text = messageDisplayLabel.text + "\n" + message
            }
        } else {
            print("Not connected to other devices")
        }
    }
    
    @IBAction func showConnectivityAction(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Connect devices", message: "Do you want to host or join session?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Host Session", style: .default, handler: { (action:UIAlertAction) in
            self.mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "Dave-type", discoveryInfo: nil, session: self.mcSession)
            self.mcAdvertiserAssistant.start()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Join Session", style: .default, handler: { (action:UIAlertAction) in
            let mcBrowser = MCBrowserViewController(serviceType: "Dave-type", session: self.mcSession)
            mcBrowser.delegate = self
            self.present(mcBrowser, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    // MARK: - MC Delegate Functions
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
        case MCSessionState.notConnected:
            print("Not Connected: \(peerID.displayName)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print(data.base64EncodedString())
        DispatchQueue.main.async {
            self.messageDisplayLabel.text = self.messageDisplayLabel.text + "\n" + String(data: data, encoding: String.Encoding.utf8)! as String!
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
}

