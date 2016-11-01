//
//  NatureViewController.swift
//  Trails
//
//  Created by Rui Policarpo on 03/04/16.
//  Copyright © 2016 nExp. All rights reserved.
//

import UIKit

class NatureViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    let tipsArray:NSArray = NSArray.init(array: ["Siga apenas pelo trilho sinalizado.","Respeite a propriedade privada.","Evite fazer ruídos desnecessários.","Observe a fauna à distância.","Não dani que nem recolha amostras de plantas ou rochas.","Não deixe lixo ou outros vestígios da sua passagem.","Não faça lume e tenha cuidado com as beatas dos cigarros.","Cuidado com o gado. Embora manso, não gosta da aproximação de estranhos às suas crias.","Deixe as cancelas como as encontrou. Se estiverem fechadas, con rme que  cam bem fechadas.","Seja afável com os habitantes locais."])
    let tipsImageArray:NSArray = NSArray.init(array: ["sings","private","noSound","binoculars","plant","garbage","fire","lamb","gate","heart"])

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
    }
    
    //TABLEVIEW DELEGATE
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0){
            return 1
        }else if (section == 1){
            return tipsArray.count
        }else {
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        
        
        if (indexPath.section == 0){
            let collectionCell:natureCollectioViewRow = self.tableView.dequeueReusableCellWithIdentifier("collectionViewRow", forIndexPath: indexPath) as! natureCollectioViewRow
            collectionCell.layer.shadowColor = UIColor.blackColor().CGColor
            collectionCell.layer.shadowOffset = CGSizeMake(0.0, 0.0)
            collectionCell.layer.shadowRadius = 8.0
            collectionCell.layer.shadowOpacity = 0.3
            collectionCell.backgroundColor = UIColor.clearColor()
            return collectionCell
        }else {
            let simpleInfoCell:natureTableViewInfoCell = self.tableView.dequeueReusableCellWithIdentifier("simpleInfoCell", forIndexPath: indexPath) as! natureTableViewInfoCell
            
            simpleInfoCell.labelInfo.layer.shadowColor = UIColor.blackColor().CGColor
            simpleInfoCell.labelInfo.layer.shadowOffset = CGSizeMake(0.0, 0.0)
            simpleInfoCell.labelInfo.layer.shadowRadius = 6.0
            simpleInfoCell.labelInfo.layer.shadowOpacity = 0.7
            
            simpleInfoCell.imageContainer.layer.shadowColor = UIColor.blackColor().CGColor
            simpleInfoCell.imageContainer.layer.shadowOffset = CGSizeMake(0.0, 0.0)
            simpleInfoCell.imageContainer.layer.shadowRadius = 8.0
            simpleInfoCell.imageContainer.layer.shadowOpacity = 0.3
            simpleInfoCell.imageContainer.layer.cornerRadius = 5
            simpleInfoCell.imageContainer.layer.masksToBounds = true
            
            simpleInfoCell.labelInfo.text = tipsArray[indexPath.row] as! String
            simpleInfoCell.imageViewRow.image = UIImage(named: tipsImageArray[indexPath.row] as! String)
            simpleInfoCell.backgroundColor = UIColor.clearColor()
            return simpleInfoCell
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.section == 0){
            return 195
        }else{
            return 79
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0){
            return "Sinalética"
        }else if (section == 1){
            return "Código de conduta"
        }else{
            return  ""
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}


class natureCollectionViewCell:UICollectionViewCell{
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelInfo: UILabel!
}

class natureCollectioViewRow:UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource{
    @IBOutlet weak var collectionView: UICollectionView!
    
    let imagesArray:NSArray = NSArray.init(array: ["certo","errado","esquerda","direita"])
    let descriptionArray:NSArray = NSArray.init(array: ["caminho certo"," caminho errado","virar à esquerda"," virar à direita"])
    
    //COLLECTIONVIEW DELEGATE
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let collectionViewCell = self.collectionView.dequeueReusableCellWithReuseIdentifier("collCell", forIndexPath: indexPath) as! natureCollectionViewCell
        collectionViewCell.layer.cornerRadius = 5
        collectionViewCell.layer.masksToBounds = true

        collectionViewCell.imageView.image = UIImage(named: imagesArray[indexPath.row] as! String)
        collectionViewCell.labelInfo.text = descriptionArray[indexPath.row] as! String
        
        return collectionViewCell
    }
}

class natureTableViewInfoCell:UITableViewCell{
    @IBOutlet weak var imageViewRow: UIImageView!
    @IBOutlet weak var labelInfo: UILabel!
    @IBOutlet weak var imageContainer: UIView!
}