import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  private var cover: UIView?

  // iOS captures the app-switcher snapshot right after this call, so the
  // cover has to be native: Flutter may not draw another frame in time.
  override func sceneWillResignActive(_ scene: UIScene) {
    super.sceneWillResignActive(scene)
    guard PrivacyState.hidePreview, cover == nil, let window = window else { return }
    let view = UIView(frame: window.bounds)
    view.backgroundColor = UIColor(red: 1, green: 0.973, blue: 0.976, alpha: 1)
    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    let logo = UIImageView(image: UIImage(named: "LaunchImage"))
    logo.center = view.center
    logo.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
    view.addSubview(logo)
    window.addSubview(view)
    cover = view
  }

  override func sceneDidBecomeActive(_ scene: UIScene) {
    super.sceneDidBecomeActive(scene)
    cover?.removeFromSuperview()
    cover = nil
  }
}
