//
//  ViewController.swift
//  Sideway
//

import Cocoa
import SafariServices
import SwiftUI

let extensionBundleIdentifier = "com.moimz.Sideway.Extension"

private let accent = Color(.sRGB, red: 0.13, green: 0.61, blue: 0.49)

final class ExtensionStatus: ObservableObject {
    @Published var enabled: Bool?
    @Published var loading = true
    @Published var settingsError: String?
    @Published var showLicense = false

    func refresh() {
        SFSafariExtensionManager.getStateOfSafariExtension(withIdentifier: extensionBundleIdentifier) { state, _ in
            DispatchQueue.main.async {
                self.enabled = state?.isEnabled
                self.loading = false
            }
        }
    }

    func openSettings() {
        settingsError = nil
        SFSafariApplication.showPreferencesForExtension(withIdentifier: extensionBundleIdentifier) { error in
            DispatchQueue.main.async {
                if error != nil {
                    self.settingsError = "Safari → 설정 → 확장 프로그램에서 Sideway를 찾아 주세요."
                }
            }
        }
    }
}

final class ViewController: NSViewController {

    private let status = ExtensionStatus()
    private var quitMonitor: Any?

    override func loadView() {
        view = NSHostingView(rootView: SidewayView(status: status))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        installSidewayMenu()

        quitMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            if modifiers == .command, event.charactersIgnoringModifiers?.lowercased() == "q" {
                NSApp.terminate(nil)
                return nil
            }
            return event
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.title = "Sideway"
        view.window?.setContentSize(NSSize(width: 540, height: 640))
        view.window?.center()
    }

    deinit {
        if let quitMonitor {
            NSEvent.removeMonitor(quitMonitor)
        }
    }
}

struct SidewayView: View {
    @ObservedObject var status: ExtensionStatus
    private let updater = Updater.shared

