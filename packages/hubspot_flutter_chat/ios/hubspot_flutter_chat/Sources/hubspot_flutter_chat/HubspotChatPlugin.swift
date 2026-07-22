import Flutter
import HubspotMobileSDK
import SwiftUI
import UIKit

/// Error surfaced when the chat UI cannot be presented.
enum HubspotChatError: Error {
    case noViewController
}

/// iOS implementation of the hubspot_flutter chat bridge.
///
/// Implements the Pigeon-generated `HubspotChatHostApi` protocol and forwards
/// each call to HubSpot's official iOS mobile chat SDK (`HubspotMobileSDK`). The
/// SDK reads its configuration from the app bundle (`Hubspot-Info.plist` /
/// config file); see the package README.
///
/// Native → Dart chat events are delivered through `HubspotChatFlutterApi`,
/// exposed to Dart as broadcast streams.
public class HubspotChatPlugin: NSObject, FlutterPlugin, HubspotChatHostApi {
    private var flutterApi: HubspotChatFlutterApi?
    private var defaultChatFlow: String?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = HubspotChatPlugin()
        HubspotChatHostApiSetup.setUp(
            binaryMessenger: registrar.messenger(),
            api: instance
        )
        instance.flutterApi = HubspotChatFlutterApi(
            binaryMessenger: registrar.messenger()
        )
    }

    // MARK: - HubspotChatHostApi

    func configure(
        setup: ChatSetupData,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        defaultChatFlow = setup.defaultChatFlow
        do {
            // Loads the bundled HubSpot configuration (portalId, hublet, ...).
            try HubspotManager.configure()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }

    func openChat(
        chatFlow: String?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let flow = chatFlow ?? defaultChatFlow
        DispatchQueue.main.async {
            guard let top = Self.topViewController() else {
                completion(.failure(HubspotChatError.noViewController))
                return
            }
            let chatView = HubspotChatView(
                manager: HubspotManager.shared,
                chatFlow: flow
            )
            let host = UIHostingController(rootView: chatView)
            host.modalPresentationStyle = .fullScreen
            top.present(host, animated: true) {
                self.flutterApi?.onChatOpened { _ in }
            }
            completion(.success(()))
        }
    }

    func closeChat(completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.main.async {
            let top = Self.topViewController()
            if top?.presentingViewController != nil {
                top?.dismiss(animated: true) {
                    self.flutterApi?.onChatClosed { _ in }
                }
            }
            completion(.success(()))
        }
    }

    func setUserIdentity(
        identity: VisitorIdentity,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        HubspotManager.shared.setUserIdentity(
            identityToken: identity.identityToken,
            email: identity.email
        )
        completion(.success(()))
    }

    func setChatProperties(
        properties: [String: String],
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        HubspotManager.shared.setChatProperties(data: properties)
        completion(.success(()))
    }

    func setPushToken(
        token: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        // Dart passes the APNs device token hex-encoded; the SDK wants raw Data.
        HubspotManager.shared.setPushToken(apnsPushToken: Self.dataFromHex(token))
        completion(.success(()))
    }

    func handlePushNotification(
        data: [String: String],
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        // NEEDS ON-DEVICE / macOS VERIFICATION — cannot be compiled on Linux.
        //
        // Unlike Android (which authoritatively gates on
        // `HubspotManager.isHubspotNotification`), the iOS SDK 1.0.x exposes no
        // synchronous "is this push ours" check. We therefore return the
        // CONSERVATIVE value `false` and do NOT emit onNewMessage: returning
        // `true` unconditionally would make an app that suppresses its own
        // notification handling on a `true` result swallow *every* non-HubSpot
        // push. Handle HubSpot chat pushes on iOS via HubSpot's AppDelegate
        // integration instead. Wire this up (returning `true` only for genuine
        // HubSpot payloads) once the iOS SDK exposes a detection API.
        completion(.success(false))
    }

    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        HubspotManager.shared.clearUserData()
        completion(.success(()))
    }

    // MARK: - Helpers

    private static func dataFromHex(_ hex: String) -> Data {
        var data = Data(capacity: hex.count / 2)
        var index = hex.startIndex
        while index < hex.endIndex {
            let next = hex.index(index, offsetBy: 2, limitedBy: hex.endIndex)
                ?? hex.endIndex
            if let byte = UInt8(hex[index..<next], radix: 16) {
                data.append(byte)
            }
            index = next
        }
        return data
    }

    @MainActor
    private static func topViewController(
        _ base: UIViewController? = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController
    ) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return topViewController(tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}
