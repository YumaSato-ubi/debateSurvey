//
//  selectionController.swift
//  ActivityLabeling
//
//  Created by 佐藤佑磨 on 2021/02/03.
//  Copyright © 2021 Yuma Sato. All rights reserved.
//

import UIKit
import APIKit
import AVKit
import AVFoundation
import EMTNeumorphicView
import MobileCoreServices
import Photos

private let reuseIdentifier = "CollectionViewCell"

class SelectionControler: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!    
    let imageView = UIImageView()
    let movieView = VideoUtil()
    let imagePickerController = UIImagePickerController()
    var videoURL: URL?
    
    let defaults = UserDefaults.standard
    
    let api = APIManager.shared
    var user = ""
    var emotion = 0
    var playFlg = false
    var movieFlg = false
    
    let numbers: [Int] = [4, 3, 2, 1, 0, -1, -2, -3, -4]
    
    static var shareCellSize: CGFloat = 0
    var num = "0"
    
    var index = 0
    
    var lastCell = -1
    
    var movieStartTime = Date()
    
//    ボタンやラベル等の定義
    let selectMovieButton = EMTNeumorphicButton(type: .custom)
    let playMovieButton = EMTNeumorphicButton(type: .custom)
    let stopMovieButton = EMTNeumorphicButton(type: .custom)
