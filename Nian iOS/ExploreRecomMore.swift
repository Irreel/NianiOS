//
//  ExploreRecomMore.swift
//  Nian iOS
//
//  Created by WebosterBob on 8/19/15.
//  Copyright (c) 2015 Sa. All rights reserved.
//

import UIKit

class ExploreRecomMore: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var titleOn: String!
    var dataArray = NSMutableArray()
    
    var page = 0
    var lastID = ""
    
    // 设置一个滚动时的 target rect, 目的是为了判断要不要加载图片
    var targetRect: NSValue?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        viewBack()
        setupView()
        
        self.titleLabel.text = titleOn
        self.collectionView.registerNib(UINib(nibName: "ExploreMoreCell", bundle: nil), forCellWithReuseIdentifier: "ExploreMoreCell")
        self.collectionView.dataSource = self
        self.collectionView.delegate = self 
        
        self.collectionView.headerBeginRefreshing()
        load(false)
    }

    func setupView() {
        let flowLayout = UICollectionViewFlowLayout()
        
//        let Q = isiPhone6P ? 4 : 3
        let Q = 3
        let x = (globalWidth - CGFloat(80 * Q))/CGFloat(2 * (Q + 1))
        let y = x + x
        
        flowLayout.minimumInteritemSpacing = x
        flowLayout.minimumLineSpacing = y
        flowLayout.itemSize = CGSize(width: 80, height: 120)
        flowLayout.sectionInset = UIEdgeInsets(top: y, left: y, bottom: y, right: y)
        self.collectionView.collectionViewLayout = flowLayout
        
        self.collectionView.addHeaderWithCallback(onPullDown)
        self.collectionView.addFooterWithCallback(onPullUp)

    }
    
    func onPullDown() {
        page = 1
        self.lastID = "0"
        load(true)
    }
    
    func onPullUp() {
        load(false)
    }
    
    
    func load(clear: Bool) {
        if clear {
            page = 1
        }
        
        if titleOn == "编辑推荐" {
            Api.getDiscoverEditorRecom("\(page++)", callback: {
                json in
                if json != nil {
                    let err = json!.objectForKey("error") as? NSNumber
                    if err == 0 {
                        if clear {
                            self.dataArray.removeAllObjects()
                        }
                        let data = json!.objectForKey("data") as? NSArray
                        if data != nil {
                            for item: AnyObject in data! {
                                self.dataArray.addObject(item)
                            }
                            
                            self.collectionView.headerEndRefreshing()
                            self.collectionView.footerEndRefreshing()
                            
                            self.collectionView.reloadData()
                        }
                    }
                }
            })
        } else if titleOn == "最新" {
            Api.getDiscoverLatest("\(page++)", callback: {
                json in
                if json != nil {
                    let err = json!.objectForKey("error") as? NSNumber
                    if err == 0 {
                        if clear {
                            self.dataArray.removeAllObjects()
                        }
                        let data = json!.objectForKey("data") as? NSArray
                        if data != nil {
                            for item: AnyObject in data! {
                                let _img = (item as! NSDictionary).objectForKey("image") as! String
                                let _imgSplit = _img.componentsSeparatedByString(".")  //_img.characters.split{$0 = "."}.map(String.init)    //split(_img.characters){$0 = "."}.map(String.init)
                                
                                if let _ = Int(_imgSplit[0]) {
                                } else {
                                    self.dataArray.addObject(item)
                                }
                            }
                            
                            self.collectionView.headerEndRefreshing()
                            self.collectionView.footerEndRefreshing()
                            
                            self.collectionView.reloadData()
                        }
                    }
                }
            })
        }
    }
    
    
    /**
    - returns: Bool值，代表是否要加载图片
    */
    func shouldLoadCellImage(cell: ExploreMoreCell, withIndexPath indexPath: NSIndexPath) -> Bool {
        let attr = self.collectionView.layoutAttributesForItemAtIndexPath(indexPath)
        let cellFrame = attr?.frame
        
        if (self.targetRect != nil) && !CGRectIntersectsRect(self.targetRect!.CGRectValue(), cellFrame!) {
            return false
        }
        
        return true
    }
    
}

extension ExploreRecomMore : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ExploreMoreCell", forIndexPath: indexPath) as! ExploreMoreCell
        let _tmpData = self.dataArray.objectAtIndex(indexPath.row) as! NSDictionary
        
        if let _img = _tmpData.objectForKey("image") as? String {
            cell.coverImageView?.setImage("http://img.nian.so/dream/\(_img)!dream", placeHolder: IconColor, bool: false)
        }
        cell.titleLabel?.text = SADecode(_tmpData.objectForKey("title") as! String)
        
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let DreamVC = DreamViewController()
        DreamVC.Id = (self.dataArray.objectAtIndex(indexPath.row) as! NSDictionary)["id"] as! String
        
        if DreamVC.Id != "0" && DreamVC.Id != "" {
            self.navigationController?.pushViewController(DreamVC, animated: true)
        }
    }
    
}

extension ExploreRecomMore: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.targetRect = nil
        
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let targetRect: CGRect = CGRectMake(targetContentOffset.memory.x, targetContentOffset.memory.y, scrollView.frame.size.width, scrollView.frame.size.height)
        self.targetRect = NSValue(CGRect: targetRect)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView is UITableView {
            self.targetRect = nil
            
            self.loadImagesForVisibleCells()
        }
    }
    
    func loadImagesForVisibleCells() {
        let cellArray = self.collectionView.visibleCells
        
        for cell in cellArray() {
            if cell is ExploreMoreCell {
                let indexPath = self.collectionView.indexPathForCell(cell as! ExploreMoreCell)
                
                var _tmpShouldLoadImg = false
                _tmpShouldLoadImg = self.shouldLoadCellImage(cell as! ExploreMoreCell, withIndexPath: indexPath!)
                
                if _tmpShouldLoadImg {
                    self.collectionView.reloadItemsAtIndexPaths([indexPath!])
                }
            }
        }
    }
}




