//
//  ChatModels.swift
//  UnI
//
// Created by SDC-USER on 11/12/25.
//

import MessageKit
import Foundation
import UIKit
import AVFAudio

struct Sender: SenderType, Codable {
    let senderId: String
    let displayName: String
}

struct ChatMessage: MessageType {
    var sender: any MessageKit.SenderType
    let messageId: String
    let sentDate: Date
    let kind: MessageKind
    
    init(sender: any MessageKit.SenderType, messageId: String, sentDate: Date, kind: MessageKind) {
        self.sender = sender
        self.messageId = messageId
        self.sentDate = sentDate
        self.kind = kind
    }
}

struct ImageMediaItem: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(image: UIImage) {
        self.image = image
        self.size = CGSize(width: 240, height: 240) // Default display size
        self.placeholderImage = UIImage()
    }
}

struct ChatAudioItem: AudioItem {

    let url: URL
    let duration: Float
    let size: CGSize

    init(url: URL) {
        self.url = url

        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback)
        try? session.setActive(true)

        let player = try? AVAudioPlayer(contentsOf: url)
        self.duration = Float(player?.duration ?? 1.0) 

        self.size = CGSize(width: 160, height: 40)
    }
}


