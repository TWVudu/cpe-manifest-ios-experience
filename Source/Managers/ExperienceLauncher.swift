//
//  ExperienceLauncher.swift
//

import UIKit
import CPEData
import Reachability

open  class ExperienceLauncher {

    public static var delegate: ExperienceDelegate?
    private static var reachability = Reachability()!
    private static var reachabilityChangedObserver: NSObjectProtocol?
    static var isBeingDismissed = false

    open static func launch(fromViewController viewController: UIViewController) {
        delegate?.experienceWillOpen()

        let homeViewController = UIStoryboard.viewController(for: HomeViewController.self) as? HomeViewController
        viewController.present(homeViewController!, animated: true, completion: nil)

        reachabilityChangedObserver = NotificationCenter.default.addObserver(forName: ReachabilityChangedNotification, object: reachability, queue: OperationQueue.main) { (notification) in
            if let reachability = notification.object as? Reachability {
                if reachability.isReachable {
                    if reachability.isReachableViaWiFi {
                        ExperienceLauncher.delegate?.connectionStatusChanged(status: .onWiFi)
                    } else {
                        ExperienceLauncher.delegate?.connectionStatusChanged(status: .onCellular)
                    }
                } else {
                    ExperienceLauncher.delegate?.connectionStatusChanged(status: .off)
                }
            }
        }

        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start reachability notifier: \(error)")
        }
    }

    open static func close() {
        isBeingDismissed = true

        if let observer = reachabilityChangedObserver {
            NotificationCenter.default.removeObserver(observer)
            reachabilityChangedObserver = nil
        }

        delegate?.experienceWillClose()
        CacheManager.clearTempDirectory()
        CPEDataUtils.reset()
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true) {
            ExperienceLauncher.isBeingDismissed = false
            CPEXMLSuite.current = nil
        }
    }

}