//    let playButton = EMTNeumorphicButton(type: .custom)
    let user1Button = EMTNeumorphicButton(type: .custom)
    let user2Button = EMTNeumorphicButton(type: .custom)
    let user3Button = EMTNeumorphicButton(type: .custom)
    let user4Button = EMTNeumorphicButton(type: .custom)
    let debateLabel = UILabel()
    
    
    
    override func viewDidLoad() {
        //PhotoLibrary使用の権限確認と依頼
        if PHPhotoLibrary.authorizationStatus() != .authorized {
            PHPhotoLibrary.requestAuthorization {status in
                if status != .authorized {
                    print("not authorized")
                    //...ユーザにPhotoLibraryへのアクセス承認を促すメッセージの表示等を行う
                }
            }
        }
        super.viewDidLoad()
        view.backgroundColor = UIColor(RGB: 0xE9F1F9)
        let screenWidth:CGFloat = self.view.frame.width
        let screenHeight:CGFloat = self.view.frame.height
        SelectionControler.shareCellSize = screenWidth/6
        let collectionY = screenHeight/2
        let userY = screenHeight/6 + screenHeight/5 + screenHeight/12 + screenHeight/2
        collectionView.frame = CGRect(x: screenWidth/12, y: collectionY+screenHeight/30 , width: screenWidth*5/6, height: screenHeight*2/5)
        collectionView.backgroundColor = UIColor(RGB: 0xE9F1F9)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.view.addSubview(debateLabel)
        debateLabel.text = "Select Movie"
        debateLabel.textAlignment = .center
//        guard let font = UIFont(name: "sean henrich atf bold", size: 50)else { return}
        debateLabel.font = UIFont(name: "SeanHenrichATF-Bold", size: 80)
        debateLabel.frame = CGRect(x: screenWidth/10, y: screenHeight/4-screenHeight/16, width: screenWidth*4/5, height: screenHeight/8)
        debateLabel.textColor = UIColor(RGB: 0x2D8CFF)
        
//        self.view.addSubview(playButton)
//        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
//        playButton.setTitleColor(.black, for: .normal)
//        playButton.setImage(UIImage(systemName: "pause.fill"), for: .selected)
//        playButton.setTitleColor(.black, for: .selected)
////        ボタンの色
//        playButton.tintColor = UIColor(RGB: 0x223377)
//        playButton.neumorphicLayer?.elementBackgroundColor = view.backgroundColor?.cgColor ?? UIColor.black.cgColor
////        ボタンの形
//        playButton.layer.cornerRadius = 25
//        playButton.layer.borderWidth = 1
//        playButton.layer.borderColor = CGColor(red: 255, green: 255, blue: 255, alpha: 0.2)
//        playButton.frame = CGRect(x:screenWidth/8, y:screenHeight/9, width:screenWidth*3/4, height:screenHeight/5)
////        画像の位置
//        playButton.imageView?.contentMode = .scaleAspectFit
//        playButton.contentVerticalAlignment = .fill
//        playButton.contentHorizontalAlignment = .fill
//        playButton.imageEdgeInsets = UIEdgeInsets(top: 30, left: screenWidth/4, bottom: 30, right:screenWidth/4)
////        playButton.translatesAutoresizingMaskIntoConstraints = false
////        ボタンに関数を適用
//        playButton.addTarget(self, action: #selector(play(_:)), for: .touchUpInside)
////        ボタンの影
//        playButton.neumorphicLayer?.lightShadowOpacity = 0.3
//        playButton.neumorphicLayer?.darkShadowOpacity = 0.8
//        playButton.neumorphicLayer?.elementDepth = 15
//        playButton.neumorphicLayer?.edged = true
        
//        動画選択ボタン
        self.view.addSubview(selectMovieButton)
        selectMovieButton.layer.cornerRadius = 5
        let selectMovieButtonWidth = screenWidth/4-screenWidth/80
        let selectMovieButtonHeight = screenHeight-userY-screenHeight/100
        selectMovieButton.frame = CGRect(x:screenWidth/3-selectMovieButtonWidth/2, y:collectionY-selectMovieButtonHeight, width:screenWidth/4-screenWidth/80, height:screenHeight-userY-screenHeight/100)
        selectMovieButton.contentVerticalAlignment = .fill
        selectMovieButton.contentHorizontalAlignment = .fill
        selectMovieButton.setTitle("select", for: .normal)
        selectMovieButton.setTitleColor(.lightGray, for: .normal)
        selectMovieButton.setTitle("select", for: .selected)
        selectMovieButton.setTitleColor(.black, for: .selected)
        selectMovieButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        selectMovieButton.titleLabel?.textAlignment = .center
        selectMovieButton.addTarget(self, action: #selector(selectMovie(_:)), for: .touchUpInside)
        selectMovieButton.neumorphicLayer?.lightShadowOpacity = 0.3
        selectMovieButton.neumorphicLayer?.darkShadowOpacity = 0.8
        selectMovieButton.neumorphicLayer?.elementDepth = 3
        selectMovieButton.neumorphicLayer?.edged = true
        selectMovieButton.neumorphicLayer?.elementColor = CGColor(red: 233/255, green: 241/255, blue: 249/255, alpha: 1)
        
//        動画再生ボタン
        self.view.addSubview(playMovieButton)
        playMovieButton.layer.cornerRadius = 5
        playMovieButton.frame = CGRect(x:screenWidth*2/3-selectMovieButtonWidth/2, y:collectionY-selectMovieButtonHeight, width:screenWidth/4-screenWidth/80, height:screenHeight-userY-screenHeight/100)
        playMovieButton.contentVerticalAlignment = .fill
        playMovieButton.contentHorizontalAlignment = .fill
        playMovieButton.setTitle("PLAY", for: .normal)
        playMovieButton.setTitleColor(.lightGray, for: .normal)
        playMovieButton.setTitle("STOP", for: .selected)
        playMovieButton.setTitleColor(.black, for: .selected)
        playMovieButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        playMovieButton.titleLabel?.textAlignment = .center
        playMovieButton.addTarget(self, action: #selector(playMovie(_:)), for: .touchUpInside)
        playMovieButton.neumorphicLayer?.lightShadowOpacity = 0.3
        playMovieButton.neumorphicLayer?.darkShadowOpacity = 0.8
        playMovieButton.neumorphicLayer?.elementDepth = 3
        playMovieButton.neumorphicLayer?.edged = true
        playMovieButton.neumorphicLayer?.elementColor = CGColor(red: 233/255, green: 241/255, blue: 249/255, alpha: 1)
        
////        動画 停止ボタン
//        self.view.addSubview(stopMovieButton)
//        stopMovieButton.layer.cornerRadius = 0
//        stopMovieButton.frame = CGRect(x:screenWidth*2/3-selectMovieButtonWidth/2, y:collectionY-selectMovieButtonHeight, width:screenWidth/4-screenWidth/80, height:screenHeight-userY-screenHeight/100)
//        stopMovieButton.contentVerticalAlignment = .fill
//        stopMovieButton.contentHorizontalAlignment = .fill
//        stopMovieButton.setTitle("stop", for: .normal)
//        stopMovieButton.setTitleColor(.lightGray, for: .normal)
//        stopMovieButton.setTitle("stop", for: .selected)
//        stopMovieButton.setTitleColor(.black, for: .selected)
//        stopMovieButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
//        stopMovieButton.titleLabel?.textAlignment = .center
//        stopMovieButton.addTarget(self, action: #selector(stopMovie(_:)), for: .touchUpInside)
//        stopMovieButton.neumorphicLayer?.lightShadowOpacity = 0.3
//        stopMovieButton.neumorphicLayer?.darkShadowOpacity = 0.8
//        stopMovieButton.neumorphicLayer?.elementDepth = 10
//        stopMovieButton.neumorphicLayer?.edged = true
//        stopMovieButton.neumorphicLayer?.elementColor = CGColor(red: 233/255, green: 241/255, blue: 249/255, alpha: 1)
//        stopMovieButton.isHidden = true
        
//        動画画面
        movieView.frame = CGRect(x:0, y:0, width:screenWidth, height:screenHeight/2-selectMovieButtonHeight)
        
        
//        セルの登録（storyboard上でcollectionViewを実装するときはいらないが、コードでやるときは必須）
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
//         レイアウト設定
         let layout = UICollectionViewFlowLayout()
         layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
         collectionView.collectionViewLayout = layout
        
        self.view.addSubview(user1Button)
        user1Button.layer.cornerRadius = 10
        user1Button.frame = CGRect(x:screenWidth/150, y:userY-screenHeight/100, width:screenWidth/4-screenWidth/80, height:screenHeight-userY-screenHeight/100)
        user1Button.contentVerticalAlignment = .fill
        user1Button.contentHorizontalAlignment = .fill
//        user1Button.imageEdgeInsets = UIEdgeInsets(top: 30, left: screenWidth/4, bottom: 30, right:screenWidth/4)
        user1Button.setTitle("user1", for: .normal)
        user1Button.setTitleColor(.lightGray, for: .normal)
        user1Button.setTitle("user1", for: .selected)
        user1Button.setTitleColor(.black, for: .selected)
        user1Button.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        user1Button.titleLabel?.textAlignment = .center
        user1Button.addTarget(self, action: #selector(userSelect(_:)), for: .touchUpInside)
        user1Button.neumorphicLayer?.lightShadowOpacity = 0.3
        user1Button.neumorphicLayer?.darkShadowOpacity = 0.8
        user1Button.neumorphicLayer?.elementDepth = 5
        user1Button.neumorphicLayer?.edged = true
        user1Button.neumorphicLayer?.elementColor = CGColor(red: 233/255, green: 241/255, blue: 249/255, alpha: 1)
        
        self.view.addSubview(user2Button)
        user2Button.layer.cornerRadius = 10
        user2Button.frame = CGRect(x:screenWidth/4+screenWidth/150, y:userY-screenHeight/100, width:screenWidth/4-screenWidth/80, height:screenHeight-userY-screenHeight/100)
        user2Button.contentVerticalAlignment = .fill
        user2Button.contentHorizontalAlignment = .fill
//        user1Button.imageEdgeInsets = UIEdgeInsets(top: 30, left: screenWidth/4, bottom: 30, right:screenWidth/4)
        user2Button.setTitle("user2", for: .normal)
        user2Button.setTitleColor(.lightGray, for: .normal)
        user2Button.setTitle("user2", for: .selected)
        user2Button.setTitleColor(.black, for: .selected)
        user2Button.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        user2Button.titleLabel?.textAlignment = .center
        user2Button.addTarget(self, action: #selector(userSelect(_:)), for: .touchUpInside)
        user2Button.neumorphicLayer?.lightShadowOpacity = 0.3
        user2Button.neumorphicLayer?.darkShadowOpacity = 0.8
        user2Button.neumorphicLayer?.elementDepth = 5
        user2Button.neumorphicLayer?.edged = true
        user2Button.neumorphicLayer?.elementColor = CGColor(red: 233/255, green: 241/255, blue: 249/255, alpha: 1)
        
        self.view.addSubview(user3Button)
        user3Button.layer.cornerRadius = 10
        user3Button.frame = CGRect(x:screenWidth/2+screenWidth/150, y:userY-screenHeight/100, width:screenWidth/4-screenWidth/80, height:screenHeight-userY-screenHeight/100)
        user3Button.contentVerticalAlignment = .fill
        user3Button.contentHorizontalAlignment = .fill
//        user1Button.imageEdgeInsets = UIEdgeInsets(top: 30, left: screenWidth/4, bottom: 30, right:screenWidth/4)
        user3Button.setTitle("user3", for: .normal)
        user3Button.setTitleColor(.lightGray, for: .normal)
        user3Button.setTitle("user3", for: .selected)
        user3Button.setTitleColor(.black, for: .selected)
        user3Button.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        user3Button.titleLabel?.textAlignment = .center
        user3Button.addTarget(self, action: #selector(userSelect(_:)), for: .touchUpInside)
        user3Button.neumorphicLayer?.lightShadowOpacity = 0.3
        user3Button.neumorphicLayer?.darkShadowOpacity = 0.8
        user3Button.neumorphicLayer?.elementDepth = 5
        user3Button.neumorphicLayer?.edged = true
        user3Button.neumorphicLayer?.elementColor = CGColor(red: 233/255, green: 241/255, blue: 249/255, alpha: 1)
        
        self.view.addSubview(user4Button)
        user4Button.layer.cornerRadius = 10
        user4Button.frame = CGRect(x:screenWidth*3/4+screenWidth/150, y:userY-screenHeight/100, width:screenWidth/4-screenWidth/80, height:screenHeight-userY-screenHeight/100)
        user4Button.contentVerticalAlignment = .fill
        user4Button.contentHorizontalAlignment = .fill
//        user1Button.imageEdgeInsets = UIEdgeInsets(top: 30, left: screenWidth/4, bottom: 30, right:screenWidth/4)
        user4Button.setTitle("user4", for: .normal)
        user4Button.setTitleColor(.lightGray, for: .normal)
        user4Button.setTitle("user4", for: .selected)
        user4Button.setTitleColor(.black, for: .selected)
        user4Button.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        user4Button.titleLabel?.textAlignment = .center
        user4Button.addTarget(self, action: #selector(userSelect(_:)), for: .touchUpInside)
        user4Button.neumorphicLayer?.lightShadowOpacity = 0.3
        user4Button.neumorphicLayer?.darkShadowOpacity = 0.8
        user4Button.neumorphicLayer?.elementDepth = 5
        user4Button.neumorphicLayer?.edged = true
        user4Button.neumorphicLayer?.elementColor = CGColor(red: 233/255, green: 241/255, blue: 249/255, alpha: 1)
        
        imageView.frame = CGRect(x:0, y:0, width:screenWidth, height:screenHeight/2-selectMovieButtonHeight)
        self.view.addSubview(imageView)
        self.view.addSubview(movieView)
        movieView.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func selectMovie(_ button: EMTNeumorphicButton) {
        guard !playMovieButton.isSelected else {
            let alert = UIAlertController(title: "Now playing", message: "If you select the other movie, please stop this movie.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        imageView.isHidden = false
        movieView.isHidden = true
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.delegate = self
            imagePickerController.mediaTypes = [kUTTypeMovie as String]
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //PHAssetが取れないときは(deprecatedでも取れるときは取れるので).referenceURLを試す
        guard let refURL = info[.referenceURL] as? URL else { //ここで警告が出るが無視
            print(".referenceURL is nil")
            return
        }
        self.videoURL = refURL
        print("URL=\(refURL)") //<-危険な強制アンラップは可能な限り避ける
        guard let image =  previewImageFromVideo(refURL) else {
            print("previewImageFromVideo(\(refURL)) is nil")
            return
        }
        debateLabel.isHidden = true
        movieFlg = true
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imagePickerController.dismiss(animated: true, completion: nil)
    }
    
    //ビデオのURLからサムネイル画像を作成
    func previewImageFromVideo(_ url:URL) -> UIImage? {
        print("動画からサムネイルを生成(URL)")
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        var time = asset.duration
        time.value = min(time.value, 2)
        do {
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch {
            print(error) //エラーを黙って捨ててしまってはいけない
            return nil
        }
    }
    
//    //ビデオのPHAssetからサムネイル画像を作成
//    func previewImage(fromVideo videoAsset: PHAsset, completion: @escaping (UIImage?)->Void) {
//        print("動画からサムネイルを生成(PHAsset)")
//        print("previewImageFromVideo(\(videoURL))")
//        let manager = PHImageManager.default()
//        manager.requestAVAsset(forVideo: videoAsset, options: nil) {asset, audioMix, info in
//            guard let asset = asset else {
//                print("asset is nil")
//                return
//            }
//            let imageGenerator = AVAssetImageGenerator(asset: asset)
//            imageGenerator.appliesPreferredTrackTransform = true
//            var time = asset.duration
//            time.value = min(time.value, 2)
//            do {
//                let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
//                completion(UIImage(cgImage: imageRef))
//            } catch {
//                print(error) //エラーを黙って捨ててしまってはいけない
//                completion(nil)
//            }
//        }
//    }

    
    @objc func playMovie(_ button:EMTNeumorphicButton) {
        guard movieFlg else {
            let alert = UIAlertController(title: "No movie", message: "Please select a movie.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        guard user != "" else {
            let alert = UIAlertController(title: "No user", message: "Please choose a user.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        playFlg.toggle()
        movieView.isHidden = false
        imageView.isHidden = true
        button.isSelected = !button.isSelected
        
        let item = AVPlayerItem(url: videoURL!)
        let player = AVPlayer(playerItem: item)
        movieView.player = player
        
        let now = Date()
        movieStartTime = now
        print(now)
        
        if button.isSelected == true{
            player.play()
            debateLabel.isHidden = true
            self.api.write(time: now, users: user, emotion: 10.0, handler: { error in
                guard (error == nil) else {
                    let alert = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
            })
            self.api.writeTime(time: now, users: user, movieTime: 0.0, handler: { error in
                guard (error == nil) else {
                    let alert = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
            })
        } else {
            player.pause()

        }
        if !playFlg {
            let indexPath: IndexPath = [0, lastCell]
            guard ((collectionView.cellForItem(at: indexPath)) != nil) else {
                return
            }
            let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
            cell.eButton.isSelected = false
            lastCell = -1
        }
    }
    
//    @objc func stopMovie(_ button:EMTNeumorphicButton) {
//        imageView.isHidden = false
//        movieView.isHidden = true
//
//        let item = AVPlayerItem(url: videoURL!)
//        let player = AVPlayer(playerItem: item)
//        movieView.player = player
//
//        player.rate = 0
//    }
    
    @objc func play(_ button: EMTNeumorphicButton) {
        guard user != "" else {
            let alert = UIAlertController(title: "No user", message: "Please choose a user.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        if playFlg {
            let indexPath: IndexPath = [0, lastCell]
            guard ((collectionView.cellForItem(at: indexPath)) != nil) else {
                return
            }
            let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
            cell.eButton.isSelected = false
            lastCell = -1
        }
        playFlg.toggle()
        button.isSelected = !button.isSelected
        let now = Date()
        print(now)
    }
    

    
    @objc func userSelect(_ button: EMTNeumorphicButton) {
        guard !playFlg else {
            let alert = UIAlertController(title: "Now playing", message: "If you select the other user, please stop this movie.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        switch button {
        case user1Button:
            user = "user1"
            button.isSelected = !button.isSelected
            user2Button.isSelected = false
            user3Button.isSelected = false
            user4Button.isSelected = false
        case user2Button:
            user = "user2"
            button.isSelected = !button.isSelected
            user1Button.isSelected = false
            user3Button.isSelected = false
            user4Button.isSelected = false
        case user3Button:
            user = "user3"
            button.isSelected = !button.isSelected
            user1Button.isSelected = false
            user2Button.isSelected = false
            user4Button.isSelected = false
        case user4Button:
            user = "user4"
            button.isSelected = !button.isSelected
            user1Button.isSelected = false
            user2Button.isSelected = false
            user3Button.isSelected = false
        default:
            user = "Error"
        }
        if button.isSelected == false {user = ""}
    }
    
    
//    各セルのサイズを決める（これがないせいでセルが表示されなくて3,4時間くらい詰んでた）
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth:CGFloat = self.view.frame.width
        let screenHeight:CGFloat = self.view.frame.height
        let cellHeight:CGFloat = screenWidth/6
        let cellWidth:CGFloat = screenWidth/5
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
//    いくつのセルを返すか
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
//    セルに情報を入れる
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        Identifierが"CollectionViewCell"でCollectionViewCellというクラスのcellを取得
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        
        let num = numbers[indexPath.item]
//        cell.setupContents(num: cellText)
        cell.eButton.tag = numbers[indexPath.item]
        
        cell.eButton.titleLabel?.font = UIFont(name: "SeanHenrichATF-Bold", size: 60)
        cell.eButton.titleLabel?.textAlignment = .center
        cell.eButton.titleEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        cell.eButton.layer.cornerRadius = 30.0
        cell.eButton.center = cell.contentView.center
        cell.eButton.layer.borderWidth = 1
        cell.eButton.layer.borderColor = CGColor(red: 255, green: 255, blue: 255, alpha: 0.2)
        if cell.eButton.tag < 0 {
           cell.eButton.setTitle(String(num), for: .normal)
           cell.eButton.setTitleColor(UIColor(RGB: 0xFADBDA), for: .normal)
           cell.eButton.setTitle(String(num), for: .selected)
           cell.eButton.setTitleColor(UIColor(RGB: 0xFA3932), for: .selected)
        } else if cell.eButton.tag > 0 {
           cell.eButton.setTitle(String(num), for: .normal)
           cell.eButton.setTitleColor(UIColor(RGB: 0xC2EEF1), for: .normal)
           cell.eButton.setTitle(String(num), for: .selected)
           cell.eButton.setTitleColor(UIColor(RGB: 0x005FFF), for: .selected)
        } else {
            cell.eButton.setTitle(String(num), for: .normal)
            cell.eButton.setTitleColor(.lightGray, for: .normal)
            cell.eButton.setTitle(String(num), for: .selected)
            cell.eButton.setTitleColor(.black, for: .selected)
        }
        
        cell.eButton.addTarget(self, action: #selector(printNum(_:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc func printNum(_ button: EMTNeumorphicButton) {
        guard playFlg else {
            let alert = UIAlertController(title: "Not started", message: "Please start the meeting.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
//            self.view.bringSubview(toFront: playButton)
            return
        }
        
        if lastCell != -1 {
            let indexPath: IndexPath = [0, lastCell]
            let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
            cell.eButton.isSelected = !cell.eButton.isSelected
        }
        button.isSelected = !button.isSelected
        lastCell = numbers.index(of: button.tag)!
        emotion = button.tag
        print(emotion)
        print(user)
        
        let time = Date()
        let timeInterval = Date().timeIntervalSince(movieStartTime)
        let timeDouble = Double(timeInterval)
        print(timeDouble)
        self.api.write(time: time, users: user, emotion: Double(emotion), handler: { error in
            guard (error == nil) else {
                let alert = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
        })
        self.api.writeTime(time: time, users: user, movieTime: timeDouble, handler: { error in
            guard (error == nil) else {
                let alert = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
        })
    }
    
    
//    func createLayout() -> UICollectionViewLayout {
//        let width:CGFloat = self.view.frame.width
//        let height:CGFloat = self.view.frame.height
//    
//    }
    
    /// DBサーバへの接続テストを行う
    func connectionTest() {
        self.api.test(handler: {error in
            guard (error == nil) else {
                let alert = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
            
            let alert = UIAlertController(title: "Success",
                                          message: "Connection successed.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        })
    }
}
