import UIKit
import SpriteKit
class memoryPhotoViewController: UIViewController,
                                 UICollectionViewDataSource,
                                 UICollectionViewDelegate,
                                 UICollectionViewDelegateFlowLayout,
                                 LocationSearchDelegate {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var MemoryTitle: UILabel!
    @IBOutlet weak var MemoryDate: UILabel!
    @IBOutlet weak var MemoryImage: UIImageView!
    @IBOutlet weak var thumbnailsCollectionView: UICollectionView!

    var currentIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true

        setupMenu()
        setupSwipes()
        setupThumbnails()
        updateUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        // disabling left swipe to back
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    @IBAction func infobutton(_ sender: Any) {guard !dataStore.savedMemories.isEmpty else { return }
        let memory = dataStore.savedMemories[currentIndex]

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        let location = memory.location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Not set" : memory.location
        let desc = memory.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "No description" : memory.description

        let alert = UIAlertController(
            title: memory.title.isEmpty ? "Memory Info" : memory.title,
            message: "Date: \(formatter.string(from: memory.date))\nLocation: \(location)\n\nDescription:\n\(desc)",
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        alert.popoverPresentationController?.barButtonItem = sender as! UIBarButtonItem
        present(alert, animated: true)
    }
    
    
    // tap bar hidden when memory is opened
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    @IBAction func closeButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    func updateUI() {
        guard !dataStore.savedMemories.isEmpty else { return }

        let memory = dataStore.savedMemories[currentIndex]

        MemoryTitle.text = memory.title
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yy"   
        MemoryDate.text = formatter.string(from: memory.date)
        MemoryImage.image = memory.uiImage ??
                            UIImage(named: memory.imageName)
        
        //collection view scroll to that particular image
        
        let indexPath = IndexPath(item: currentIndex, section: 0)
        thumbnailsCollectionView.selectItem(
            at: indexPath,
            animated: true,
            scrollPosition: .centeredHorizontally
        )
    }
    
    func setupMenu() {

        let editTitle = UIAction(
            title: "Edit Title",
            image: UIImage(systemName: "pencil")
        ) { [weak self] _ in
            self?.showEditTitleAlert()
        }

        let editDescription = UIAction(
            title: "Edit Description",
            image: UIImage(systemName: "text.alignleft")
        ) { [weak self] _ in
            self?.showEditDescriptionAlert()
        }

        let editDate = UIAction(
            title: "Adjust Date",
            image: UIImage(systemName: "calendar")
        ) { [weak self] _ in
            self?.showEditDateAlert()
        }

        let adjustLocation = UIAction(
            title: "Adjust Location",
            image: UIImage(systemName: "mappin")
        ) { [weak self] _ in
            self?.performSegue(withIdentifier: "goToLocation", sender: nil)
        }

        let delete = UIAction(
            title: "Delete",
            image: UIImage(systemName: "trash"),
            attributes: .destructive
        ) { [weak self] _ in
            self?.confirmDeleteMemory()
        }

        menuButton.menu = UIMenu(children: [
            editTitle,
            editDescription,
            editDate,
            adjustLocation,
            delete
        ])
    }
    private func confirmDeleteMemory() {
        let alert = UIAlertController(
            title: "Delete Memory?",
            message: "This memory will be deleted for you and your partner.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteMemory()
        })

        present(alert, animated: true)
    }

    private func showEditTitleAlert() {
        guard !dataStore.savedMemories.isEmpty else { return }

        let alert = UIAlertController(title: "Edit Title", message: nil, preferredStyle: .alert)
        alert.addTextField { [weak self] tf in
            tf.placeholder = "Memory title"
            tf.text = self.map { dataStore.savedMemories[$0.currentIndex].title }
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self, weak alert] _ in
            guard let self,
                  let text = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !text.isEmpty else { return }

            dataStore.savedMemories[self.currentIndex].title = text
            self.updateUI()
        })

        present(alert, animated: true)
    }

    private func showEditDescriptionAlert() {
        guard !dataStore.savedMemories.isEmpty else { return }

        let alert = UIAlertController(title: "Edit Description", message: nil, preferredStyle: .alert)
        alert.addTextField { [weak self] tf in
            tf.placeholder = "Memory description"
            tf.text = self.map { dataStore.savedMemories[$0.currentIndex].description }
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self, weak alert] _ in
            guard let self else { return }

            let text = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            dataStore.savedMemories[self.currentIndex].description = text
            self.updateUI()
        })

        present(alert, animated: true)
    }

    private func showEditDateAlert() {
        guard !dataStore.savedMemories.isEmpty else { return }

        let memory = dataStore.savedMemories[currentIndex]
        let alert = UIAlertController(title: "Adjust Date", message: "\n\n\n\n\n\n\n\n", preferredStyle: .alert)

        let datePicker = UIDatePicker(frame: CGRect(x: 10, y: 45, width: 250, height: 160))
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.maximumDate = Date()
        datePicker.date = memory.date
        alert.view.addSubview(datePicker)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self else { return }
            dataStore.savedMemories[self.currentIndex].date = datePicker.date
            self.updateUI()
        })

        present(alert, animated: true)
    }
    private func showSimpleError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // Ti open location view controler
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToLocation" {
            let vc = segue.destination as! LocationSearchViewController
            vc.delegate = self
        }
    }

    func didSelectLocation(_ name: String) {
        dataStore.savedMemories[currentIndex].location = name
        updateUI()
    }

    func deleteMemory() {
        guard !dataStore.savedMemories.isEmpty else { return }

        let memory = dataStore.savedMemories[currentIndex]

        Task {
            do {
                // 1. Delete from Supabase (wait for completion)
                try await SupabaseManager.shared.deleteMemory(
                    memoryId: memory.id,
                    imagePath: memory.imageName
                )

                // 2. Supabase delete succeeded — now remove locally
                await MainActor.run {
                    // Guard in case realtime already removed it
                    if let index = dataStore.savedMemories.firstIndex(where: { $0.id == memory.id }) {
                        dataStore.savedMemories.remove(at: index)
                    }
                    
                    // Remove heart from jar scene
                    if let jarVC = self.navigationController?.viewControllers.first(where: { $0 is MemoryJarViewController }) as? MemoryJarViewController,
                       let scene = jarVC.MemoryJarView.scene as? MemoryJarScene {
                        scene.removeHeart(memoryID: memory.id)
                        jarVC.memoryLaneCollectionView.reloadData()
                    }
                    
                    // If no memories left, pop back
                    if dataStore.savedMemories.isEmpty {
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        self.currentIndex = min(self.currentIndex, dataStore.savedMemories.count - 1)
                        self.thumbnailsCollectionView.reloadData()
                        self.updateUI()
                    }
                }

            } catch {
                print("❌ Failed to delete memory: \(error)")
                await MainActor.run {
                    self.showSimpleError("Failed to delete memory: \(error.localizedDescription)")
                }
            }
        }
    }

    func setupSwipes() {
        let left = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        left.direction = .left

        let right = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        right.direction = .right

        view.addGestureRecognizer(left)
        view.addGestureRecognizer(right)
    }

    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left,
           currentIndex < dataStore.savedMemories.count - 1 {
            currentIndex += 1
        } else if gesture.direction == .right,
                  currentIndex > 0 {
            currentIndex -= 1
        }

        UIView.transition(
            with: MemoryImage,
            duration: 0.4,
            options: .transitionCrossDissolve
        ) {
            self.updateUI()
        }
    }
    
    // Collection view
    func setupThumbnails() {
        thumbnailsCollectionView.dataSource = self
        thumbnailsCollectionView.delegate = self

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 55, height: 55)
        layout.minimumLineSpacing = 8

        thumbnailsCollectionView.collectionViewLayout = layout
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return dataStore.savedMemories.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ThumbnailCell",
            for: indexPath
        ) as! ThumbnailCell

        let memory = dataStore.savedMemories[indexPath.item]
        cell.imageView.image = memory.uiImage ??
                               UIImage(named: memory.imageName)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        currentIndex = indexPath.item
        updateUI()
    }
}
