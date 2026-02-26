//
//  LoveNotePageViewController.swift
//  Project Love 2.0
//

import UIKit

class LoveNotePageViewController: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var sectionTitleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var addButton: UIBarButtonItem!

    private var filteredNotes: [LoveNote] = []
    private var didSetLayout = false

    override func viewDidLoad() {
        super.viewDidLoad()
      
        setupCollectionView()


        segmentedControl.selectedSegmentIndex = 0
        sectionTitleLabel.text = "Sent"

        applyFilter()
        
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !didSetLayout {
            collectionView.collectionViewLayout = generateLayout()
            didSetLayout = true
        }
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self

        let nib = UINib(nibName: "LoveNoteCardCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "LoveNoteCardCell")
    }


    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        print("Segment changed to:", sender.selectedSegmentIndex)
        applyFilter()
    }



    private func applyFilter() {
        let notes = DataStore.shared.loveNotes

        switch segmentedControl.selectedSegmentIndex {
        case 0:
            filteredNotes = notes.filter { $0.status == .sent }
            sectionTitleLabel.text = "Sent"

        case 1:
            filteredNotes = notes.filter { $0.status == .received }
            sectionTitleLabel.text = "Received"

        case 2:
            filteredNotes = notes.filter { $0.status == .scheduled }
            sectionTitleLabel.text = "Scheduled"

        default:
            filteredNotes = []
        }

        collectionView.reloadData()
    }


    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
    }
    @IBAction func addButtonTapped(_ sender: Any) {
        presentLoveNotePopup()
    }

    private func presentLoveNotePopup() {
        let storyboard = UIStoryboard(name: "LoveNote", bundle: nil)

        let vc = storyboard.instantiateViewController(
            withIdentifier: "LoveNoteViewController"
        ) as! LoveNoteViewController

 
        vc.onSave = { [weak self] newNote in
            DataStore.shared.addLoveNote(newNote)
            self?.applyFilter()
        }

        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve

        present(vc, animated: true)
    }

    private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 8, left: 12, bottom: 12, right: 12)
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        return layout
    }
}

extension LoveNotePageViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filteredNotes.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "LoveNoteCardCell",
            for: indexPath
        ) as! LoveNoteCardCell

        cell.configure(with: filteredNotes[indexPath.item])
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        let selectedNote = filteredNotes[indexPath.item]
        
        let storyboard = UIStoryboard(name: "LoveNote", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "LoveNoteDetailVC"
        ) as! LoveNoteDetail2ViewController
        
        
        vc.note = selectedNote
        vc.onDismiss = { [weak self] in
                self?.applyFilter()
            }
        
        vc.modalPresentationStyle = .pageSheet
        present(vc, animated: true)
    }
}


  








