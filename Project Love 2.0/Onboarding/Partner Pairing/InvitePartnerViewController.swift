import UIKit
import Supabase

class InvitePartnerViewController: UIViewController {

    @IBOutlet weak var codeCollectionView: UICollectionView!
    @IBOutlet weak var shareMyCodeButton: UIButton!
    @IBOutlet weak var copyCodeButton: UIButton!
    
    var codeArray: [String] = []
    var generatedCode: String = ""
    let supabase = SupabaseManager.shared.client
    var isSavingCode = false
    var realtimeChannel: RealtimeChannelV2?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        
        generatedCode = generateCode()
        codeArray = generatedCode.map { String($0) }
        codeCollectionView.reloadData()
        listenForRelationshipInsert()
        
        Task {
            await savePairingCodeToDB(code: generatedCode)
        }
    }
    func listenForRelationshipInsert() {
        guard let myUserId = SupabaseManager.shared.currentUserId else { return }

        // Use the class property to keep the channel alive
        realtimeChannel = supabase.channel("public:relationships")

        Task {
            // Explicitly use InsertAction.self to solve the "contextual type" error
            let stream = realtimeChannel?.postgresChange(
                InsertAction.self,
                schema: "public",
                table: "relationships"
            )

            await realtimeChannel?.subscribe()

            // Using a loop instead of a closure is cleaner and avoids "extra trailing closure" errors
            if let stream = stream {
                for await payload in stream {
                    let record = payload.record

                    guard
                        let user1String = record["user1_id"]?.stringValue,
                        let user2String = record["user2_id"]?.stringValue,
                        let user1 = UUID(uuidString: user1String),
                        let user2 = UUID(uuidString: user2String)
                    else { continue }

                    // Check if I am part of this new relationship
                    if user1 == myUserId || user2 == myUserId {
                        await MainActor.run {
                            self.showPartnerJoinedAlert()
                        }
                    }
                }
            }
        }
    }
    
    func generateCode() -> String {
        let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in chars.randomElement()! })
    }
    
    func savePairingCodeToDB(code: String) async {
        if isSavingCode { return }
        isSavingCode = true

        guard let userId = SupabaseManager.shared.currentUserId else {
            isSavingCode = false
            return
        }

        do {
            let formatter = ISO8601DateFormatter()
            let expiresAt = formatter.string(from: Date().addingTimeInterval(600))

            let update = PairingCodeUpdate(
                pairing_code: code.uppercased(),
                pairing_code_expires_at: expiresAt
            )

            try await supabase
                .from("users")
                .update(update)
                .eq("user_id", value: userId.uuidString)
                .execute()

            print("Pairing code saved to users table")

        } catch {
            print("Failed to save pairing code:", error)
        }

        isSavingCode = false
    }

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
    

    @IBAction func taptocopyButton(_ sender: UIButton) {
        UIPasteboard.general.string = generatedCode
 
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
        UIView.animate(withDuration: 0.1, animations: { sender.alpha = 0.5 }) { _ in
            UIView.animate(withDuration: 0.1) { sender.alpha = 1.0 }
        }
    }

    @IBAction func shareMyCodePressed(_ sender: Any) {
        let code = codeArray.joined()
        let activityVC = UIActivityViewController(activityItems: ["My partner code: \(code)"], applicationActivities: nil)

        present(activityVC, animated: true)
    }

    @IBAction func enterPartnerCodeButton(_ sender: Any) {
        navigateToEnterCode()
    }

    func navigateToEnterCode() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "EnterCodeVC") {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    func showPartnerJoinedAlert() {
        UserDefaults.standard.set(true, forKey: "hasCompletedPairing")
        let alert = UIAlertController(
            title: "Paired ❤️",
            message: "Your partner has joined!",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Continue", style: .default) { _ in
            
            let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
            
            guard let vc = storyboard.instantiateViewController(withIdentifier: "infoPageViewController") as? infoPageViewController else {
                print("❌ Could not instantiate infoPageViewController")
                return
            }
            
            if let nav = self.navigationController {
                nav.pushViewController(vc, animated: true)
            } else {
                self.present(vc, animated: true)
            }
        })

        self.present(alert, animated: true)
    }
    
    @IBAction func skipTapped(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "didSkipPairing")
        UserDefaults.standard.set(true, forKey: "hasCompletedPairing")
            
            // Stop realtime listener if active
            Task {
                await realtimeChannel?.unsubscribe()
            }
            
            let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
            
            guard let vc = storyboard.instantiateViewController(
                withIdentifier: "infoPageViewController"
            ) as? infoPageViewController else {
                print("❌ Could not instantiate infoPageViewController")
                return
            }
            
            navigationController?.pushViewController(vc, animated: true)
    }
    
}

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
