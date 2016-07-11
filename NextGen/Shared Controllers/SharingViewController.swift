//
//  SharingViewController.swift
//

import UIKit
import NextGenDataManager

class SharingViewController: SceneDetailViewController {
    
    @IBOutlet weak var player: UIView!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var clipDurationLabel: UILabel!
    @IBOutlet weak var clipNameLabel: UILabel!
    @IBOutlet weak var clipThumbnailImageView: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var videoBackgroundView: UIView!
    private var _videoPlayerViewController: VideoPlayerViewController?
    
    private var _clips = [NSURL]?()
    //private var _clips = [NGDMTimedEvent]?()
    private var _index = 0
    
    private var _shareableURL: NSURL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        videoBackgroundView.backgroundColor = UIColor.init(red: 17/255, green: 17/255, blue: 19/255, alpha: 1)
        _clips = []
        self.view.translatesAutoresizingMaskIntoConstraints = true
        // Localizations
        shareButton.setTitle(String.localize("clipshare.share_button").uppercaseString, forState: UIControlState.Normal)
        
        clipNameLabel.text = timedEvent?.descriptionText
        
        if let imageURL = timedEvent?.imageURL {
            clipThumbnailImageView.setImageWithURL(imageURL, completion: nil)
        } else {
            clipThumbnailImageView.image = UIImage.themeDefaultImage16By9()
        }
        
        if let videoURL = timedEvent?.audioVisual?.videoURL {
            _shareableURL = videoURL
            for i in 0...3{
                _clips!.append( _shareableURL!)
            }
        }
        
        self.clipDurationLabel.text = ((timedEvent?.endTime ?? 0) - (timedEvent?.startTime ?? 0)).timeString()
    }

    func replaceClip(){
        
        if let videoPlayerViewController = UIStoryboard.getNextGenViewController(VideoPlayerViewController) as? VideoPlayerViewController  {
            if let player = videoPlayerViewController.player {
                player.removeAllItems()
            }

            videoPlayerViewController.curIndex = 0
            videoPlayerViewController.indexMax = 1
            videoPlayerViewController.mode = VideoPlayerMode.SupplementalInMovie
            videoPlayerViewController.view.frame = player.bounds
            player.addSubview(videoPlayerViewController.view)
            self.addChildViewController(videoPlayerViewController)
            videoPlayerViewController.didMoveToParentViewController(self)
            _videoPlayerViewController = videoPlayerViewController
            
        }

        
    
    }
    
    
    // MARK: Actions
    @IBAction func playClip(sender: AnyObject) {
        clipThumbnailImageView.hidden = true
        playButton.hidden = true
        
        replaceClip()
        _videoPlayerViewController!.playVideoWithURL(_clips![_index])
    }
    
    @IBAction func shareClip(sender: AnyObject) {
        if let url = _shareableURL {
            let activityViewController = UIActivityViewController(activityItems: [String.localize("clipshare.share_message", variables: ["movie_name": "Man of Steel", "url": url.absoluteString])], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = sender as? UIView
            self.presentViewController(activityViewController, animated: true, completion: nil)
        }
    }
    @IBAction func prevClip(sender: AnyObject) {
        
        //Move array index by -1. Check for bounds
        if _index <= 0 {
            return
        }
        
        clipThumbnailImageView.hidden = false
        playButton.hidden = false
        _index -= 1
        replaceClip()
        
    }
    
    @IBAction func nextClip(sender: AnyObject) {
        
        //Move array index by +1. Check for bounds
        if _index >= _clips?.count {
            return
        }
        
        clipThumbnailImageView.hidden = false
        playButton.hidden = false
        _index += 1
        replaceClip()
    }
}