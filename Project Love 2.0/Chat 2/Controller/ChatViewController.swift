//
//  ChatViewController.swift
//  UnI
//
//  Created by SDC-USER on 11/12/25.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import PhotosUI
import AVFoundation


class ChatViewController: MessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
    var pendingImages: [UIImage] = []
    let currentUser = Sender(
        senderId: "self", displayName: "Me"
    )
    let otherUser = Sender(
        senderId: "other", displayName: "User"
    )
    
    var sampleMessages: [ChatMessage] = []
    
    //for voice recording //properties
    var audioRecorder: AVAudioRecorder?
    var audioFileURL: URL?

    @IBOutlet weak var profileHeaderView: UIView!
    
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    
    @IBOutlet weak var profileNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Pushing messages down so the header is visible
        messagesCollectionView.contentInset.top = 100
        messagesCollectionView.scrollIndicatorInsets.top = 100
        
        // Bringing header to front otherwise messages overlap
        view.bringSubviewToFront(profileHeaderView)

        //styling the headerprofile
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
        profileNameLabel.text = "Ashley"
        
        messagesCollectionView.backgroundColor = .appBackground
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
        
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem()
        
        let plusButton = InputBarButtonItem()
        plusButton.setSize(
            CGSize(
                width: 30, height: 30
            ), animated: true
        )
        plusButton.setTitle(
            "+", for: .normal
        )
        
        plusButton.onTouchUpInside{
            [
                weak self
            ] item in
            self?.showActions()
        }

        messageInputBar.setLeftStackViewWidthConstant(
            to: 36, animated: true
        )
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setStackViewItems(
            [
                plusButton
            ], forStack: .left, animated: true
        )
        
        configureInputBar()
        loadShortActivityChat()
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem()

        
        //hide keyboard when tapping anywhere
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false   // So table view still works
        messagesCollectionView.addGestureRecognizer(tap)
        
        //Hide keyboard when user drags the chat
        messagesCollectionView.delegate = self


    }
    @objc func dismissKeyboard() {
        messageInputBar.inputTextView.resignFirstResponder()
    }

    func loadShortActivityChat() {
        sampleMessages = [
            ChatMessage(
                sender: otherUser,
                messageId: UUID().uuidString,
                sentDate: Date().addingTimeInterval(-1800),
                kind: .text("Today felt exhausting 😮‍💨")
            ),
            ChatMessage(
                sender: currentUser,
                messageId: UUID().uuidString,
                sentDate: Date().addingTimeInterval(-1700),
                kind: .text("Yeah… same here.")
            ),
            ChatMessage(
                sender: otherUser,
                messageId: UUID().uuidString,
                sentDate: Date().addingTimeInterval(-1600),
                kind: .text("Maybe we should try that Chill & Glow Sesh tonight?")
            ),
            ChatMessage(
                sender: currentUser,
                messageId: UUID().uuidString,
                sentDate: Date().addingTimeInterval(-1500),
                kind: .text("That actually sounds perfect 🕯️✨")
            )
        ]
    }
    func configureInputBar() {
        // 1. Set the delegate so we know when text changes
        messageInputBar.delegate = self
        
        // 2. Clear the default Send button initially
        messageInputBar.setStackViewItems([micButton], forStack: .right, animated: false)
        
        // 3. Stylize the Input bar
        messageInputBar.setRightStackViewWidthConstant(to: 38, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
    
    func showActions() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // 1. Camera Action
        let cameraImage = UIImage(systemName: "camera")?.withRenderingMode(.alwaysOriginal)
        let sendPhotoAction = UIAlertAction(title: "Open Camera", style: .default) { [weak self] _ in
            self?.openCamera()
        }
        sendPhotoAction.setValue(cameraImage, forKey: "image")
        alert.addAction(sendPhotoAction)
        
        // 2. Gallery Action
        let galleryImage = UIImage(systemName: "photo.stack")?.withRenderingMode(.alwaysOriginal)
        let openGalleryAction = UIAlertAction(title: "Open Gallery", style: .default) { [weak self] _ in
            self?.openGallery()
        }
        openGalleryAction.setValue(galleryImage, forKey: "image")
        alert.addAction(openGalleryAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
        
        
    }
    
    func backgroundColor(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) -> UIColor {
        
        // If the message was sent by you → purple
        if message.sender.senderId == currentUser.senderId {
            return UIColor.systemIndigo
        }
        
        // Incoming messages → default gray
        return UIColor.systemGray5
    }

    func textColor(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) -> UIColor {
        if message.sender.senderId == currentUser.senderId {
            return .white
        }
        return .label
    }

    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera
            picker.allowsEditing = false
       self.present(picker, animated: true, completion: nil)
        } else {
            print("Camera not available (simulators don't have cameras)")
        }
    }
    
    func openGallery() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = 0   // unlimited → Done(count)

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    // Helper to send the photo message
    func sendPhoto(_ image: UIImage) {
        let mediaItem = ImageMediaItem(image: image)
        
        let newMessage = ChatMessage(
    sender: currentUser,
    messageId: UUID().uuidString,
    sentDate: Date(),
    kind: .photo(mediaItem) // <--- Using .photo instead of .text
        )
        
        sampleMessages.append(newMessage)
        // Ensure you update your sampleMessages if you are using that as a backing store
        // sampleMessages.append(newMessage)
        
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem(animated: true)
    }
    
    // ... inside ChatViewController
    func showPhotoSentPopover(count: Int) {

        let message: String

        if count == 1 {
            message = "Photo sent successfully"
        } else {
            message = "\(count) photos sent successfully"
        }

        let alert = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .actionSheet
        )

        present(alert, animated: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            alert.dismiss(animated: true)
        }
    }


    // The Walkie-Talkie Button
    lazy var micButton: InputBarButtonItem = {
        let item = InputBarButtonItem()
        item.image = UIImage(systemName: "mic.fill")
        item.tintColor = .systemGray
        item.setSize(CGSize(width: 36, height: 36), animated: false)
        
        // Add the gesture targets
        item.addTarget(self, action: #selector(startRecording), for: .touchDown)
        item.addTarget(self, action: #selector(stopAndSendRecording), for: .touchUpInside)
        item.addTarget(self, action: #selector(cancelRecording), for: .touchUpOutside)
        
        return item
    }()
    
    @objc func startRecording() {

        // 1. Request microphone permission
        AVAudioSession.sharedInstance().requestRecordPermission { allowed in
            if !allowed {
                print("Microphone access denied")
                return
            }
        }

        // 2. Prepare audio session
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .default)
        try? session.setActive(true)

        // 3. Create file path
        let filename = UUID().uuidString + ".m4a"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        audioFileURL = url

        // 4. Recorder settings
        let settings: [String : Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        // 5. Start recording
        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.record()

            print("Started recording at:", url)
        } catch {
            print("Could not start recording:", error)
        }

        // UI feedback
        micButton.tintColor = .systemRed
        messageInputBar.inputTextView.placeholder = "Recording..."
    }


    @objc func stopAndSendRecording() {

        print("Stopped recording")

        // Stop recorder
        audioRecorder?.stop()

        guard let url = audioFileURL else {
            print("No audio file available")
            return
        }

        print("Sending voice note:", url)

        // Wrap into audio item
        let audioItem = ChatAudioItem(url: url)

        // Build MessageKit message
        let message = ChatMessage(
            sender: currentUser,
   messageId: UUID().uuidString,
            sentDate: Date(),
            kind: .audio(audioItem)
        )

        // Add to array
        sampleMessages.append(message)

        // Update UI
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem(animated: true)

        resetMicUI()
    }



    @objc func cancelRecording() {
        print("Recording cancelled.")
        audioRecorder?.stop()
        
        if let url = audioFileURL {
            try? FileManager.default.removeItem(at: url)
        }
        resetMicUI()
    }

    
    func resetMicUI() {
        micButton.tintColor = .systemGray
        messageInputBar.inputTextView.placeholder = "Aa"
    }
    

    

   }

   extension ChatViewController: MessagesDataSource{
       var currentSender: any MessageKit.SenderType {
           return currentUser
       }
       
       func numberOfSections(
        in messagesCollectionView: MessagesCollectionView
       ) -> Int {
           return sampleMessages.count
       }
       
       func messageForItem(
        at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView
       ) -> any MessageType {
           return sampleMessages[indexPath.section]
       }
   }

   extension ChatViewController: MessagesLayoutDelegate{}
   extension ChatViewController: MessagesDisplayDelegate{
       func configureAvatarView(
        _ avatarView: AvatarView,
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
       ) {
           let senderId = message.sender.senderId
           
           if senderId == currentUser.senderId {
               avatarView.image = UIImage(named: "myImage")        // your photo
           } else {
               avatarView.image = UIImage(named: "herImage")       // her photo
   }
       }
   }

   //keyboard scrolling
   extension ChatViewController {
       override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
           messageInputBar.inputTextView.resignFirstResponder()
       }
   }



   extension ChatViewController: InputBarAccessoryViewDelegate {
       func inputBar(_ inputBar: InputBarAccessoryView,
                     didPressSendButtonWith text: String) {

           // 1️⃣ Send queued images first
           for image in pendingImages {
       let message = ChatMessage(
        sender: currentUser,
        messageId: UUID().uuidString,
        sentDate: Date(),
        kind: .photo(ImageMediaItem(image: image))
       )
               sampleMessages.append(message)
           }

           pendingImages.removeAll()

           // 2️⃣ Send text if any
           let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
           if !trimmed.isEmpty {
               let message = ChatMessage(
                sender: currentUser,
                messageId: UUID().uuidString,
                sentDate: Date(),
                kind: .text(trimmed)
               )
                sampleMessages.append(message)
           }

           inputBar.inputTextView.text = ""
           messagesCollectionView.reloadData()
           messagesCollectionView.scrollToLastItem(animated: true)
       }
       
       func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
           
           if text.isEmpty {
               // Text is empty -> Show Mic Button
               inputBar.setStackViewItems([micButton], forStack: .right, animated: true)
           } else {
               // User is typing -> Show Send Button
               inputBar.setStackViewItems([inputBar.sendButton], forStack: .right, animated: true)
           }
       }
   }

   extension ChatViewController {
       func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
           picker.dismiss(animated: true)
           
           if let image = info[.originalImage] as? UIImage {
               self.sendPhoto(image)
           }
       }
       
       func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
           picker.dismiss(animated: true)
       }
   }

   extension ChatViewController {
       func picker(_ picker: PHPickerViewController,
                   didFinishPicking results: [PHPickerResult]) {

           picker.dismiss(animated: true)
           guard !results.isEmpty else { return }

           let group = DispatchGroup()

           for result in results {
               let provider = result.itemProvider

               if provider.canLoadObject(ofClass: UIImage.self) {
                   group.enter()
                   provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
                       defer { group.leave() }

                       guard let self = self,
                             let image = object as? UIImage else { return }

                       let message = ChatMessage(
                           sender: self.currentUser,
                           messageId: UUID().uuidString,
                           sentDate: Date(),
                           kind: .photo(ImageMediaItem(image: image))
                       )

                       self.sampleMessages.append(message)
                   }
               }
           }

           group.notify(queue: .main) {
               self.messagesCollectionView.reloadData()
               self.messagesCollectionView.scrollToLastItem(animated: true)

               self.showPhotoSentPopover(count: results.count)
           }

   }
       func openPhotoPicker() {
           var config = PHPickerConfiguration(photoLibrary: .shared())
           config.filter = .images
           config.selectionLimit = 0   // unlimited → enables count on Done

           let picker = PHPickerViewController(configuration: config)
           picker.delegate = self
           present(picker, animated: true)
       }
   }
