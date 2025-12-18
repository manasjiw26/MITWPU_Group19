//
//  TellMoodSelectionViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 16/12/25.
//

import UIKit
protocol TellMoodSelectionDelegate: AnyObject {
    func didSelectMood(_ mood: MoodCheckIn, at indexPath: IndexPath)
}

class TellMoodSelectionViewController: UIViewController {

    weak var delegate: TellMoodSelectionDelegate?
       var selectedIndexPath: IndexPath?
    
    @IBOutlet weak var titleLabel: UILabel!
       @IBOutlet weak var subtitleLabel: UILabel!
       @IBOutlet weak var collectionView: UICollectionView!
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let image = UIImage(
            systemName: "chevron.left",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
        )
        button.setImage(image, for: .normal)
        button.tintColor = .black
        
        return button
    }()
    
    let moods = DataStore.shared.moodOptions
    var screenTitle1: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        backButton.configuration = .glass()
        setupBackButton()
        titleLabel.text = screenTitle1
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.estimatedItemSize = .zero
        }
    }
    
    private func setupBackButton() {
        view.addSubview(backButton)
        
        backButton.addTarget(
            self,
            action: #selector(backTapped),
            for: .touchUpInside
        )
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 0
            ),
            backButton.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 16
            ),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func backTapped() {
        dismiss(animated: true)
    }
    
}
extension TellMoodSelectionViewController:
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout {

        func collectionView(_ collectionView: UICollectionView,
                            numberOfItemsInSection section: Int) -> Int {
            moods.count
        }

        func collectionView(_ collectionView: UICollectionView,
                            cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "MoodCell",
                for: indexPath
            ) as! MoodCell

            let mood = moods[indexPath.item]

            cell.moodLabel.text = mood.title
            cell.moodImageView.image = UIImage(named: mood.imageName)


            cell.layer.cornerRadius = 16
            cell.backgroundColor = .white
           
            return cell
        }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 106, height: 110)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {

        // Screen width math for PERFECT centering
        let totalCellWidth = (106 * 3)        // 3 cells
        let totalSpacing = (16 * 2)           // space between cells
        let totalUsed = CGFloat(totalCellWidth + totalSpacing)

        let sideInset = (collectionView.bounds.width - totalUsed) / 2

        return UIEdgeInsets(top: 20,
                            left: sideInset,
                            bottom: 24,
                            right: sideInset)
    }


    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        let selectedMood = moods[indexPath.item]

        dataStore.setHisMood(moodId: selectedMood.id)
        
        //delegate?.didSelectMood(moodCheckIn, at: selectedIndexPath)
        dismiss(animated: true)
    }

    }

