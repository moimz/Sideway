# Sideway

Safari 에서 **마우스 측면 버튼**(로지텍 등의 뒤로·앞으로 버튼)으로 이전 페이지와 다음 페이지를 오가게 해 주는 맥용 Safari 확장입니다.

*A Safari web extension for Mac that makes the mouse side buttons (back/forward) navigate pages in Safari.*

## 기능

- 측면 버튼 뒤로 → 이전 페이지, 앞으로 → 다음 페이지 (모든 사이트, iframe 포함)
- 방문 기록을 모으거나 보내지 않음 — 확장은 버튼 클릭만 보고 `history.back()` / `history.forward()` 를 부름
- 앱 화면에서 확장이 켜져 있는지 확인하고, Safari 확장 설정을 바로 열기
- 자동 업데이트 (Sparkle): 하루 한 번 새 버전을 확인하고, 있으면 설치할지 묻기

## 설치

1. [최신 릴리즈](https://github.com/moimz/Sideway/releases/latest)에서 `Sideway-….dmg` 를 받아 열고 Sideway 를 응용 프로그램 폴더로 끌어 놓습니다.
2. Sideway 를 한 번 실행합니다.
3. Safari → 설정 → 확장 프로그램에서 **Sideway** 를 켜고, 웹사이트 접근을 허용합니다.

## 요구 사항

- macOS 14 이상, Apple 실리콘 맥
- Safari

## 빌드

Xcode 26 이상에서 `Sideway.xcodeproj` 를 엽니다. 대상은 앱 `Sideway` 와 Safari 확장 `Sideway Extension` 두 개이고, 자동 업데이트에 쓰는 [Sparkle](https://sparkle-project.org) 은 Swift Package 로 받습니다.

## 라이선스

앱 아이콘은 [Lucide](https://lucide.dev) 아이콘(ISC, 일부 MIT)을 바탕으로 했습니다. 전문은 앱 화면의 "아이콘 출처 및 라이선스"에 있습니다.
