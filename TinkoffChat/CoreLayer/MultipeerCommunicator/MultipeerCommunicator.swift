//
//  MultipeerCommunicator.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 10/18/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import UIKit
import MultipeerConnectivity

protocol ICommunicator : class {
    func sendMessage(string: String, to userID: String, completionHandler: ((_ success: Bool, _ error: Error?) -> ())?)
    weak var delegate : ICommunicatorDelegate? {get set}
    var online : Bool {get set}
}

class MultipeerCommunicator: NSObject, ICommunicator {

    private var myPeerId : MCPeerID!
    private var browser : MCNearbyServiceBrowser!
    private var advertiser : MCNearbyServiceAdvertiser!
    
    weak var delegate : ICommunicatorDelegate?
    var online : Bool = true
    
    private let tinkoffServiceType = "tinkoff-chat"
    private let myDiscoveryInfo = ["userName" : "m.a.semakova"]
    private var sessions = [String: MCSession]()
    
    
    override init() {
        super.init()
        
        myPeerId = MCPeerID(displayName: UIDevice.current.identifierForVendor!.uuidString)
        
        browser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: tinkoffServiceType)
        browser.delegate = self
        browser.startBrowsingForPeers()
        
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: myDiscoveryInfo, serviceType: tinkoffServiceType)
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
    }
    
    deinit {
        browser.stopBrowsingForPeers()
        advertiser.stopAdvertisingPeer()
    }
    
    func sendMessage(string: String, to userID: String, completionHandler: ((Bool, Error?) -> ())?) {
            let message = ["eventType": "TextMessage", "messageId": generateMessageId(), "text": string]
            
            if JSONSerialization.isValidJSONObject(message) {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: message, options: .prettyPrinted)
                    if let session = sessions[userID] {
                        try session.send(jsonData, toPeers: session.connectedPeers, with: .reliable)
                    }
                } catch {
                    completionHandler?(false, error)
                }
            }
            
            completionHandler?(true, nil)
    }
    
    private func generateMessageId() -> String {
        let string = "\(arc4random_uniform(UINT32_MAX))+\(Date.timeIntervalSinceReferenceDate)+\(arc4random_uniform(UINT32_MAX))".data(using: .utf8)?.base64EncodedString()
        return string!
    }
    
}

// MARK: - Browser Delegate

extension MultipeerCommunicator : MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        let newSession = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .optional)
        newSession.delegate = self
        if !newSession.connectedPeers.contains(peerID) {
            sessions[peerID.displayName] = newSession
            browser.invitePeer(peerID, to: newSession, withContext: nil, timeout: 30)
            delegate?.didFoundUser(userID: peerID.displayName, userName: info?["userName"])
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        sessions.removeValue(forKey: peerID.displayName)
        delegate?.didLostUser(userID: peerID.displayName)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        delegate?.failedToStartAdvertising(error: error)
    }
}

// MARK: - Advertiser Delegate

extension MultipeerCommunicator : MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
        let newSession = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .optional)
        newSession.delegate = self
        if !newSession.connectedPeers.contains(peerID) {
            sessions[peerID.displayName] = newSession
            invitationHandler(true, newSession)
        } else {
            invitationHandler(false, newSession)
        }
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        delegate?.failedToStartAdvertising(error: error)
    }
}

// MARK: - Session Delegate

extension MultipeerCommunicator : MCSessionDelegate {
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
            let jsonData = try JSONSerialization.jsonObject(with: data as Data, options: [])
            if let messageData = jsonData as? [String: String] {
                delegate?.didReceiveMessage(text: messageData["text"] ?? "", fromUser: peerID.displayName, toUser: myPeerId.displayName)
            } else {
                print("JSON is invalid")
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("CONNECTED")
        case .notConnected:
            print("NOT CONNECTED")
        case .connecting:
            print("CONNECTING")
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }
}
