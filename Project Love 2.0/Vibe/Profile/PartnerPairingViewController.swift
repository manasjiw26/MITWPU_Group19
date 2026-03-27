//
//  PartnerPairingViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 17/02/26.
//

import UIKit
import Supabase

class PartnerPairingViewController: UIViewController {

    @IBOutlet var sharedCodeCollectionView: UICollectionView!
    @IBOutlet var enterCodeCollectionView: UICollectionView!
    @IBOutlet var shareInviteButton: UIButton!
    @IBOutlet var pairNowButton: UIButton!
    @IBOutlet var hiddenTextField: UITextField!

    // MARK: - Properties

    var shareCodeArray: [String] = []          // Live code from Supabase (no more hardcoded)
    var enteredCode: String = ""
    let maxDigits = 6
    var generatedCode: String = ""

    let supabase = SupabaseManager.shared.client
    var isSavingCode = false
    var realtimeChannel: RealtimeChannelV2?
    let spinner = UIActivityIndicatorView(style: .large)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground

        setupButtons()
        setupCollectionViews()
        setupTextField()
        setupTapToFocus()
        setupSpinner()

        // Generate a real pairing code and save it to Supabase
        generatedCode = generateCode()
        shareCodeArray = generatedCode.map { String($0) }
        sharedCodeCollectionView.reloadData()

        // Start listening for a partner to join via this code
        listenForRelationshipInsert()

