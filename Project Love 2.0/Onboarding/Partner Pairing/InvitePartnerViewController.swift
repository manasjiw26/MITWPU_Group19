//
//  InvitePartnerViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 26/11/25.
//

import UIKit

class InvitePartnerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return codeArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CodeCell", for: indexPath) as! ShareCodeCollectionViewCell
        
        cell.CodeLabel.text = codeArray[indexPath.item]
        
        return cell
    }
    
    
    
    @IBOutlet weak var codeCollectionView: UICollectionView!
    
    
    @IBOutlet weak var tapToCopyLabel: UILabel!
    
    
    @IBOutlet weak var shareMyCodeButton: UIButton!
    
    
    @IBOutlet weak var footerLabel: UILabel!
    
    //testing purpose
    let codeArray = ["D", "K", "1", "T", "D", "8"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //making label tappable
        tapToCopyLabel.isUserInteractionEnabled = true
        tapToCopyLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(copyCode)))
        
        
        
        let nib = UINib(nibName: "ShareCodeCollectionViewCell", bundle: nil)
        codeCollectionView.register(nib, forCellWithReuseIdentifier: "CodeCell")
        
        // Setting delegate and dataSource
        codeCollectionView.delegate = self
        codeCollectionView.dataSource = self
        
        // Additional layout
        if let layout = codeCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 12
            layout.minimumLineSpacing = 12
            
            
            
        }
        setupFooterText()
        
    }
    
    @objc func copyCode() {
        let fullCode = codeArray.joined()
        UIPasteboard.general.string = fullCode
        
        // haptic
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // popup animation
        UIView.animate(withDuration: 0.1, animations: {
            self.tapToCopyLabel.alpha = 0.3
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.tapToCopyLabel.alpha = 1.0
            }
        }
    }
    
    
    
    @IBAction func shareMyCodePressed(_ sender: Any) {
        
        let code = codeArray.joined()
        
        // native ios menu
        let activityVC = UIActivityViewController(activityItems: ["My partner code: \(code)"], applicationActivities: nil)
        
        present(activityVC, animated: true)
    }
    
    func setupFooterText() {
        let fullText = "Received an invite? Enter partner’s code"
        let attributedText = NSMutableAttributedString(string: fullText)
        
        let clickableRange = (fullText as NSString).range(of: "Enter partner’s code")
        
        attributedText.addAttribute(.foregroundColor, value: UIColor.black, range: clickableRange)
        attributedText.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: clickableRange)
        
        footerLabel.attributedText = attributedText
        footerLabel.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onFooterTap(_:)))
        footerLabel.addGestureRecognizer(tap)
    }
    
    
    // tap only "enter partner's code"
    
    @objc func onFooterTap(_ gesture: UITapGestureRecognizer) {
        let text = "Received an invite? Enter partner’s code" as NSString
        let targetRange = text.range(of: "Enter partner’s code")
        
        if gesture.didTapAttributedTextInLabel(label: footerLabel, inRange: targetRange) {
            navigateToEnterCode()
        }
        
        
    }
    
    func navigateToEnterCode() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "EnterCodeVC") {
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
}


//This allows detecting taps inside a specific word range inside UILabel
        extension UITapGestureRecognizer {
            func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
                guard let attributedText = label.attributedText else { return false }
                
                let textStorage = NSTextStorage(attributedString: attributedText)
                let layoutManager = NSLayoutManager()
                let textContainer = NSTextContainer(size: .zero)
                
                textContainer.lineFragmentPadding = 0
                textContainer.lineBreakMode = label.lineBreakMode
                textContainer.maximumNumberOfLines = label.numberOfLines
                
                layoutManager.addTextContainer(textContainer)
                textStorage.addLayoutManager(layoutManager)
                
                textContainer.size = label.bounds.size
                
                let location = self.location(in: label)
                let index = layoutManager.characterIndex(for: location, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
                
                return NSLocationInRange(index, targetRange)
            }
        }
        
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


