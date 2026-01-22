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

        let adjustLocation = UIAction(
            title: "Adjust Location",
            image: UIImage(systemName: "mappin")
        ) { _ in
            self.performSegue(withIdentifier: "goToLocation", sender: nil)
        }

        let delete = UIAction(
            title: "Delete",
            image: UIImage(systemName: "trash"),
            attributes: .destructive
        ) { _ in
            self.deleteMemory()
        }

        menuButton.menu = UIMenu(children: [
            UIAction(title: "Edit Title", image: UIImage(systemName: "pencil")) { _ in },
            UIAction(title: "Edit Description", image: UIImage(systemName: "text.alignleft")) { _ in },
            UIAction(title: "Adjust Date", image: UIImage(systemName: "calendar")) { _ in },
            adjustLocation,
            delete
        ])
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

        // take the memory before removing
        let deletedMemory = dataStore.savedMemories[currentIndex]

        // delete from datastore
        dataStore.savedMemories.remove(at: currentIndex)

        // find the jar vc
        if let jarVC = navigationController?.viewControllers.first(where: { $0 is MemoryJarViewController }) as? MemoryJarViewController,
           let scene = jarVC.MemoryJarView.scene as? MemoryJarScene {

            scene.removeHeart(memoryID: deletedMemory.id)
        }
        
        // If no memories give a popover
        if dataStore.savedMemories.isEmpty {
            navigationController?.popViewController(animated: true)
            return
        }

        currentIndex = max(0, currentIndex - 1)
        thumbnailsCollectionView.reloadData()
        updateUI()
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
