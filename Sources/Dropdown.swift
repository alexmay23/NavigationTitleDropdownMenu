//
//  Dropdown.swift
//  essaypro
//
//  Created by admin on 5/4/16.
//  Copyright © 2016 Alex Moiseenko. All rights reserved.
//

import Foundation
import UIKit


class DropdownMenuTableViewCell:UITableViewCell
{
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
   
}



public protocol DropdownMenuItem:CustomStringConvertible
{
    var font: UIFont { get }
    var titleColor: UIColor { get }
}


extension DropdownMenuItem
{

    var font: UIFont
    {
        return UIFont.boldSystemFont(ofSize: 15.0);
    }
    
    var titleColor: UIColor
    {
        return UIColor.black;
    }
    
}


class DropdownMenuTableViewDataSource: NSObject, UITableViewDataSource, UITableViewDelegate
{
    
    var items: [DropdownMenuItem] = [];
    
    var selectedIndex:Int = 0;
    
    var callback:((Int)->Void)!
    
    var selectedItem:DropdownMenuItem{
        return self.items[selectedIndex]
    }
    
    var cellHeight:CGFloat = 44.0
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DropdownMenuTableViewCell", for: indexPath) as!DropdownMenuTableViewCell
        let item = items[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = item.description;
        cell.textLabel?.textColor = item.titleColor;
        cell.textLabel?.font = item.font;
        return cell;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.cellHeight;
    }
    
    @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = (indexPath as NSIndexPath).row
        callback(selectedIndex)
        tableView.deselectRow(at: indexPath, animated: true);
    }
}

class DropdownMenuTableView:UITableView
{
    
    init()
    {
        super.init(frame:CGRect.zero, style:.plain);
        self.isScrollEnabled = false;
        self.translatesAutoresizingMaskIntoConstraints = false;
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
}


class BackgroundView: UIView
{
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    var tapCallback:((Void)->Void)?
    
    init()
    {
        super.init(frame: CGRect.zero);
        self.backgroundColor = UIColor.darkGray;
        self.alpha = 0.0;
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapped(_:)))
        self.addGestureRecognizer(self.tapGestureRecognizer);
    }
    
    @objc func didTapped(_ gestureRecognizer: UITapGestureRecognizer)
    {
        tapCallback?()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
}



public protocol DropdownMenuDelegate: class {
    
    func dropdownMenu(_ menu:DropdownMenu, didSelectItem item:DropdownMenuItem, atIndex index: Int)
}

public class DropdownMenu:NSObject
{
    let viewController:UIViewController
    
    public weak var delegate: DropdownMenuDelegate?
    
    var dropdownTableView:DropdownMenuTableView!
    
    var backgroundView: BackgroundView!
    
    
    var selectedIndex:Int{
        return self.dropdownMenuDatasource.selectedIndex
    }
    
    fileprivate var dropdownMenuDatasource = DropdownMenuTableViewDataSource()
    
    public var animationDuration = 0.33;
    
    var closedConstraint: NSLayoutConstraint!
    
    let image = UIImage(named: "Arrow", in: bundle, compatibleWith: nil);
    
    var arrowImageView: UIImageView!
    
    var openedConstraint: NSLayoutConstraint!
    
    public var tintColor: UIColor!{
        didSet{
            self.selectButton.setTitleColor(tintColor, for: .normal);
            self.arrowImageView.image = image!.withRenderingMode(.alwaysTemplate);
            self.arrowImageView.tintColor = self.tintColor;
        }
    }
    
    public var separatorColor: UIColor!{
        didSet
        {
            self.dropdownTableView.separatorColor = separatorColor;
        }
    }
    
    var backgroundViewConstraints: [NSLayoutConstraint]!
    
    fileprivate var isShowing: Bool = false;
    
    public var selectButton:UIButton!
    
    public var containerView:UIView!
    
    public init(inViewController viewController:UIViewController)
    {
        self.viewController = viewController;
        super.init();
        self.setup();
    }
    
    public func setItems(items:[DropdownMenuItem], selected:Int)
    {
        self.dropdownMenuDatasource.items = items;
        self.dropdownMenuDatasource.selectedIndex = selected;
        self.selectButton.setTitle(self.dropdownMenuDatasource.selectedItem.description, for: UIControlState());
        self.dropdownTableView.reloadData();
        self.resetTableHeight();
        
    }
    
    @discardableResult
    public func setItemInMenu(at index:Int)->DropdownMenuItem
    {
        self.dropdownMenuDatasource.selectedIndex = index;
        let dropdownMenuItem = self.dropdownMenuDatasource.selectedItem;
        self.selectButton.setTitle(dropdownMenuItem.description, for: UIControlState())
        self.selectButton.layoutIfNeeded();
        self.containerView.setNeedsUpdateConstraints();
        self.containerView.layoutIfNeeded();
        return dropdownMenuItem
    }
    
    public func setItemAtIndex(_ index:Int)
    {
        let dropdownMenuItem = setItemInMenu(at: index);
        self.hideMenu();
        delegate?.dropdownMenu(self, didSelectItem: dropdownMenuItem, atIndex: index);
    }
    
    @objc func selectButtonAction(_ button:UIButton)
    {
        self.toggleMenu();
    }
    
