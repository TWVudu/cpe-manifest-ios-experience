//
//  NextGenDataLoader.swift
//

import Foundation
import GoogleMaps
import NextGenDataManager

@objc class NextGenDataLoader: NSObject, NextGenHookDelegate {
    
    static let ManifestData = [
        "urn:dece:cid:eidr-s:DAFF-8AB8-3AF0-FD3A-29EF-Q": [
            "title": "Man of Steel",
            "image": "MOS-Onesheet",
            "manifest": "Data/Manifests/mos_hls_manifest_r60-v0.5",
            "appdata": "Data/Manifests/mos_appdata_locations_r60-v0.5"
        ],
        "urn:dece:cid:eidr-s:B257-8696-871C-A12B-B8C1-S": [
            "title": "Batman v Superman",
            "image": "BvS-Onesheet",
            "manifest": "Data/Manifests/bvs_manifest_r60-v1.1",
            "appdata": "Data/Manifests/bvs_appdata_locations_r60-v1.1"
        ],
        "1": [
            "title": "Sisters",
            "image": "Sisters-Onesheet",
            "manifest": "Data/Manifests/sisters_hls_manifest_v2-R60-generated-spec1.5"
        ],
        "2": [
            "title": "Sisters (Unrated)",
            "image": "SistersUnrated-Onesheet",
            "manifest": "Data/Manifests/sisters_extended_hls_manifest_v3-generated-spec1.5"
        ],
        "3": [
            "title": "Minions",
            "image": "Minions-Onesheet",
            "manifest": "Data/Manifests/minions_hls_manifest_v6-R60-generated-spec1.5"
        ]
    ]
    
    private struct ConfigKey {
        static let TheTakeAPI = "thetake_api_key"
        static let BaselineAPI = "baseline_api_key"
        static let GoogleMapsAPI = "google_maps_api_key"
    }
    
    
    static let sharedInstance = NextGenDataLoader()
    private var currentCid: String?
    
    override init() {
        super.init()
        
        NextGenHook.delegate = self
    }
    
    func loadConfig() {
        // Load configuration file
        if let configDataPath = NSBundle.mainBundle().pathForResource("Data/config", ofType: "json") {
            do {
                let configData = try NSData(contentsOfURL: NSURL(fileURLWithPath: configDataPath), options: NSDataReadingOptions.DataReadingMappedIfSafe)
                if let configJSON = try NSJSONSerialization.JSONObjectWithData(configData, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
                    if let key = configJSON[ConfigKey.TheTakeAPI] as? String {
                        TheTakeAPIUtil.sharedInstance.apiKey = key
                    }
                    
                    if let key = configJSON[ConfigKey.BaselineAPI] as? String {
                        NGDMConfiguration.talentAPIUtil = BaselineAPIUtil(apiKey: key)
                    }
                    
                    if let key = configJSON[ConfigKey.GoogleMapsAPI] as? String {
                        GMSServices.provideAPIKey(key)
                        NGDMConfiguration.mapService = .GoogleMaps
                    }
                }
            } catch let error as NSError {
                print("Error parsing config data \(error.localizedDescription)")
            }
        } else {
            print("Configuration file not found")
        }
    }
    
    func loadTitle(cid: String) {
        if let titleData = NextGenDataLoader.ManifestData[cid] {
            // Load current Manifest file
            if let manifestXMLPath = NSBundle.mainBundle().pathForResource(titleData["manifest"], ofType: "xml") {
                do {
                    NGDMManifest.createInstance()
                    
                    try NGDMManifest.sharedInstance.loadManifestXMLFile(manifestXMLPath)
                    NGDMManifest.sharedInstance.mainExperience?.appearance = NGDMAppearance(type: .Main)
                    
                    NGDMManifest.sharedInstance.inMovieExperience?.appearance = NGDMAppearance(type: .InMovie)
                    NGDMManifest.sharedInstance.outOfMovieExperience?.appearance = NGDMAppearance(type: .OutOfMovie)
                    
                    if TheTakeAPIUtil.sharedInstance.apiKey != nil, let mediaId = NGDMManifest.sharedInstance.mainExperience?.customIdentifier(Namespaces.TheTake) {
                        TheTakeAPIUtil.sharedInstance.mediaId = mediaId
                        TheTakeAPIUtil.sharedInstance.prefetchProductFrames(start: 0)
                        TheTakeAPIUtil.sharedInstance.prefetchProductCategories()
                    }
                    
                    if var talentAPIUtil = NGDMConfiguration.talentAPIUtil {
                        talentAPIUtil.apiId = NGDMManifest.sharedInstance.mainExperience?.customIdentifier(Namespaces.Baseline)
                    }
                    
                    NGDMManifest.sharedInstance.mainExperience?.loadTalent()
                } catch NGDMError.MainExperienceMissing {
                    print("Error loading Manifest file: no main Experience found")
                    abort()
                } catch NGDMError.InMovieExperienceMissing {
                    print("Error loading Manifest file: no in-movie Experience found")
                    abort()
                } catch NGDMError.OutOfMovieExperienceMissing {
                    print("Error loading Manifest file: no out-of-movie Experience found")
                    abort()
                } catch {
                    print("Error loading Manifest file: unknown error")
                    abort()
                }
            } else {
                print("No Manifest file found")
                abort()
            }
            
            // Load current AppData file
            if let appDataXMLPath = NSBundle.mainBundle().pathForResource(titleData["appdata"], ofType: "xml") {
                do {
                    NGDMManifest.sharedInstance.appData = try NGDMManifest.sharedInstance.loadAppDataXMLFile(appDataXMLPath)
                } catch {
                    print("Error loading AppData file")
                }
            } else {
                print("No AppData file found")
            }
            
            currentCid = cid
        } else {
            print("No title found for \(cid)")
            abort()
        }
    }
    
    // MARK: NextGenHookDelegate
    func nextGenExperienceWillClose() {
        NGDMManifest.destroyInstance()
    }
    
    func videoPlayerWillClose(mode: VideoPlayerMode) {
        // Handle end of playback
    }
    
    func getProcessedVideoURL(url: NSURL, mode: VideoPlayerMode, completion: (url: NSURL?) -> Void) {
        // Handle DRM
        completion(url: url)
    }
    
}