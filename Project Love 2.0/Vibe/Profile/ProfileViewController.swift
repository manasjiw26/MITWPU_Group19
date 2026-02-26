import UIKit

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

        user = DataStore.shared.userProfile
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

    // MARK: Table

    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        sections[section].items.count
    }

    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }
    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        return 34
    }

    func tableView(_ tableView: UITableView,
                   heightForFooterInSection section: Int) -> CGFloat {
        return 8
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let item = sections[indexPath.section].items[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.showsChevron ? .disclosureIndicator : .none

        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        let item = sections[indexPath.section].items[indexPath.row]

        if item.title == "Personal Info" {
            let storyboard = UIStoryboard(name: "Profile_Info", bundle: nil)
            let vc = storyboard.instantiateViewController(
                withIdentifier: "Personal_InfoViewController"
            ) as! Personal_InfoViewController
            navigationController?.pushViewController(vc, animated: true)
        }

        if item.title == "Special Dates" {
            navigationController?.pushViewController(
                UIStoryboard(name: "SpecialDates", bundle: nil)
                .instantiateViewController(withIdentifier: "SpecialDatesViewController"),
                animated: true)
        }

        if item.title == "Partner Pairing" {
            navigationController?.pushViewController(
                UIStoryboard(name: "PartnerPairing", bundle: nil)
                .instantiateViewController(withIdentifier: "PartnerPairingViewController"),
                animated: true)
        }

        if item.title == "Help & Support" {
            navigationController?.pushViewController(
                UIStoryboard(name: "Help_Support", bundle: nil)
                .instantiateViewController(withIdentifier: "Help_SupportViewController"),
                animated: true)
        }
    }
}
