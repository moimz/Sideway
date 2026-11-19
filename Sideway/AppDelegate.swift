//
//  AppDelegate.swift
//  Sideway
//

import Cocoa

@main @MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {

    private var window: NSWindow?

    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        withExtendedLifetime(delegate) { app.run() }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        installSidewayMenu()
        _ = Updater.shared

        let window = NSWindow(contentViewController: ViewController())
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.title = "Sideway"
        window.makeKeyAndOrderFront(nil)
        self.window = window
        NSApp.activate()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    @objc func checkForUpdates(_ sender: Any?) {
        Updater.shared.checkForUpdates()
    }

    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(checkForUpdates(_:)) {
            return Updater.shared.canCheck
        }
        return true
    }
}

func installSidewayMenu() {
    let appMenu = NSMenu(title: "Sideway")
    appMenu.addItem(withTitle: "Sideway에 관하여", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
    appMenu.addItem(withTitle: "업데이트 확인…", action: #selector(AppDelegate.checkForUpdates(_:)), keyEquivalent: "")
    appMenu.addItem(.separator())
    appMenu.addItem(withTitle: "Sideway 가리기", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
    appMenu.addItem(.separator())
    appMenu.addItem(withTitle: "Sideway 종료", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")

    let appItem = NSMenuItem()
    appItem.submenu = appMenu

    let mainMenu = NSMenu()
    mainMenu.addItem(appItem)
    NSApp.mainMenu = mainMenu
}
