import UIKit
import SpriteKit
import Supabase

class MemoryJarViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var memoryLaneCollectionView: UICollectionView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var MemoryJarView: SKView!

    private let loadingIndicator = UIActivityIndicatorView(style: .large)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        memoryLaneCollectionView.dataSource = self
        memoryLaneCollectionView.delegate   = self
        memoryLaneCollectionView.register(
            UINib(nibName: "memoryEmptyStateCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "emptyMemoryState"
        )
        MemoryJarView.allowsTransparency = true
        MemoryJarView.backgroundColor   = .clear
        addButton.configuration         = .glass()
        addButton.setTitle("Add", for: .normal)

        // Listen for new memories added locally (own) or by partner (via MemorySyncManager)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNewMemory(_:)),
            name: NSNotification.Name("MemoryAdded"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDeletedMemory(_:)),
            name: NSNotification.Name("MemoryDeleted"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showMemoryDisplay(_:)),
            name: NSNotification.Name("OpenMemory"),
            object: nil
        )

        memoryLaneCollectionView.alwaysBounceVertical  = false
        memoryLaneCollectionView.showsVerticalScrollIndicator = false
        memoryLaneCollectionView.contentInsetAdjustmentBehavior = .never

        // Loading indicator
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MemoryJarView.isPaused = false
        Task { await fetchMemoriesFromSupabase() }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        MemoryJarView.isPaused = true
        MemorySyncManager.shared.stop()
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

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Data

    private var isEmptyState: Bool { dataStore.savedMemories.isEmpty }

    /// Fetches memory metadata from Supabase DB, downloads any missing images,
    /// then shows hearts + photos together so the user never sees hearts without images.
    @MainActor
    func fetchMemoriesFromSupabase() async {
        guard let userId = SupabaseManager.shared.client.auth.currentUser?.id else { return }

        let isInitialLoad = dataStore.savedMemories.isEmpty
        if isInitialLoad {
            loadingIndicator.startAnimating()
            MemoryJarView.isHidden = true
            memoryLaneCollectionView.isHidden = true
        }

        do {
            // 1. Get relationship_id for this user
            let relResponse = try await SupabaseManager.shared.client
                .from("users")
                .select("relationship_id")
                .eq("user_id", value: userId.uuidString)
                .single()
                .execute()

            struct UserRelation: Decodable { let relationship_id: UUID? }
            let decodedRelation = try JSONDecoder().decode(UserRelation.self, from: relResponse.data)
            guard let relationshipId = decodedRelation.relationship_id else {
                stopLoading(isInitialLoad: isInitialLoad); return
            }

            // 2. Start sync manager NOW (before the memory fetch) so we
            //    never miss a Realtime event that fires during the fetch.
            MemorySyncManager.shared.start(
                relationshipId: relationshipId,
                currentUserId:  userId
            )

            // 3. Fetch all metadata rows for this couple
            let memResponse = try await SupabaseManager.shared.client
                .from("memories")
                .select()
                .eq("relationship_id", value: relationshipId.uuidString)
                .order("memory_date", ascending: true)
                .execute()

            let decoded = try JSONDecoder().decode([MemoryModel].self, from: memResponse.data)

            // 4. Download any images missing from local disk BEFORE showing the UI.
            //    This keeps the loading spinner up until every photo is ready,
            //    so hearts and images always appear together — never hearts-first.
            await downloadMissingImages(for: decoded, userId: userId)

            // 5. Build Memory objects — images are now guaranteed on disk (if download succeeded)
            let convertedMemories: [Memory] = decoded.map { item in
                let date      = ISO8601DateFormatter().date(from: item.memory_date) ?? Date()
                let localPath = MemoryFileManager.localURL(for: item.image_path).path
                let uiImage   = MemoryFileManager.loadImage(fileName: item.image_path)

                return Memory(
                    id:             item.id,
                    date:           date,
                    imageName:      item.image_path,
                    location:       "",
                    title:          item.title,
                    description:    item.description ?? "",
                    uiImage:        uiImage,
                    localImagePath: localPath
                )
            }

            // 6. Update data store and reveal UI — hearts and photos appear simultaneously
            dataStore.savedMemories = convertedMemories
            stopLoading(isInitialLoad: isInitialLoad)
            refreshMemoryLaneUI()
            syncJarHearts()

        } catch {
            stopLoading(isInitialLoad: isInitialLoad)
        }
    }

    // MARK: - Pre-show image catch-up

    /// Downloads images that are missing from local disk (e.g. partner added memories
    /// while this device was offline / the app was closed).
    /// Called BEFORE the UI is revealed — the loading spinner stays up during this
    /// wait so hearts and photos always appear together.
    private func downloadMissingImages(for items: [MemoryModel], userId: UUID) async {
        let supabase = SupabaseManager.shared.client

        for item in items {
            // Skip images already on disk — instant path, no network needed
            guard MemoryFileManager.loadImage(fileName: item.image_path) == nil else { continue }

            print("[MemoryJarVC] 📥 Downloading missing image: \(item.image_path)")

            do {
                let data = try await supabase.storage
                    .from("memory-images")
                    .download(path: item.image_path)

                MemoryFileManager.saveImage(data: data, fileName: item.image_path)
                print("[MemoryJarVC] ✅ Saved missing image (\(data.count) bytes): \(item.image_path)")

                // Mark is_synced = true so the uploader can clean up Supabase Storage.
                // Only applies to the partner's images, never our own.
                if item.user_id.uuidString != userId.uuidString {
                    try? await supabase
                        .from("memories")
                        .update(["is_synced": true])
                        .eq("memory_id", value: item.id.uuidString)
                        .execute()
                    print("[MemoryJarVC] ✅ Marked is_synced = true for \(item.id)")
                }

            } catch {
                print("[MemoryJarVC] ⚠️ Could not download missing image \(item.image_path): \(error)")
            }
        }
    }

    // MARK: - New Memory Handler (local + partner via MemorySyncManager)

    @objc func handleNewMemory(_ notification: Notification) {
        guard let localMemory = notification.object as? Memory else { return }

        DispatchQueue.main.async {
            guard !dataStore.savedMemories.contains(where: { $0.id == localMemory.id }) else { return }
            dataStore.savedMemories.append(localMemory)
            self.refreshMemoryLaneUI()

            if let scene = self.MemoryJarView.scene as? MemoryJarScene {
                let newIndex = dataStore.savedMemories.count - 1
                guard newIndex >= 0 else { return }
                scene.addHeart(index: newIndex, memoryID: localMemory.id, animate: true)

                let indexPath = IndexPath(item: newIndex, section: 0)
                if indexPath.item < self.memoryLaneCollectionView.numberOfItems(inSection: 0) {
                    self.memoryLaneCollectionView.scrollToItem(at: indexPath, at: .right, animated: true)
                }
            }
        }
    }

    /// Called when the PARTNER deletes a memory — removes heart and card in real-time.
    @objc func handleDeletedMemory(_ notification: Notification) {
        guard let deletedId = notification.object as? UUID else { return }

        DispatchQueue.main.async {
            guard let index = dataStore.savedMemories.firstIndex(where: { $0.id == deletedId }) else { return }
            dataStore.savedMemories.remove(at: index)

            if let scene = self.MemoryJarView.scene as? MemoryJarScene {
                scene.removeHeart(memoryID: deletedId)
            }
            self.refreshMemoryLaneUI()

            // If the user is currently viewing this memory, pop back to the jar
            if let navVC = self.navigationController,
               let topVC = navVC.topViewController,
               (topVC is memoryPhotoViewController || topVC is MemoryLaneViewController) {
                navVC.popToViewController(self, animated: true)
            }
        }
    }


    // MARK: - UI Helpers

    private var lastLayoutWasEmpty: Bool? = nil

    private func refreshMemoryLaneUI() {
        // 1. reloadData() first — commits the correct item count into UIKit's cache
        memoryLaneCollectionView.reloadData()

        // 2. Swap the layout only when empty-state changes, and defer it to the
        //    NEXT run loop cycle so UIKit processes reloadData() fully first.
        //    If setCollectionViewLayout fires synchronously during an active data
        //    change it triggers a layout pass with stale section counts → crash.
        let nowEmpty = isEmptyState
        guard lastLayoutWasEmpty != nowEmpty else { return }
        lastLayoutWasEmpty = nowEmpty

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.memoryLaneCollectionView.setCollectionViewLayout(
                self.generateLayout(), animated: false
            )
        }
    }

    private func syncJarHearts() {
        guard let scene = MemoryJarView.scene as? MemoryJarScene else { return }

        let currentHearts = scene.children.filter { $0.name?.hasPrefix("heart_") == true }
        let actualCount   = dataStore.savedMemories.count
        guard currentHearts.count != actualCount else { return }

        // Clear all existing hearts first
        currentHearts.forEach { $0.removeFromParent() }

        // Add hearts staggered — 80 ms per heart so the physics engine has time
        // to settle each one before the next appears. Combined with the grid-based
        // spawn positions in addHeart(animate:false), this prevents wall-embedding
        // and stuck-together clusters even with large memory counts.
        for (index, memory) in dataStore.savedMemories.enumerated() {
            let delay = Double(index) * 0.08
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak scene] in
                guard let scene = scene else { return }
                scene.addHeart(index: index, memoryID: memory.id, animate: false)
            }
        }
    }

    private func stopLoading(isInitialLoad: Bool) {
        guard isInitialLoad else { return }
        loadingIndicator.stopAnimating()
        UIView.animate(withDuration: 0.3) {
            self.MemoryJarView.isHidden = false
            self.memoryLaneCollectionView.isHidden = false
        }
    }

    // MARK: - Collection View

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isEmptyState ? 1 : dataStore.savedMemories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isEmptyState {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "emptyMemoryState", for: indexPath
            ) as! memoryEmptyStateCollectionViewCell
            cell.emptyTitleLabel.text  = "No memory"
            cell.emptyImageView.image  = UIImage(named: "empty_memory")
            return cell
        }

        let cell   = collectionView.dequeueReusableCell(withReuseIdentifier: "MemoryLaneCell", for: indexPath) as! MemoryLaneCell
        guard indexPath.item < dataStore.savedMemories.count else { return cell }
        let memory = dataStore.savedMemories[indexPath.item]

        // Clear stale image immediately on dequeue
        cell.ImageView.image = nil
        cell.tag = indexPath.item

        MemoryFileManager.loadImageAsync(fileName: memory.imageName) { [weak cell] image in
            guard let cell = cell, cell.tag == indexPath.item else { return }
            cell.ImageView.image = image ?? memory.uiImage
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < dataStore.savedMemories.count else { return }

        let storyboard = UIStoryboard(name: "MemoryJar", bundle: nil)
        guard let laneVC = storyboard.instantiateViewController(
            withIdentifier: "MemoryLaneVC"
        ) as? MemoryLaneViewController else { return }

        laneVC.autoOpenIndex = indexPath.item

        if let nav = navigationController {
            nav.pushViewController(laneVC, animated: true)
        } else {
            laneVC.modalPresentationStyle = .fullScreen
            laneVC.modalTransitionStyle   = .coverVertical
            present(laneVC, animated: true)
        }
    }

    // MARK: - Layout

    private func generateLayout() -> UICollectionViewLayout {
        if isEmptyState {
            let itemSize  = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(110))
            let item      = NSCollectionLayoutItem(layoutSize: itemSize)
            let group     = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
            let section   = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
            section.orthogonalScrollingBehavior = .none
            return UICollectionViewCompositionalLayout(section: section)
        }

        let itemSize  = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item      = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(110), heightDimension: .absolute(110))
        let group     = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section   = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing          = 2
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
        return UICollectionViewCompositionalLayout(section: section)
    }

    // MARK: - Memory Display

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