    /// "2.0 (2)" — 버전 (빌드 번호)
    private var appVersion: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? ""
        let build = info?["CFBundleVersion"] as? String ?? ""
        return "\(version) (\(build))"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 18) {
                    if let url = Bundle.main.url(forResource: "Icon", withExtension: "png"),
                       let icon = NSImage(contentsOf: url) {
                        Image(nsImage: icon)
                            .resizable()
                            .frame(width: 84, height: 84)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("A LITTLE SHORTCUT FOR SAFARI")
                            .font(.system(size: 9, weight: .semibold))
                            .tracking(1.25)
                            .foregroundStyle(.secondary)
                        (Text("Sideway") + Text(".").foregroundColor(accent))
                            .font(.system(size: 42, weight: .bold))
                            .tracking(-1.7)
                    }
                    Spacer()
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("웹 탐색을, 손끝으로.")
                        .font(.system(size: 23, weight: .semibold))
                    Text("마우스 측면 버튼으로 이전 페이지와 다음 페이지를 오가세요.")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 24)
                .padding(.bottom, 22)

                HStack(spacing: 12) {
                    Circle()
                        .fill(dotColor)
                        .frame(width: 9, height: 9)
                        .padding(5)
                    VStack(alignment: .leading, spacing: 5) {
                        Text(title)
                            .font(.system(size: 13, weight: .semibold))
                        Text(detail)
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(cardBackground)

                HStack(spacing: 12) {
                    navigationCard(symbol: "arrow.left", label: "뒤로 버튼", title: "이전 페이지", subtitle: "방금 보던 페이지로")
                    navigationCard(symbol: "arrow.right", label: "앞으로 버튼", title: "다음 페이지", subtitle: "다시 이어서 탐색")
                }
                .padding(.top, 16)

                Text("사용할 웹사이트에서 확장 접근을 허용해 주세요.\n이 창을 닫아도 Safari의 버튼 동작은 계속됩니다.")
                    .font(.system(size: 11))
                    .lineSpacing(5)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 18)

                Button {
                    status.openSettings()
                } label: {
                    HStack {
                        Text("Safari 확장 설정 열기")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 15)
                    .contentShape(Rectangle())
                    .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(accent))
                }
                .buttonStyle(.plain)

                if let error = status.settingsError {
                    Text(error)
                        .font(.system(size: 11))
                        .foregroundStyle(Color(.sRGB, red: 0.68, green: 0.29, blue: 0.22))
                        .padding(.top, 10)
                }

                HStack {
                    Text(verbatim: "Sideway \(appVersion) · 방문 기록 수집 없음")
                    Spacer()
                    Button("앱 종료  ⌘Q") {
                        NSApp.terminate(nil)
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut("q", modifiers: .command)
                }
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
                .padding(.top, 18)

                HStack {
                    Toggle("자동으로 업데이트 확인", isOn: Binding(
                        get: { updater.automaticallyChecks },
                        set: { updater.automaticallyChecks = $0 }
                    ))
                    .toggleStyle(.checkbox)
                    Spacer()
                    Button("업데이트 확인…") {
                        updater.checkForUpdates()
                    }
                    .buttonStyle(.plain)
                    .disabled(!updater.canCheck)
                }
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
                .padding(.top, 10)

                Button("아이콘 출처 및 라이선스") {
                    status.showLicense = true
                }
                .buttonStyle(.plain)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
                .padding(.top, 14)
            }
            .padding(32)
        }
        .frame(minWidth: 460, minHeight: 520)
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear { status.refresh() }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            status.refresh()
        }
        .sheet(isPresented: $status.showLicense) {
            VStack(alignment: .leading, spacing: 16) {
                Text("아이콘 출처 및 라이선스")
                    .font(.headline)
                ScrollView {
                    Text(lucideLicense)
                        .font(.system(size: 11, design: .monospaced))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                HStack {
                    Spacer()
                    Button("닫기") {
                        status.showLicense = false
                    }
                    .keyboardShortcut(.defaultAction)
                }
            }
            .padding(24)
            .frame(width: 460, height: 380)
        }
    }

    private var title: String {
        if status.loading { return "확장 상태 확인 중" }
        switch status.enabled {
        case true?: return "Safari 확장이 켜져 있어요"
        case false?: return "Safari 확장을 켜 주세요"
        case nil: return "Safari에서 설정을 확인해 주세요"
        }
    }

    private var detail: String {
        if status.loading { return "Safari에 연결하고 있습니다." }
        switch status.enabled {
        case true?: return "사이트 접근을 허용한 페이지에서 사용할 수 있습니다."
        case false?: return "아래 버튼을 눌러 Sideway를 활성화해 주세요."
        case nil: return "아래 버튼으로 Safari 확장 설정을 열 수 있습니다."
        }
    }

    private var dotColor: Color {
        if status.loading { return Color.secondary.opacity(0.5) }
        switch status.enabled {
        case true?: return accent
        case false?: return Color(.sRGB, red: 0.78, green: 0.58, blue: 0.22)
        case nil: return Color.secondary.opacity(0.5)
        }
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 15, style: .continuous)
            .fill(Color(nsColor: .controlBackgroundColor))
            .overlay(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .stroke(Color.primary.opacity(0.07), lineWidth: 1)
            )
    }

    private func navigationCard(symbol: String, label: String, title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Image(systemName: symbol)
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(accent)
                .padding(.bottom, 7)
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.system(size: 16, weight: .semibold))
            Text(subtitle)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
    }
}

private let lucideLicense = """
ISC License

Copyright (c) 2026 Lucide Icons and Contributors

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

---

The following Lucide icons are derived from the Feather project:

airplay, alert-circle, alert-octagon, alert-triangle, aperture, arrow-down-circle, arrow-down-left, arrow-down-right, arrow-down, arrow-left-circle, arrow-left, arrow-right-circle, arrow-right, arrow-up-circle, arrow-up-left, arrow-up-right, arrow-up, at-sign, calendar, cast, check, chevron-down, chevron-left, chevron-right, chevron-up, chevrons-down, chevrons-left, chevrons-right, chevrons-up, circle, clipboard, clock, code, columns, command, compass, corner-down-left, corner-down-right, corner-left-down, corner-left-up, corner-right-down, corner-right-up, corner-up-left, corner-up-right, crosshair, database, divide-circle, divide-square, dollar-sign, download, external-link, feather, frown, hash, headphones, help-circle, info, italic, key, layout, life-buoy, link-2, link, loader, lock, log-in, log-out, maximize, meh, minimize, minimize-2, minus-circle, minus-square, minus, monitor, moon, more-horizontal, more-vertical, move, music, navigation-2, navigation, octagon, pause-circle, percent, plus-circle, plus-square, plus, power, radio, rss, search, server, share, shopping-bag, sidebar, smartphone, smile, square, table-2, tablet, target, terminal, trash-2, trash, triangle, tv, type, upload, x-circle, x-octagon, x-square, x, zoom-in, zoom-out

The MIT License (MIT) (for the icons listed above)

Copyright (c) 2013-present Cole Bemis

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"""