    func setup()
    {
        self.dropdownMenuDatasource.callback = self.setItemAtIndex;
        self.dropdownTableView = DropdownMenuTableView()
        self.dropdownTableView.delegate = self.dropdownMenuDatasource;
        self.dropdownTableView.dataSource = self.dropdownMenuDatasource;
        self.dropdownTableView.separatorColor = self.separatorColor;
        
        self.selectButton = UIButton(frame: CGRect.zero)
        self.selectButton.translatesAutoresizingMaskIntoConstraints = false;
        self.arrowImageView = UIImageView();
        self.arrowImageView.translatesAutoresizingMaskIntoConstraints = false;
        
        self.containerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 150.0, height: 44.0))
        self.containerView.addSubview(self.selectButton);
        self.containerView.addSubview(self.arrowImageView);
        self.containerView.addConstraint(NSLayoutConstraint(item: self.selectButton, attribute: .centerX, relatedBy: .equal, toItem: containerView, attribute: .centerX, multiplier: 1.0, constant: -10.0))
        self.containerView.addConstraint(NSLayoutConstraint(item: self.selectButton, attribute: .centerY, relatedBy: .equal, toItem: containerView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        self.containerView.addConstraint(NSLayoutConstraint(item: self.arrowImageView, attribute:.leading , relatedBy: .equal, toItem: self.selectButton, attribute: .trailing, multiplier: 1.0, constant: 10.0))
        self.containerView.addConstraint(NSLayoutConstraint(item: self.arrowImageView, attribute: .centerY, relatedBy: .equal, toItem: containerView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        
        self.selectButton.hitEdgeInsets = UIEdgeInsets(top: -10.0, left: -50.0, bottom: -10.0, right: -50.0)
    
        self.selectButton.addTarget(self, action: #selector(self.selectButtonAction(_:)), for: .touchUpInside);
        
        self.backgroundView = BackgroundView()
        
        self.backgroundView.tapCallback = self.hideMenu;
        
        self.configureDropdownMenuTableViewInController(self.viewController);
        self.configureBackgroundViewInController(self.viewController);
        
    }
    
    func resetTableHeight()
    {
        dropdownTableView.constraints.forEach{
            if $0.firstAttribute == NSLayoutAttribute.height{
                dropdownTableView.removeConstraint($0);
            }
        }
        dropdownTableView.addConstraint(NSLayoutConstraint(item: dropdownTableView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: CGFloat(self.dropdownMenuDatasource.items.count) * self.dropdownMenuDatasource.cellHeight));
        
    }
    
    func configureDropdownMenuTableViewInController(_ viewController:UIViewController)
    {
        let navigationBar = viewController.navigationController!.navigationBar;
        viewController.navigationController!.view.insertSubview(dropdownTableView, belowSubview: navigationBar);
        self.dropdownTableView.register(DropdownMenuTableViewCell.self, forCellReuseIdentifier: "DropdownMenuTableViewCell")
        viewController.navigationController!.view.addConstraint(NSLayoutConstraint(item: dropdownTableView, attribute: .width, relatedBy: .equal, toItem:  viewController.navigationController!.view, attribute: .width, multiplier: 1.0, constant: 0.0));
        self.closedConstraint = NSLayoutConstraint(item: dropdownTableView, attribute: .bottom, relatedBy: .equal, toItem: viewController.navigationController!.view, attribute: .top, multiplier: 1.0, constant: 0.0);
        self.openedConstraint = NSLayoutConstraint(item: dropdownTableView, attribute: .top, relatedBy: .equal, toItem: navigationBar, attribute: .bottom, multiplier: 1.0, constant: 0.0);
        self.openedConstraint.isActive = false;
        self.viewController.navigationController?.view.setNeedsLayout();
        self.viewController.navigationController?.view.layoutIfNeeded();
        viewController.navigationController!.view.addConstraints([self.openedConstraint, self.closedConstraint]);
    }
    
    
    func rotateArrow(_ reverse:Bool=false)
    {
        let (start, end) = reverse ? (Double.pi-0.01, 0.0) : (0.01, Double.pi)
        self.arrowImageView.layer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(start)))
        UIView.animate(withDuration: self.animationDuration){
            self.arrowImageView.layer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(end)))
        }
    }
    
    
    
    func configureBackgroundViewInController(_ viewController:UIViewController)
    {
        let view = self.viewController.navigationController!.view;
        self.backgroundViewConstraints = [
            NSLayoutConstraint(item: backgroundView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: backgroundView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: backgroundView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0)
        ]
    }
    
    public func toggleMenu()
    {
        isShowing ? hideMenu() : showMenu()
    }
    
    public func showMenu()
    {
        guard !isShowing else {return}
        
        self.rotateArrow();
        
        self.viewController.navigationController?.view.insertSubview(self.backgroundView, belowSubview: self.dropdownTableView);
        self.viewController.navigationController?.view.addConstraints(self.backgroundViewConstraints);
        self.viewController.navigationController?.view.setNeedsLayout();
        self.viewController.navigationController?.view.layoutIfNeeded();
        
        self.closedConstraint.isActive = false;
        self.openedConstraint.isActive = true;
        
        UIView.animate(withDuration: self.animationDuration){
            
            self.backgroundView.alpha = 0.5;
            self.viewController.navigationController?.view.layoutIfNeeded();
        }
        self.isShowing = true;
    }
    
    public func hideMenu()
    {
        guard isShowing else {return}
        
        self.rotateArrow(true);
        
        self.closedConstraint.isActive = true;
        self.openedConstraint.isActive = false;
        
        UIView.animate(withDuration: self.animationDuration, animations: {
            self.backgroundView.alpha  = 0.0;
            self.viewController.navigationController?.view.layoutIfNeeded();
        }){
            guard $0 else {return}
            self.backgroundView.removeFromSuperview();
            self.isShowing = false;
        }
        
    }
}








