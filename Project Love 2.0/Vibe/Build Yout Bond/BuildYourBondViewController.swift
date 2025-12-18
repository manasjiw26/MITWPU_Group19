//
//  BuildYourBondViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

class BuildYourBondViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var selectedbondOption: BuildYourBond?
    var bondPage: BuildYourBondpage?
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        registerCell()

        guard let selectedBond = selectedbondOption else { return }

        let page = dataStore.getBuildYourBondPages(name: selectedBond.name)
        self.bondPage = page

        collectionView.setCollectionViewLayout(generateLayout(), animated: false)
    }
    func registerCell(){
        
        
        collectionView.register(UINib(nibName: "BUBSection1CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BondHeaderCell")
        collectionView.register(UINib(nibName: "BUBSection2CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BondBadgeCell")
        collectionView.register(UINib(nibName: "BUBSection3CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BondHIWCell")
        collectionView.register(UINib(nibName: "BondHIWCell", bundle: nil), forCellWithReuseIdentifier: "BondProgressCell")
        collectionView.register(UINib(nibName: "BUBSection4CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BondActivitiesCell")
        collectionView.register(UINib(nibName: "TitleCollectionResuableView", bundle: nil), forSupplementaryViewOfKind: "title", withReuseIdentifier: "title_cell")
    }
    func generateLayout() ->UICollectionViewLayout{
        let layout = UICollectionViewCompositionalLayout { section, env in
            let titleSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
            let titleItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: titleSize, elementKind: "title", alignment: .top)
            
            if section == 0 {
                let item = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1.0),
                            heightDimension: .absolute(200)
                        )
                    )

                    // Optional: small internal item padding
                    item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

                    let group = NSCollectionLayoutGroup.vertical(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1.0),
                            heightDimension: .absolute(200)
                        ),
                        subitems: [item]
                    )

                    let section = NSCollectionLayoutSection(group: group)

                    // Outer card padding
                    section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)

                    return section
            }
            else if section == 1{
                let itemSize = NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1.0),
                            heightDimension: .fractionalHeight(1.0)
                        )
                        let item = NSCollectionLayoutItem(layoutSize: itemSize)
                        
                        // GROUP
                        let groupSize = NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1.0),
                            heightDimension: .estimated(240)  // Adjust based on your content height
                        )
                        let group = NSCollectionLayoutGroup.vertical(
                            layoutSize: groupSize,
                            subitems: [item]
                        )
                        
                        // SECTION
                        let section = NSCollectionLayoutSection(group: group)
                        section.contentInsets = NSDirectionalEdgeInsets(
                            top: 0,
                            leading: 20,
                            bottom: 15,
                            trailing: 20
                        )
                        
                        return section
            }
            else if section == 2{
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(204)
                )

                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: itemSize,
                    subitems: [item]
                )

                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 0, leading: 16, bottom: 15, trailing: 16
                )
                section.boundarySupplementaryItems = [titleItem]

                return section
            }
            else{
                let itemSize = NSCollectionLayoutSize(
                          widthDimension: .fractionalWidth(1.0),
                          heightDimension: .absolute(125) // auto height for labels
                      )
                      let item = NSCollectionLayoutItem(layoutSize: itemSize)

                      // GROUP (vertical list)
                      let groupSize = NSCollectionLayoutSize(
                          widthDimension: .fractionalWidth(1.0),
                          heightDimension: .absolute(125)
                      )
                      let group = NSCollectionLayoutGroup.vertical(
                          layoutSize: groupSize,
                          subitems: [item]
                      )

                      // SECTION
                      let section = NSCollectionLayoutSection(group: group)

                      // outer spacing (card margins)
                      section.contentInsets = NSDirectionalEdgeInsets(
                          top: 5,
                          leading: 16,
                          bottom: 0,
                          trailing: 16
                      )

                      // spacing between cards (this is where your dotted line visually fits)
                      section.interGroupSpacing = 8
                section.boundarySupplementaryItems = [titleItem]

                      return section
            }
            
        }
        return layout
        
    }
}
extension BuildYourBondViewController:  UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else if section == 1 {
            return 1
        }
        else if section == 2 {
            return 1
        }
        else {
            return 4
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BondHeaderCell", for: indexPath) as! BUBSection1CollectionViewCell
            if let bp = bondPage {
                cell.configure(bond: bp)
            }
            return cell

        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BondBadgeCell", for: indexPath) as! BUBSection2CollectionViewCell
            if let bp = bondPage {
                cell.configureCells(bond: bp)
            }
            return cell

        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BondHIWCell", for: indexPath) as! BUBSection3CollectionViewCell
            if let bp = bondPage {
                cell.configureCells(bond: bp)
            }
            return cell

        case 3:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "BondActivitiesCell",
                for: indexPath
            ) as! BUBSection4CollectionViewCell

            if let bp = bondPage {
                let activity = bp.activity[indexPath.item]
                cell.configureCells(
                    activity: activity,
                    index: indexPath.item,
                    total: bp.activity.count
                )
            }

            return cell

        default:
            return UICollectionViewCell()
        }
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let title = collectionView.dequeueReusableSupplementaryView(ofKind: "title", withReuseIdentifier: "title_cell", for: indexPath) as! TitleCollectionResuableView
        
        if indexPath.section == 2 {
            title.configureTitle(title: "How it works", subtitle: "")
        } else if indexPath.section == 3 {
            title.configureTitle(title: "Your journey steps", subtitle: "")
        }
        return title
    }
}
extension BuildYourBondViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0{
            
        }
    }
}
