import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Outlets
    @IBOutlet weak var viewForIcon: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Data
    private var user: UserProfile!
    private let sections = DataStore.shared.profileSections
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeButtonTapped)
        )
        
        user = DataStore.shared.userProfile
        setupUI()
       
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        
        nameLabel.text = user.name
        emailLabel.text = user.email
        
        profileImage.image = UIImage(named: user.profileImageName)
    }
    
    //    private func setupCloseButton() {
    //        let closeButton = UIButton(type: .close)
    //        closeButton.translatesAutoresizingMaskIntoConstraints = false
    //        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    //        view.addSubview(closeButton)
    //
    //        NSLayoutConstraint.activate([
    //            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
    //            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
    //        ])
    //    }
//    private func setupEditButton() {
//        let editButton = UIBarButtonItem(
//            title: "Edit",
//            style: .plain,
//            target: self,
//            action: #selector(editButtonTapped)
//        )
//        navigationItem.rightBarButtonItem = editButton
//    }
//    @objc private func editButtonTapped() {
//        print("Edit tapped")
//        // later: push EditProfileViewController
//    }
    
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    // MARK: - TableView DataSource
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = sections[indexPath.section].items[indexPath.row]
        
        cell.textLabel?.text = item.title
        cell.textLabel?.font = .systemFont(ofSize: 16)
        cell.textLabel?.textColor = .label
        cell.textLabel?.textAlignment = .left
        
        cell.accessoryType = item.showsChevron ? .disclosureIndicator : .none
        
        return cell
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = sections[indexPath.section].items[indexPath.row]
        
        if item.title == "Personal Info" {
            let storyboard = UIStoryboard(name: "Profile_Info", bundle: nil)
            let vc = storyboard.instantiateViewController(
                withIdentifier: "Personal_InfoViewController"
            ) as! Personal_InfoViewController

            vc.title = "Personal Info"

            navigationController?.pushViewController(vc, animated: true)


        }
        if item.title == "Status" {
            let storyboard = UIStoryboard(name: "Activity_Status", bundle: nil)
            let vc = storyboard.instantiateViewController(
                withIdentifier: "ActivityStatsViewController"
            ) as! ActivityStatsViewController
            navigationController?.pushViewController(vc, animated: true)

        }

    }
    
}
