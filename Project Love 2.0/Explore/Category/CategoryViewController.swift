
//
//  CategoryViewController.swift
//  Project Love 2.0
//

import UIKit

class CategoryViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var navigationTitle: UINavigationItem!
    @IBOutlet weak var activityCollectionView: UICollectionView!

    // MARK: - Input (set before navigation)
    var category: ActivityCategory?        // preferred
    var categoryName: String?              // optional fallback

    // MARK: - Data
    private var activities: [Activity] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        fetchActivities()
        registerCells()
    }

    // MARK: - Setup
    private func setupUI() {
        activityCollectionView.dataSource = self
        activityCollectionView.delegate = self

        // Screen title
        if let category = category {
            title = category.name
        } else if let name = categoryName {
            title = name
        } else {
            title = "Activities"
        }
    }

    private func fetchActivities() {
        if let category = category {
            activities = dataStore.getActivities(for: category)
        } else if let name = categoryName {
            activities = dataStore.getActivities(forCategoryName: name)
        }
    }

    private func registerCells() {
        activityCollectionView.register(
            UINib(nibName: "ActivityCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "activity_cell"
        )
    }
}
extension CategoryViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return activities.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "activity_cell",
            for: indexPath
        ) as! ActivityCollectionViewCell

        cell.configureCells(activity: activities[indexPath.row])
        return cell
    }
}
extension CategoryViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let modalVC = SmallModalViewController(
            nibName: "SmallModalViewController",
            bundle: nil
        )

        let selectedActivity = activities[indexPath.row]

        if let modalData = dataStore.smallmodal.first(
            where: { $0.title == selectedActivity.name }
        ) {
            modalVC.selectedActivity = modalData
        }

//        modalVC.flowSource = .category
        modalVC.modalPresentationStyle = .overFullScreen

        present(modalVC, animated: false)
    }
}
extension CategoryViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        let padding: CGFloat = 32
        let width = collectionView.bounds.width - padding
        let height: CGFloat = 115

        return CGSize(width: width, height: height)
    }
}
