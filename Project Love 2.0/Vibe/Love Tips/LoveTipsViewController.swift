//
//  LoveTipsViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 26/11/25.
//

import UIKit

class LoveTipsViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    var tips = dataStore.getTips()
       // To track selected radio button
    
       var selectedIndex: Int? = nil
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("\(tips.count)")
        return tips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tipOption", for: indexPath) as! TipTableViewCell
                
                let tip = tips[indexPath.row]
                let isSelected = (selectedIndex == indexPath.row)
                
                cell.configure(option: tip.title, isSelected: isSelected)
                
                // Button Action
                cell.radioButton.tag = indexPath.row
                cell.radioButton.addTarget(self, action: #selector(radioTapped(_:)), for: .touchUpInside)
        
                
                return cell
    }
    
    // User tapped row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        tableView.reloadData()
    }
    
    // User tapped radio button
        @objc func radioTapped(_ sender: UIButton) {
            selectedIndex = sender.tag
            tableView.reloadData()
        }
    

    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    @IBOutlet weak var tableView: UITableView!
    
//    @IBOutlet weak var tableHieghtConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        tableView.backgroundColor = .appBackground
      
        // Do any additional setup after loading the view.
        setDescriptionLabel()
        
    }
    
    func setDescriptionLabel() {
        self.descriptionLabel.text = "Here are a few quick ways to brighten her day Pick one that feels right!"
    }
    
    func setupTableView() {
          tableView.delegate = self
          tableView.dataSource = self
          
          tableView.tableFooterView = UIView()
        tableView.separatorStyle = .singleLine
      }
  
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
