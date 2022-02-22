//
//  ViewController.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 1/15/21.
//

import UIKit

class SleepViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var curIndex: Int = 0
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let top: CGFloat = 0
        let bottom: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height
        let scrollPosition = scrollView.contentOffset.y
        //print(scrollPosition)
    }
    

    var tindex: [Int] = []
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("numberOfRowsInSection")
        return tindex.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRowAt: \(indexPath.row)")
        curIndex = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "sleepCell", for: indexPath)
        cell.textLabel?.text = "\(tindex[indexPath.row])"
       

        return cell
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for i in 0...1000{
            tindex.append(i)
            //index.insert(i, at: 0)
        }
        tableView.dataSource = self
        tableView.delegate = self
        
        let toprow = IndexPath(row: 500, section: 0)
        
        self.tableView.scrollToRow(at: toprow, at: .top, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
//        if(indexPath.row == 0) {
//            print("yo")
//            tableView.reloadData()
//
//        }
    }
}

    
    



