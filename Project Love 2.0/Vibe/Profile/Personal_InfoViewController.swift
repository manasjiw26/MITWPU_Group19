import UIKit

class Personal_InfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var Imageview: UIImageView!
    @IBOutlet weak var Cellview: UIView!
    @IBOutlet weak var Table: UITableView!

    private var sections: [PersonalInfoSection] {
        DataStore.shared.personalInfoSections
    }

    private var user: UserProfile? { DataStore.shared.userProfile }
    private var isEditingProfile = false


    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Personal Info"
        view.backgroundColor = .systemGroupedBackground

        setupTableView()
        setupHeader()
        setupEditButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            await DataStore.shared.refreshUserProfileFromSupabase()
            DispatchQueue.main.async {
                self.setupHeader()
                self.Table.reloadData()
            }
        }
    }

    private func setupTableView() {
        Table.delegate = self
        Table.dataSource = self
        Table.tableFooterView = UIView()

        if #available(iOS 15.0, *) {
            Table.sectionHeaderTopPadding = 0
        }
    }

    private func setupHeader() {
        guard let user = user else { return }

        Imageview.image = UIImage(named: user.profileImageName)
        Imageview.layer.cornerRadius = Imageview.frame.height / 2
        Imageview.clipsToBounds = true
        Imageview.contentMode = .scaleAspectFill
    }

    private func setupEditButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Edit",
            style: .plain,
            target: self,
            action: #selector(editButtonTapped)
        )
    }

    private func saveProfileData() {
        var updatedName: String?
        var updatedEmail: String?
        var updatedDOBString: String?

        for cell in Table.visibleCells {
            guard let indexPath = Table.indexPath(for: cell),
                  let cell = cell as? PersonalInfoTableViewCell else { continue }

            let newValue = cell.valueTextField.text ?? ""

            DataStore.shared.personalInfoSections[indexPath.section].items[indexPath.row].value = newValue

            let itemTitle = DataStore.shared.personalInfoSections[indexPath.section].items[indexPath.row].title
            if itemTitle == "Full Name" {
                DataStore.shared.userProfile?.name = newValue
                updatedName = newValue
            } else if itemTitle == "Email" {
                DataStore.shared.userProfile?.email = newValue
                updatedEmail = newValue
            } else if itemTitle == "Date of Birth" {
                updatedDOBString = newValue
            }
        }

        // Persist to Supabase
        let name = updatedName ?? DataStore.shared.userProfile?.name ?? ""
        let email = updatedEmail ?? DataStore.shared.userProfile?.email ?? ""

        if let dobStr = updatedDOBString ?? DataStore.shared.personalInfoSections
            .flatMap({ $0.items }).first(where: { $0.title == "Date of Birth" })?.value {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "dd/MM/yyyy"
            if let dobDate = formatter.date(from: dobStr) {
                DataStore.shared.updateProfileInSupabase(name: name, email: email, dob: dobDate)
            }
        }
    }

    @objc private func editButtonTapped() {
        if isEditingProfile {
            view.endEditing(true)
            saveProfileData()
        }

        isEditingProfile.toggle()

        navigationItem.rightBarButtonItem = isEditingProfile
        ? UIBarButtonItem(image: UIImage(systemName: "checkmark"),
                          style: .plain,
                          target: self,
                          action: #selector(editButtonTapped))
        : UIBarButtonItem(title: "Edit",
                          style: .plain,
                          target: self,
                          action: #selector(editButtonTapped))

        Table.reloadData()
    }

    // MARK: - Table

    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "cell",
            for: indexPath
        ) as! PersonalInfoTableViewCell

        let item = sections[indexPath.section].items[indexPath.row]

        cell.configure(
            title: item.title,
            value: item.value,
            isEditing: isEditingProfile,
            showsChevron: item.showsChevron
        )

        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        let item = sections[indexPath.section].items[indexPath.row]

        if item.title == "Edit Preferences" {
            let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)

            if let vc = storyboard.instantiateViewController(
                withIdentifier: "questions"
            ) as? onboardingQuestionViewController {

                vc.isEditingMode = true
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
