import UIKit
import SpriteKit
import Supabase

class MemoryJarViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var memoryLaneCollectionView: UICollectionView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var MemoryJarView: SKView!
    
    private var memoryChannel: RealtimeChannelV2?
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        memoryLaneCollectionView.dataSource = self
        
        memoryLaneCollectionView.delegate = self
        memoryLaneCollectionView.register(
            UINib(nibName: "memoryEmptyStateCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "emptyMemoryState"
        )
        MemoryJarView.allowsTransparency = true
        MemoryJarView.backgroundColor = .clear
        addButton.configuration = .glass()
        addButton.setTitle("Add", for: .normal)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewMemory(_:)), name: NSNotification.Name("MemoryAdded"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showMemoryDisplay(_:)), name: NSNotification.Name("OpenMemory"), object: nil)
        memoryLaneCollectionView.alwaysBounceVertical = false
        memoryLaneCollectionView.showsVerticalScrollIndicator = false
        memoryLaneCollectionView.contentInsetAdjustmentBehavior = .never

        // Setup loading indicator
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
    }
    private var isEmptyState: Bool {
        dataStore.savedMemories.isEmpty
    }
    private func refreshMemoryLaneUI() {
        memoryLaneCollectionView.setCollectionViewLayout(generateLayout(), animated: false)
        memoryLaneCollectionView.collectionViewLayout.invalidateLayout()
        memoryLaneCollectionView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MemoryJarView.isPaused = false

        Task {
            await fetchMemoriesFromSupabase()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        MemoryJarView.isPaused = true

        if let channel = memoryChannel {
            Task {
                await SupabaseManager.shared.client.removeChannel(channel)
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if MemoryJarView.scene == nil {
            let scene = MemoryJarScene(size: MemoryJarView.bounds.size)
            scene.scaleMode = .aspectFill
            MemoryJarView.presentScene(scene)
            syncJarHearts()
        }
    }

    private func syncJarHearts() {
        guard let scene = MemoryJarView.scene as? MemoryJarScene else { return }
        let currentHearts = scene.children.filter { $0.name?.hasPrefix("heart_") == true }
        let actualDataCount = dataStore.savedMemories.count
        
        if currentHearts.count != actualDataCount {
            scene.children
                .filter { $0.name?.hasPrefix("heart_") == true }
                .forEach { $0.removeFromParent() }
            
            for (index, memory) in dataStore.savedMemories.enumerated() {
                scene.addHeart(index: index, memoryID: memory.id, animate: false)
            }
        }
    }

    @objc func handleNewMemory(_ notification: Notification) {
        // Retrieve the locally created memory
        guard let localMemory = notification.object as? Memory else { return }

        DispatchQueue.main.async {
            // Check if it was already added somehow to prevent duplicates
            guard !dataStore.savedMemories.contains(where: { $0.id == localMemory.id }) else { return }

            // Add the local memory to the data store immediately
            dataStore.savedMemories.append(localMemory)
            
            // Reload the collection view to show the new card
            self.refreshMemoryLaneUI()
            
            if let scene = self.MemoryJarView.scene as? MemoryJarScene {
                let newIndex = dataStore.savedMemories.count - 1
                
                guard newIndex >= 0 else { return }
                
                scene.addHeart(index: newIndex, memoryID: localMemory.id, animate: true)
                
                let indexPath = IndexPath(item: newIndex, section: 0)
                // Scroll to the new item
                if indexPath.item < self.memoryLaneCollectionView.numberOfItems(inSection: 0) {
                    self.memoryLaneCollectionView.scrollToItem(at: indexPath, at: .right, animated: true)
                }
            }
        }
    }

    @MainActor
    func fetchMemoriesFromSupabase() async {
        guard let userId = SupabaseManager.shared.client.auth.currentUser?.id else { return }

        // Determine if we need to show the loading state (e.g. if we have no memories locally)
        let isInitialLoad = dataStore.savedMemories.isEmpty
        if isInitialLoad {
            loadingIndicator.startAnimating()
            MemoryJarView.isHidden = true
            memoryLaneCollectionView.isHidden = true
        }

        do {
            // 1️⃣ Get relationship_id
            let response = try await SupabaseManager.shared.client
                .from("users")
                .select("relationship_id")
                .eq("user_id", value: userId.uuidString)
                .single()
                .execute()

            struct UserRelation: Decodable {
                let relationship_id: UUID?
            }

            let decodedRelation = try JSONDecoder().decode(UserRelation.self, from: response.data)
            guard let relationshipId = decodedRelation.relationship_id else { return }
            
            print("Fetched relationship_id:", decodedRelation.relationship_id as Any)

            let memoryResponse = try await SupabaseManager.shared.client
                .from("memories")
                .select()
                .eq("relationship_id", value: relationshipId.uuidString)
                .order("memory_date", ascending: true)
                .execute()

            let decoded = try JSONDecoder().decode([MemoryModel].self, from: memoryResponse.data)

            var convertedMemories: [Memory] = []

            for item in decoded {

                let date = ISO8601DateFormatter().date(from: item.memory_date) ?? Date()

                let imageData = try await SupabaseManager.shared.client
                    .storage
                    .from("memory-images")
                    .download(path: item.image_path)

                let uiImage = UIImage(data: imageData)

                let memory = Memory(
                    id: item.id,
                    date: date,
                    imageName: item.image_path,
                    location: "",
                    title: item.title,
                    description: item.description ?? "",
                    uiImage: uiImage
                )

                convertedMemories.append(memory)
            }

            await MainActor.run {
                dataStore.savedMemories.removeAll()
                dataStore.savedMemories = convertedMemories
                
                if isInitialLoad {
                    self.loadingIndicator.stopAnimating()
                    // Animate the views back in
                    UIView.animate(withDuration: 0.3) {
                        self.MemoryJarView.isHidden = false
                        self.memoryLaneCollectionView.isHidden = false
                    }
                }
            }
            refreshMemoryLaneUI()
            syncJarHearts()
            await listenForPartnerMemory(relationshipId: relationshipId)

        } catch {
            print("Fetch error:", error)
            await MainActor.run {
                if isInitialLoad {
                    self.loadingIndicator.stopAnimating()
                    self.MemoryJarView.isHidden = false
                    self.memoryLaneCollectionView.isHidden = false
                }
            }
        }
    }
    
    func listenForPartnerMemory(relationshipId: UUID) async {
        
        if let existingChannel = memoryChannel {
            await SupabaseManager.shared.client.removeChannel(existingChannel)
        }

        self.memoryChannel = SupabaseManager.shared.client.channel("memory_updates")
        guard let channel = self.memoryChannel else { return }

        let changesStream = channel.postgresChange(
            AnyAction.self,
            schema: "public",
            table: "memories",
            filter: "relationship_id=eq.\(relationshipId.uuidString)"
        )

        await channel.subscribe()

        Task {
            for await change in changesStream {
                switch change {

                case .insert(let action):
                    do {
                        let jsonData = try JSONEncoder().encode(action.record)
                        let item = try JSONDecoder().decode(MemoryModel.self, from: jsonData)

                        // Ignore own insert (already shown locally)
                       

                        // Prevent duplicates
                        if dataStore.savedMemories.contains(where: { $0.id == item.id }) {
                            continue
                        }

                        let imageData = try await SupabaseManager.shared.client
                            .storage
                            .from("memory-images")
                            .download(path: item.image_path)

                        await MainActor.run {
                            let date = ISO8601DateFormatter().date(from: item.memory_date) ?? Date()

                            let newMemory = Memory(
                                id: item.id,
                                date: date,
                                imageName: item.image_path,
                                location: "",
                                title: item.title,
                                description: item.description ?? "",
                                uiImage: UIImage(data: imageData)
                            )

                            dataStore.savedMemories.append(newMemory)
                            self.refreshMemoryLaneUI()

                            if let scene = self.MemoryJarView.scene as? MemoryJarScene {
                                let newIndex = dataStore.savedMemories.count - 1
                                scene.addHeart(index: newIndex, memoryID: newMemory.id, animate: true)
                            }
                        }
                    } catch {
                        print("Insert realtime handling error:", error)
                    }

                case .delete(let action):
                    do {
                        let jsonData = try JSONEncoder().encode(action.oldRecord)

                        struct DeletedMemory: Decodable {
                            let id: UUID
                            let title: String?

                            enum CodingKeys: String, CodingKey {
                                case id
                                case memory_id
                                case title
                            }

                            init(from decoder: Decoder) throws {
                                let container = try decoder.container(keyedBy: CodingKeys.self)
                                if let v = try container.decodeIfPresent(UUID.self, forKey: .id) {
                                    id = v
                                } else {
                                    id = try container.decode(UUID.self, forKey: .memory_id)
                                }
                                title = try container.decodeIfPresent(String.self, forKey: .title)
                            }
                        }

                        let deleted = try JSONDecoder().decode(DeletedMemory.self, from: jsonData)

                        await MainActor.run {
                            if let index = dataStore.savedMemories.firstIndex(where: { $0.id == deleted.id }) {
                                dataStore.savedMemories.remove(at: index)

                                if let scene = self.MemoryJarView.scene as? MemoryJarScene {
                                    scene.removeHeart(memoryID: deleted.id)
                                }

                                self.refreshMemoryLaneUI()

                                if let navVC = self.navigationController,
                                   let topVC = navVC.topViewController,
                                   (topVC is memoryPhotoViewController || topVC is MemoryLaneViewController) {
                                    navVC.popToViewController(self, animated: true)
                                }
                            }
                        }
                    } catch {
                        print("Delete realtime handling error:", error)
                    }

                default:
                    break
                }
            }
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isEmptyState ? 1 : dataStore.savedMemories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isEmptyState {
               let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emptyMemoryState", for: indexPath) as! memoryEmptyStateCollectionViewCell
               cell.emptyTitleLabel.text = "No memory"
               cell.emptyImageView.image = UIImage(named: "empty_memory")
               return cell
           }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemoryLaneCell", for: indexPath) as! MemoryLaneCell
        let memory = dataStore.savedMemories[indexPath.item]
        cell.ImageView.image = memory.uiImage ?? UIImage(named: memory.imageName)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < dataStore.savedMemories.count else { return }

        let storyboard = UIStoryboard(name: "MemoryJar", bundle: nil)
        guard let laneVC = storyboard.instantiateViewController(withIdentifier: "MemoryLaneVC") as? MemoryLaneViewController else { return }

        laneVC.autoOpenIndex = indexPath.item

        if let nav = navigationController {
            nav.pushViewController(laneVC, animated: true)
        } else {
            laneVC.modalPresentationStyle = .fullScreen
            laneVC.modalTransitionStyle = .coverVertical
            present(laneVC, animated: true)
        }
    }

    private func generateLayout() -> UICollectionViewLayout {
        
        if isEmptyState {
               let itemSize = NSCollectionLayoutSize(
                   widthDimension: .fractionalWidth(1.0),
                   heightDimension: .absolute(110)
               )
               let item = NSCollectionLayoutItem(layoutSize: itemSize)
               let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
               let section = NSCollectionLayoutSection(group: group)
               section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
               section.orthogonalScrollingBehavior = .none
               return UICollectionViewCompositionalLayout(section: section)
           }
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(110),
            heightDimension: .absolute(110)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 2   // space between cells
        section.orthogonalScrollingBehavior = .continuous
        
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12) // left-right spacing
        
        return UICollectionViewCompositionalLayout(section: section)
    }

    @objc func showMemoryDisplay(_ notification: Notification) {
        
        guard let index = notification.object as? Int else { return }
        
        guard index >= 0 && index < dataStore.savedMemories.count else { return }
        
        if let displayVC = storyboard?.instantiateViewController(withIdentifier: "memoryDisplay") as? memoryDisplay {
            displayVC.memory = dataStore.savedMemories[index]
            displayVC.modalPresentationStyle = .pageSheet
            self.present(displayVC, animated: true)
        }
    }
}
