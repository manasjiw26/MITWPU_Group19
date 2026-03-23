import UIKit
import Supabase

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var viewForIcon: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    private var user: UserProfile!
    private let sections = DataStore.shared.profileSections

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyHeader()

        Task {
            await DataStore.shared.refreshUserProfileFromSupabase()
            DispatchQueue.main.async { self.applyHeader() }
        }
    }

    private func applyHeader() {
        guard let user = DataStore.shared.userProfile else { return }
        nameLabel.text = user.name
        emailLabel.text = user.email
        profileImage.image = UIImage(named: user.profileImageName)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeButtonTapped)
        )

        setupUI()
        setupTable()
    }

    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
    }

    private func setupTable() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()

        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }

    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }

    // MARK: - Table

    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].items.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 34
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = sections[indexPath.section].items[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.showsChevron ? .disclosureIndicator : .none

        // Red tint for destructive actions
        if item.title == "Sign Out" {
            cell.textLabel?.textColor = .systemRed
        } else if item.title == "Delete Account" {
            cell.textLabel?.textColor = .systemRed
        } else {
            cell.textLabel?.textColor = .label
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = sections[indexPath.section].items[indexPath.row]

        switch item.title {
        case "Personal Info":
            let vc = UIStoryboard(name: "Profile_Info", bundle: nil)
                .instantiateViewController(withIdentifier: "Personal_InfoViewController")
                as! Personal_InfoViewController
            navigationController?.pushViewController(vc, animated: true)

        case "Special Dates":
            navigationController?.pushViewController(
                UIStoryboard(name: "SpecialDates", bundle: nil)
                    .instantiateViewController(withIdentifier: "SpecialDatesViewController"),
                animated: true)

        case "Partner Pairing":
            navigationController?.pushViewController(
                UIStoryboard(name: "PartnerPairing", bundle: nil)
                    .instantiateViewController(withIdentifier: "PartnerPairingViewController"),
                animated: true)

        case "Help & Support":
            navigationController?.pushViewController(
                UIStoryboard(name: "Help_Support", bundle: nil)
                    .instantiateViewController(withIdentifier: "Help_SupportViewController"),
                animated: true)

        case "Sign Out":
            confirmSignOut()

        case "Delete Account":
            confirmDeleteAccount()

        default:
            break
        }
    }

    // MARK: - Sign Out

    private func confirmSignOut() {
        let alert = UIAlertController(
            title: "Sign Out",
            message: "Are you sure you want to sign out?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { _ in
            self.performSignOut()
        })
        present(alert, animated: true)
    }

    private func performSignOut() {
        Task {
            do {
                try await SupabaseManager.shared.client.auth.signOut()
                DispatchQueue.main.async {
                    DataStore.shared.clearSession()
                    self.navigateToLogin()
                }
            } catch {
                DispatchQueue.main.async {
                    self.showError("Failed to sign out. Please try again.")
                }
            }
        }
    }

    // MARK: - Delete Account

    private func confirmDeleteAccount() {
        let alert = UIAlertController(
            title: "Delete Account",
            message: "This will permanently delete your account and all your data. This action cannot be undone.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.performDeleteAccount()
        })
        present(alert, animated: true)
    }

    private func performDeleteAccount() {
        guard let userId = DataStore.shared.currentUserId else { return }

        Task {
            do {
                // Delete all user data from Supabase (cascade via RLS/FK) then delete auth user
                let client = SupabaseManager.shared.client

                // 1. Delete from users table (FK cascades to other tables)
                try await client
                    .from("users")
                    .delete()
                    .eq("user_id", value: userId.uuidString)
                    .execute()

                // 2. Sign out and navigate to login
                try await client.auth.signOut()

                DispatchQueue.main.async {
                    DataStore.shared.clearSession()
                    self.navigateToLogin()
                }
            } catch {
                DispatchQueue.main.async {
                    self.showError("Failed to delete account. Please try again.")
                }
            }
        }
    }

    // MARK: - Helpers

    private func navigateToLogin() {
        // Navigate to root / login screen
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let loginStoryboard = UIStoryboard(name: "Main", bundle: nil)
            window.rootViewController = loginStoryboard.instantiateInitialViewController()
            window.makeKeyAndVisible()
            UIView.transition(with: window,
                              duration: 0.35,
                              options: .transitionCrossDissolve,
                              animations: nil)
        }
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
