//
//  SubredditTableViewCell.swift
//  beam
//
//  Created by Rens Verhoeven on 20-10-15.
//  Copyright © 2015 Awkward. All rights reserved.
//

import UIKit
import Snoo

protocol SubredditTableViewCellDelegate: class {
    
    func subredditTableViewCell(_ cell: SubredditTableViewCell, didTapStarOnSubreddit subreddit: Subreddit)
}

class SubredditTableViewCell: BeamTableViewCell {

    weak var delegate: SubredditTableViewCellDelegate?
    @IBOutlet fileprivate var titleLabel: UILabel!
    @IBOutlet fileprivate var starButton: UIButton!
    
    @IBOutlet fileprivate var titleLabelLeftConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate var starButtonLeftConstraint: NSLayoutConstraint!
    
    @IBOutlet fileprivate var previewImageView: UIImageView?
    @IBOutlet var previewLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.titleLabel.adjustsFontSizeToFitWidth = true
        self.titleLabel.minimumScaleFactor = 0.8
    }
    
    fileprivate var showStar = false {
        didSet {
            self.configureStarButton()
        }
    }
    
    fileprivate var subredditIsBookmarked: Bool {
        return (self.subreddit?.isBookmarked.boolValue ?? false)
    }

    var subreddit: Subreddit? {
        didSet {
            self.titleLabel.font = self.titleLabelFont
            self.titleLabel.attributedText = self.attributedTitle
            self.titleLabel.numberOfLines = self.starButtonEnabled ? 1 : 2
            self.previewLabel?.text = self.previewLabelText
            self.starButton.isEnabled = self.starButtonEnabled
            
            if self.subreddit?.identifier == Subreddit.frontpageIdentifier {
                //Use frontpage icon
                self.previewImageView?.image = UIImage(named: "subreddit_icon_frontpage")
                self.previewLabel?.isHidden = true
            } else if self.subreddit?.identifier == Subreddit.allIdentifier {
                //Use all icon
                self.previewImageView?.image = UIImage(named: "subreddit_icon_all")
                self.previewLabel?.isHidden = true
            } else {
                self.previewImageView?.image = nil
                self.previewLabel?.isHidden = false
            }
            self.updateImageMask()
            
            self.displayModeDidChange()
            self.configureStarButton()
            
        }
    }
    
    fileprivate var attributedTitle: NSAttributedString {
        let title = NSMutableAttributedString()
        
        if let titleString = self.subreddit?.displayName {
            let titleColor = self.displayMode == .dark ? UIColor.white : UIColor.black
            title.append(NSAttributedString(string: titleString,attributes: [NSForegroundColorAttributeName: titleColor]))
        }
        
        let subtitleColor = DisplayModeValue(UIColor.black.withAlphaComponent(0.8), darkValue: UIColor.white.withAlphaComponent(0.8))
        
        if self.subreddit?.identifier == Subreddit.frontpageIdentifier {
            title.append(NSAttributedString(string: "\n\(AWKLocalizedString("frontpage-description"))", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 13), NSForegroundColorAttributeName: subtitleColor]))
        } else if self.subreddit?.identifier == Subreddit.allIdentifier {
            title.append(NSAttributedString(string: "\n\(AWKLocalizedString("all-description"))", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 13), NSForegroundColorAttributeName: subtitleColor]))
        }
        
        return title
    }
    
    fileprivate var previewLabelText: String? {
        if let displayName = self.subreddit?.displayName , displayName.characters.count > 0{
            return displayName.substring(to: displayName.index(displayName.startIndex, offsetBy: 1)).uppercased(with: Locale.current)
        }
        return nil
    }
    
    fileprivate var starButtonEnabled: Bool {
        return (self.subreddit?.isPrepopulated != true)
    }
    
    fileprivate var titleLabelFont: UIFont {
        if self.subredditIsBookmarked {
            return UIFont.systemFont(ofSize: 17, weight: UIFontWeightSemibold)
        } else {
            return UIFont.systemFont(ofSize: 17, weight: UIFontWeightRegular)
        }
    }
    
    func configureStarButton() {
        if self.subredditIsBookmarked {
            self.starButton.setImage(UIImage(named: "tableview_star_filled"), for: UIControlState())
        } else {
            self.starButton.setImage(UIImage(named: "tableview_star"), for: UIControlState())
        }
        
        self.starButtonLeftConstraint.constant = (self.showStar ? -6 : -38)
        self.titleLabelLeftConstraint.constant = (self.showStar ? 38 : 7)
        
        self.displayModeDidChange()
    }
    
    override func displayModeDidChange() {
        super.displayModeDidChange()
        
        self.titleLabel.backgroundColor = self.contentView.backgroundColor
        self.titleLabel.isOpaque = true
        
        self.previewLabel?.textColor = UIColor.beamGreyLight()
        self.titleLabel.attributedText = self.attributedTitle
        
        let starHighlighted = self.starButton.isHighlighted || self.subreddit?.isBookmarked.boolValue == true
        
        switch self.displayMode {
        case .default:
            if starHighlighted {
                self.starButton.tintColor = UIColor(red: 250/255, green: 212/255, blue: 25/255, alpha: 1.0)
            } else {
                self.starButton.tintColor = UIColor(red: 201/255, green: 200/255, blue: 204/255, alpha: 1.0)
            }
            self.selectedBackgroundView = nil
            self.previewImageView?.backgroundColor = UIColor.beamGreyExtraExtraLight()
        case .dark:
            if starHighlighted {
                self.starButton.tintColor = UIColor(red: 250/255, green: 212/255, blue: 25/255, alpha: 0.6)
            } else {
                self.starButton.tintColor = UIColor(red: 201/255, green: 200/255, blue: 204/255, alpha: 1.0)
            }
            let view = UIView()
            view.backgroundColor = UIColor(red:0.16, green:0.16, blue:0.16, alpha:1)
            self.selectedBackgroundView = view
            self.previewImageView?.backgroundColor = UIColor.beamGreyDark()
        }
        if self.subreddit?.isPrepopulated == true {
            self.starButton.tintColor = UIColor(red:0.4, green:0.7, blue:1, alpha:1)
        }
    }
    
    @IBAction func tappedStarButton(_ sender: UIButton?) {
        if let subreddit = self.subreddit {
            self.delegate?.subredditTableViewCell(self, didTapStarOnSubreddit: subreddit)
        }
        
        self.configureStarButton()
    }
    
    @IBAction func updateStarButton(_ sender: UIButton?) {
        self.configureStarButton()
    }
    
    override func willTransition(to state: UITableViewCellStateMask) {

        self.showStar = state.contains(.showingEditControlMask)

        super.willTransition(to: state)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateImageMask()
            self.titleLabel.numberOfLines = (self.bounds.height > 44) ? 2 : 1
    }
    
    func updateImageMask() {
        if let bounds = self.previewImageView?.bounds {
            let layer = CAShapeLayer()
            layer.frame = bounds
            layer.path = UIBezierPath(ovalIn: bounds).cgPath
            layer.fillColor = UIColor.black.cgColor
            layer.contentsScale = UIScreen.main.scale
            self.previewImageView?.layer.mask = layer
        }
    }
    
    
}
