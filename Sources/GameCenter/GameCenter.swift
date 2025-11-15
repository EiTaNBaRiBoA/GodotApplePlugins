//
//  GameCenter.swift
//  SwiftGodotAppleTemplate
//
//  Created by Miguel de Icaza on 11/15/25.
//

import SwiftGodotRuntime
import SwiftUI
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

import GameKit

@Godot
class ApplePlayer: RefCounted, @unchecked Sendable {
    var player: GKPlayer
    required init(_ context: InitContext) {
        fatalError("ApplePlayer should only be constructed via GameCenterManager")
    }

    @Export var gamePlayerID: String { player.gamePlayerID }
    @Export var teamPlayerID: String { player.teamPlayerID }
    @Export var alias: String { player.alias }
    @Export var displayName: String { player.displayName }
    @Export var isInvitable: Bool { player.isInvitable }

    @Callable
    func scopedIDsArePersistent() -> Bool {
        player.scopedIDsArePersistent()
    }

    @Callable
    func load_photo(_ small: Bool, _ callback: Callable) {
        GD.print("request to load photo")
        player.loadPhoto(for: small ? .small : .normal) { img, error in
            GD.print("Result from loadPhoto: \(String(describing: img)) \(String(describing: error))")
            if let img, let png = img.pngData() {
                let array = PackedByteArray([UInt8](png))
                DispatchQueue.main.async {
                    callback.call(Variant(array))
                }
            }
        }
    }

    init(player: GKPlayer) {
        self.player = player
        guard let ctxt = InitContext.createObject(className: ApplePlayer.godotClassName) else {
            fatalError("Could not create object")
        }
        super.init(ctxt)
    }
}

@Godot
class AppleLocalPlayer: ApplePlayer, @unchecked Sendable {
    required init(_ context: InitContext) {
        super.init(context)
        player = GKLocalPlayer.local
    }

    init() {
        super.init(player: GKLocalPlayer.local)
    }

    @Export var isAuthenticated: Bool { GKLocalPlayer.local.isAuthenticated }
    @Export var isUnderage: Bool { GKLocalPlayer.local.isUnderage }
    @Export var isMultiplayerGamingRestricted: Bool { GKLocalPlayer.local.isMultiplayerGamingRestricted }
    @Export var isPersonalizedCommunicationRestricted: Bool { GKLocalPlayer.local.isPersonalizedCommunicationRestricted }
}

@Godot
class GameCenterManager: RefCounted, @unchecked Sendable {
    @Signal var authentication_error: SignalWithArguments<String>
    @Signal var authentication_result: SignalWithArguments<Bool>

    var isAuthenticated: Bool = false
    
    @Export var localPlayer: AppleLocalPlayer

    required init(_ context: InitContext) {
        localPlayer = AppleLocalPlayer()
        super.init(context)
    }

    @Callable
    func authenticate() {
        let localPlayer = GKLocalPlayer.local
        var x = AppleLocalPlayer()
        localPlayer.authenticateHandler = { viewController, error in
            GD.print("AppleLocalPlayer: authentication callback")
            MainActor.assumeIsolated {
                if let vc = viewController {
                    GD.print("Presenting VC")
                    presentOnTop(vc)
                    return
                }

                if let error = error {
                    GD.print("God an error: \(error)")
                    self.authentication_error.emit(String(describing: error))
                }
                GD.print("Raising events")
                self.isAuthenticated = GKLocalPlayer.local.isAuthenticated
                self.authentication_result.emit(self.isAuthenticated)
            }
        }

    }
}

#initSwiftExtension(cdecl: "godot_game_center_init", types: [
    GameCenterManager.self,
    AppleLocalPlayer.self,
    ApplePlayer.self
])
