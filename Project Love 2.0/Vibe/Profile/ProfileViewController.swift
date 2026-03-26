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

        case "Partner Info":
            let vc = PartnerInfoViewController()
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
        Task {
            do {
                let client = SupabaseManager.shared.client

                // 1. Execute the master deletion script on the server
                // This will safely bypass foreign key locks by deleting all connected data first.
                try await client.rpc("master_delete_user").execute()

                // 2. Sign out natively
                try await client.auth.signOut()

                DispatchQueue.main.async {
                    if let domain = Bundle.main.bundleIdentifier {
                        UserDefaults.standard.removePersistentDomain(forName: domain)
                    }
                    DataStore.shared.clearSession()
                    self.navigateToLogin()
                }
            } catch {
                DispatchQueue.main.async {
                    self.showError("Deletion failed:\n\(error.localizedDescription)")
                    print("Deletion error: \(error)")
                }
            }
        }
    }

    // MARK: - Helpers

    private func navigateToLogin() {
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: "hasCompletedAuth")
        defaults.set(false, forKey: "hasCompletedBasicInfo")
        defaults.set(false, forKey: "hasCompletedAssessment")
        defaults.set(false, forKey: "hasCompletedPairing")
        defaults.set(false, forKey: "hasCompletedOnboarding")
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let loginStoryboard = UIStoryboard(name: "Onboarding", bundle: nil)
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

class PartnerInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var tableView: UITableView!
    private var emptyStateLabel: UILabel!
    private var connectButton: UIButton!
    
    private struct PartnerInfoItemLocal {
        let title: String
        var value: String
    }
    
    private var partnerItems: [PartnerInfoItemLocal] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Partner Info"
        view.backgroundColor = .systemGroupedBackground
        
        setupUI()
        setupHeaderView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkPartnerStatus()
    }
    
    private func setupUI() {
        tableView = UITableView(frame: view.bounds, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(tableView)
        
        emptyStateLabel = UILabel()
        emptyStateLabel.text = "You are not connected to a partner."
        emptyStateLabel.textColor = .secondaryLabel
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.font = .preferredFont(forTextStyle: .headline)
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateLabel)
        
        connectButton = UIButton(type: .system)
        connectButton.setTitle("Connect to a Partner", for: .normal)
        connectButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        connectButton.translatesAutoresizingMaskIntoConstraints = false
        connectButton.addTarget(self, action: #selector(connectTapped), for: .touchUpInside)
        view.addSubview(connectButton)
        
        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            connectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            connectButton.topAnchor.constraint(equalTo: emptyStateLabel.bottomAnchor, constant: 16)
        ])
    }
    
    private func setupHeaderView() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 200))
        headerView.backgroundColor = .clear
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "Profile") ?? UIImage(systemName: "person.crop.circle.fill")
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .systemGray3
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        
        headerView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 50),
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        tableView.tableHeaderView = headerView
    }
    
    private func checkPartnerStatus() {
        if let partnerId = DataStore.shared.partnerUserId {
            tableView.isHidden = false
            emptyStateLabel.isHidden = true
            connectButton.isHidden = true
            fetchPartnerInfo(partnerId: partnerId)
        } else {
            tableView.isHidden = true
            emptyStateLabel.isHidden = false
            connectButton.isHidden = false
        }
    }
    
    private func fetchPartnerInfo(partnerId: UUID) {
        Task {
            do {
                struct UserProfileRowLocal: Decodable {
                    let name: String?
                    let birth_date: String?
                    let gender: String?
                }
                
                let rows: [UserProfileRowLocal] = try await SupabaseManager.shared.client
                    .from("users")
                    .select("name, birth_date, gender")
                    .eq("user_id", value: partnerId.uuidString)
                    .limit(1)
                    .execute()
                    .value
                
                guard let row = rows.first else {
                    print("DEBUG: Fetched partner info but got 0 rows. Check RLS policies or user ID: \(partnerId)")
                    self.partnerItems = [
                        PartnerInfoItemLocal(title: "Status", value: "Could not load data (0 rows)")
                    ]
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    return
                }
                
                let name = row.name?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? row.name! : "Unknown"
                let gender = row.gender?.capitalized ?? "Unknown"
                var dobString = "Unknown"
                if let bd = row.birth_date {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    if let date = formatter.date(from: bd) {
                        let displayFormatter = DateFormatter()
                        displayFormatter.dateStyle = .medium
                        dobString = displayFormatter.string(from: date)
                    } else {
                        dobString = bd
                    }
                }
                
                self.partnerItems = [
                    PartnerInfoItemLocal(title: "Full Name", value: name),
                    PartnerInfoItemLocal(title: "Gender", value: gender),
                    PartnerInfoItemLocal(title: "Date of Birth", value: dobString)
                ]
                
                print("DEBUG: Successfully fetched partner info: \(self.partnerItems)")
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("DEBUG: Failed to fetch partner info. Error: \(error)")
                self.partnerItems = [
                    PartnerInfoItemLocal(title: "Error", value: "Failed to load")
                ]
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @objc private func connectTapped() {
        let storyboard = UIStoryboard(name: "PartnerPairing", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PartnerPairingViewController")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return partnerItems.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Basic Information"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        cell.selectionStyle = .none
        let item = partnerItems[indexPath.row]
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.value
        return cell
    }
}
