//
//  CardParser.swift
//  assistance
//
//  Created by Nicko on 18/01/16.
//  Copyright © 2016 Darmstadt University of Technology. All rights reserved.
//

import UIKit

import MapKit

import SDWebImage

class CardParser: NSObject, MKMapViewDelegate {
    
    static let sharedParser = CardParser()
    
    var tableViewController = UITableViewController()
    
    let appTintColor = UIView.appearance().tintColor
    
    func parseObject(object: [String: AnyObject], superview: UIView) {
        let type = object["type"] as! String
        
        switch type {
            case "group": parseGroup(object, superview: superview)
            case "text": parseText(object, superview: superview)
            case "image": parseImage(object, superview: superview)
            case "map": parseMap(object, superview: superview)
            case "button": parseButton(object, superview: superview)
            default: break
        }
    }
    
    func parseGroup(groupObject: [String: AnyObject], superview: UIView) {
        let stackView = UIStackView()
        
        stackView.spacing = 4.0
        
        if let alignment = groupObject["alignment"] as? String where alignment == "vertical" {
            stackView.axis = .Vertical
        }
        
        let content = groupObject["content"] as! [[String: AnyObject]]
        for object in content {
            parseObject(object, superview: stackView)
        }
        
        if let target = groupObject["target"] as? String {
            addTarget(target, toView: stackView)
        }
        
        addView(stackView, toSuperview: superview)
    }
    
    func parseText(textObject: [String: AnyObject], superview: UIView) {
        let label = UILabel()
        
        label.numberOfLines = 0
        label.lineBreakMode = .ByWordWrapping
        
        label.text = textObject["caption"] as? String
        
        if let alignment = textObject["alignment"] as? String {
            switch alignment {
                case "left": label.textAlignment = .Left
                case "center": label.textAlignment = .Center
                case "right": label.textAlignment = .Right
                default: label.textAlignment = .Left
            }
        }
        
        if let style = textObject["style"] as? String {
            switch style {
                case "title1": label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleTitle1)
                case "title2": label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleTitle2)
                case "title3": label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleTitle3)
                case "headline": label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
                case "subheadline": label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
                case "body": label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
                case "callout": label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCallout)
                case "footnote": label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
                case "caption1": label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
                case "caption2": label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
                default: label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            }
        }
        
        if let highlighted = textObject["highlighted"] as? Bool where highlighted {
            label.textColor = appTintColor
        }
        
        if let target = textObject["target"] as? String {
            addTarget(target, toView: label)
        }
        
        addView(label, toSuperview: superview)
    }
    
    func parseImage(imageObject: [String: AnyObject], superview: UIView) {
        let imageView = UIImageView()
        
        if let imageURL = NSURL(string: imageObject["source"] as! String) {
            imageView.sd_setImageWithURL(imageURL) {
                image, error, cacheType, imageURL in
                
                if cacheType == .None {
                    self.tableViewController.tableView.reloadData()
                }
            }
        }
        
        if let image = imageView.image {
            var width = 0.0
            var height = 0.0
            if image.size.height <= 150 {
                width = Double(image.size.width)
                height = Double(image.size.height)
            } else {
                width = 150
                height = 150
            }
            
            let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:[mapView(width)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["width": width], views: ["imageView": imageView])
            let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[mapView(height)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["height": height], views: ["imageView": imageView])
            superview.addConstraints(horizontalConstraints + verticalConstraints)
        }
        
        if let target = imageObject["target"] as? String {
            addTarget(target, toView: imageView)
        }
        
        addView(imageView, toSuperview: superview)
    }
    
    func parseMap(mapObject: [String: AnyObject], superview: UIView) {
        let mapView = MKMapView()
        mapView.delegate = self
        
        mapView.zoomEnabled = false
        mapView.scrollEnabled = false
        mapView.pitchEnabled = false
        mapView.rotateEnabled = false
        
        if let showUserLocation = mapObject["showUserLocation"] as? Bool {
            mapView.showsUserLocation = showUserLocation
        }
        
        if let points = mapObject["points"] as? [[Double]] {
            for point in points {
                let pointAnnotation = MKPointAnnotation()
                pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: point[0], longitude: point[1])
                mapView.addAnnotation(pointAnnotation)
            }
            mapView.showAnnotations(mapView.annotations, animated: false)
        }
        
        if let target = mapObject["target"] as? String {
            addTarget(target, toView: mapView)
        }
        
        addView(mapView, toSuperview: superview)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[mapView(150)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["mapView": mapView])
        superview.addConstraints(verticalConstraints)
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        if mapView.showsUserLocation {
            mapView.showAnnotations(mapView.annotations + [mapView.userLocation], animated: false)
        } else {
            mapView.showAnnotations(mapView.annotations, animated: false)
        }
    }
    
    func parseButton(buttonObject: [String: AnyObject], superview: UIView) {
        let button = UIButton()
        
        button.setTitle(buttonObject["caption"] as? String, forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.backgroundColor = appTintColor
        
        button.onTouchUpInside {
            sender in
            
            let target = buttonObject["target"] as! String
            if let url = NSURL(string: target) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
        
        addView(button, toSuperview: superview)
    }
    
    func addTarget(target: String, toView view: UIView) {
        view.userInteractionEnabled = true
        
        view.addGestureRecognizer(UITapGestureRecognizer() {
            if let url = NSURL(string: target) {
                UIApplication.sharedApplication().openURL(url)
            }
        })
    }
    
    func addView(view: UIView, toSuperview superview: UIView) {
        if superview is UIStackView {
            (superview as! UIStackView).addArrangedSubview(view)
        } else {
            superview.addSubview(view)
        }
    }
    
}