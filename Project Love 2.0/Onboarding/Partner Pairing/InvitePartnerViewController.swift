import UIKit

class InvitePartnerViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var codeCollectionView: UICollectionView!
    @IBOutlet weak var shareMyCodeButton: UIButton!
    @IBOutlet weak var copyCodeButton: UIButton! // Connect this to your 'Tap to Copy' button
    
    // MARK: - Properties
    let codeArray = ["D", "K", "1", "T", "D", "8"]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
//        setupUI()
    }

    // MARK: - Setup Methods
    private func setupCollectionView() {
        let nib = UINib(nibName: "ShareCodeCollectionViewCell", bundle: nil)
        codeCollectionView.register(nib, forCellWithReuseIdentifier: "CodeCell")
        
        codeCollectionView.delegate = self
        codeCollectionView.dataSource = self
        
        if let layout = codeCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 12
            layout.minimumLineSpacing = 12
        }
    }
    
//    private func setupUI() {
//        shareMyCodeButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
//        copyCodeButton.setImage(UIImage(systemName: "doc.on.doc"), for: .normal)
//    }

    // MARK: - Actions

    @IBAction func taptocopyButton(_ sender: UIButton) {
        UIPasteboard.general.string = codeArray.joined()
        
        // Haptic feedback
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
        // Quick pulse animation
        UIView.animate(withDuration: 0.1, animations: { sender.alpha = 0.5 }) { _ in
            UIView.animate(withDuration: 0.1) { sender.alpha = 1.0 }
        }
    }

    @IBAction func shareMyCodePressed(_ sender: Any) {
        let code = codeArray.joined()
        let activityVC = UIActivityViewController(activityItems: ["My partner code: \(code)"], applicationActivities: nil)
        
        // iPhone only: just present it
        present(activityVC, animated: true)
    }

    @IBAction func enterPartnerCodeButton(_ sender: Any) {
        navigateToEnterCode()
    }

    // MARK: - Navigation
    func navigateToEnterCode() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "EnterCodeVC") {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - CollectionView Extensions
extension InvitePartnerViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return codeArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CodeCell", for: indexPath) as! ShareCodeCollectionViewCell
        cell.CodeLabel.text = codeArray[indexPath.item]
        return cell
    }
}
