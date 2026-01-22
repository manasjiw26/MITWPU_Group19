import UIKit

class Personal_InfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var Imageview: UIImageView!
    @IBOutlet weak var Cellview: UIView!
    @IBOutlet weak var Table: UITableView!

    private var sections: [PersonalInfoSection] {
        DataStore.shared.personalInfoSections
    }

    private let user = DataStore.shared.userProfile
    private var isEditingProfile = false

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Personal Info"
        view.backgroundColor = .systemGroupedBackground

        setupTableView()
        setupHeader()
        setupEditButton()
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
        for cell in Table.visibleCells {
            guard let indexPath = Table.indexPath(for: cell),
                  let cell = cell as? PersonalInfoTableViewCell else { continue }

            let newValue = cell.valueTextField.text ?? ""

            DataStore.shared.personalInfoSections[indexPath.section].items[indexPath.row].value = newValue

            let itemTitle = DataStore.shared.personalInfoSections[indexPath.section].items[indexPath.row].title
            if itemTitle == "Full Name" {
                DataStore.shared.userProfile?.name = newValue
            } else if itemTitle == "Email" {
                DataStore.shared.userProfile?.email = newValue
            }
        }
    }


    @objc private func editButtonTapped() {
        if isEditingProfile {
               view.endEditing(true)
               saveProfileData()
           }

           isEditingProfile.toggle()

           if isEditingProfile {
               navigationItem.rightBarButtonItem = UIBarButtonItem(
                   image: UIImage(systemName: "checkmark"),
                   style: .plain,
                   target: self,
                   action: #selector(editButtonTapped)
               )
           } else {
               setupEditButton()
           }

           Table.reloadData()
    }

    private func setupTableView() {
        Table.delegate = self
        Table.dataSource = self
        Table.tableFooterView = UIView()
        Table.tableHeaderView = Cellview

    }

    private func setupHeader() {
        guard let user = user else { return }

        Imageview.image = UIImage(named: user.profileImageName)
        Imageview.layer.cornerRadius = Imageview.frame.height / 2
        Imageview.clipsToBounds = true
        Imageview.contentMode = .scaleAspectFill

    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
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
            isEditing: isEditingProfile, showsChevron: item.showsChevron
        )

        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = sections[indexPath.section].items[indexPath.row]
        print("\(item.title) tapped")
       
    }
    
}