        Task {
            await savePairingCodeToDB(code: generatedCode)
        }
    }

    deinit {
        Task { [weak channel = realtimeChannel] in
            await channel?.unsubscribe()
        }
    }

    // MARK: - Setup

    func setupButtons() {
        shareInviteButton.configuration = .glass()
        shareInviteButton.setTitle("Share my code", for: .normal)

        pairNowButton.configuration = .glass()
        pairNowButton.setTitle("Pair now", for: .normal)
    }

    func setupCollectionViews() {
        sharedCodeCollectionView.register(
            UINib(nibName: "ShareCodeCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "CodeCell"
        )

        enterCodeCollectionView.register(
            UINib(nibName: "EnterCodeCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "EnterCodeCell"
        )

        sharedCodeCollectionView.delegate = self
        sharedCodeCollectionView.dataSource = self

        enterCodeCollectionView.delegate = self
        enterCodeCollectionView.dataSource = self
    }

    func setupTextField() {
        hiddenTextField.delegate = self
        hiddenTextField.keyboardType = .asciiCapable
        hiddenTextField.autocorrectionType = .no
        hiddenTextField.alpha = 0.01

        hiddenTextField.addTarget(self,
                                  action: #selector(textDidChange),
                                  for: .editingChanged)
    }

    func setupTapToFocus() {
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(focusInput))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    func setupSpinner() {
        spinner.center = view.center
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
    }

    // MARK: - Code Generation & Supabase

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
        } catch {
            print("DEBUG: Failed to save pairing code: \(error)")
        }

        isSavingCode = false
    }

    // MARK: - Realtime Listener

    func listenForRelationshipInsert() {
        guard let myUserId = SupabaseManager.shared.currentUserId else {
            print("DEBUG [PartnerPairing]: No currentUserId — skipping listener")
            return
        }
        print("DEBUG [PartnerPairing]: Setting up listener for user \(myUserId)")

        realtimeChannel = supabase.channel("profile-relationships-\(myUserId.uuidString.prefix(8))")

        Task {
            let stream = realtimeChannel?.postgresChange(
                InsertAction.self,
                schema: "public",
                table: "relationships"
            )

            await realtimeChannel?.subscribe()
            print("DEBUG [PartnerPairing]: Realtime channel subscribed")

            if let stream = stream {
                for await payload in stream {
                    let record = payload.record
                    print("DEBUG [PartnerPairing]: Got INSERT event: \(record)")

                    guard
                        let user1String = record["user1_id"]?.stringValue,
                        let user2String = record["user2_id"]?.stringValue,
                        let user1 = UUID(uuidString: user1String),
                        let user2 = UUID(uuidString: user2String)
                    else {
                        print("DEBUG [PartnerPairing]: Could not parse user IDs from record")
                        continue
                    }

                    print("DEBUG [PartnerPairing]: user1=\(user1), user2=\(user2), me=\(myUserId)")

                    if user1 == myUserId || user2 == myUserId {
                        print("DEBUG [PartnerPairing]: Match! Showing paired alert")
                        await MainActor.run {
                            self.showPairedAlert()
                        }
                    }
                }
            } else {
                print("DEBUG [PartnerPairing]: Stream is nil — listener not set up")
            }
        }
    }

    // MARK: - Text Handling

    @objc func focusInput() {
        hiddenTextField.becomeFirstResponder()
    }

    @objc func textDidChange(_ textField: UITextField) {
        let text = textField.text?.uppercased() ?? ""
        enteredCode = String(text.prefix(maxDigits))
        textField.text = enteredCode
        enterCodeCollectionView.reloadData()

        if enteredCode.count == maxDigits {
            codeCompleted(enteredCode)
        }
    }

    // MARK: - Pairing Logic

    func codeCompleted(_ code: String) {
        hiddenTextField.resignFirstResponder()
        spinner.startAnimating()
        view.isUserInteractionEnabled = false

        Task {
            await pairWithCode(code)
        }
    }

    func pairWithCode(_ code: String) async {
        do {
            let response = try await supabase
                .rpc("pair_with_code", params: ["p_code": code.uppercased()])
                .execute()

            // If the function returns a UUID, pairing succeeded
            let _ = try JSONDecoder().decode(UUID.self, from: response.data)

            await MainActor.run { showPairedAlert() }
        } catch {
            await MainActor.run {
                showError("Pairing failed: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Actions

    @IBAction func shareInviteTapped(_ sender: UIButton) {
        let code = shareCodeArray.joined()
        let activityVC = UIActivityViewController(
            activityItems: ["My partner code: \(code)"],
            applicationActivities: nil
        )
        present(activityVC, animated: true)
    }

    @IBAction func pairNow(_ sender: UIButton) {
        if enteredCode.count == maxDigits {
            codeCompleted(enteredCode)
        } else {
            showError("Enter full 6-digit code")
        }
    }

    // MARK: - Alerts

    func showPairedAlert() {
        spinner.stopAnimating()
        view.isUserInteractionEnabled = true

        // Remove skip flag since user is now paired
        UserDefaults.standard.removeObject(forKey: "didSkipPairing")

        let alert = UIAlertController(
            title: "Paired ❤️",
            message: "You are now connected!",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Continue", style: .default) { [weak self] _ in
            // Reload the user context so partner info is available
            Task {
                await DataStore.shared.loadUserContext()
                DataStore.shared.startPartnerDeletionListener()
                DataStore.shared.syncActivitiesFromSupabase()
            }

            // Dismiss back to the main app
            self?.dismiss(animated: true)
        })

        present(alert, animated: true)
    }

    func showError(_ message: String) {
        spinner.stopAnimating()
        view.isUserInteractionEnabled = true

        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - CollectionView

extension PartnerPairingViewController:
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout {

    func collectionView(_ cv: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return cv == sharedCodeCollectionView
        ? shareCodeArray.count
        : maxDigits
    }

    func collectionView(_ cv: UICollectionView,
                        cellForItemAt indexPath: IndexPath)
    -> UICollectionViewCell {

        if cv == sharedCodeCollectionView {
            let cell = cv.dequeueReusableCell(
                withReuseIdentifier: "CodeCell",
                for: indexPath) as! ShareCodeCollectionViewCell

            cell.CodeLabel.text = String(shareCodeArray[indexPath.item])
            return cell

        } else {
            let cell = cv.dequeueReusableCell(
                withReuseIdentifier: "EnterCodeCell",
                for: indexPath) as! EnterCodeCollectionViewCell

            let chars = Array(enteredCode)
            cell.enterCodeLabel.text =
                indexPath.item < chars.count ? String(chars[indexPath.item]) : ""
            return cell
        }
    }

    func collectionView(_ cv: UICollectionView,
                        layout: UICollectionViewLayout,
                        sizeForItemAt: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 60)
    }

    func collectionView(_ cv: UICollectionView,
                        layout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt: Int) -> CGFloat {
        return 5
    }
}

// MARK: - UITextFieldDelegate

extension PartnerPairingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
