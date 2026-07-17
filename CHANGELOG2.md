# Ludi 更新日誌（CHANGELOG2）

> 本檔接續記錄 Ludi 開發進度。舊日誌內容已整合至 `AGENTS.md` 各章節，本檔專注於 TestFlight 上傳後的上架流程追蹤。
> 日期：2026-07-17 起。

---

## iOS 上架流程 To-Do List

> 觸發點：2026-07-17 IPA 已上傳 App Store Connect，TestFlight build 進入 Processing。
> 完成規則：每項完成後將 `[ ]` 改為 `[x]` 並補上完成日期。

| # | 狀態 | 項目 | 說明 |
|---|------|------|------|
| 1 | [ ] | 確認 TestFlight Build 處理完成 | App Store Connect → TestFlight，等 build status 從 Processing 變可用，會收到 Apple email 通知 |
| 2 | [ ] | 填寫 TestFlight 測試資訊 | 測試說明、回饋 email、隱私權政策 URL（https://garyhcy.github.io/mahjong-learning/legal/privacy.html） |
| 3 | [ ] | 加入內部測試員 | Internal Testers，需為 App Store Connect 帳號內 Admin / Account Holder / Developer 角色成員 |
| 4 | [ ] | 分發 Build 給內部測試群組 | 建立群組 → 選 build → 加測試員 → 發送邀請，測試員透過 TestFlight app 安裝測試 |
| 5 | [ ] | 實機測試核心流程並收集回饋 | 登入、闖關、訂閱、雲端同步，透過 TestFlight 回饋或直接回報 |
| 6 | [ ] | 製作 App Store 商店截圖 | 6.7" iPhone（1290×2796）必要，6.5" / iPad 選填，可用模擬器截圖 |
| 7 | [ ] | 填寫 App Store 頁面資訊 | 描述、關鍵字、副標題、類別、年齡分級、版權、支援 URL、隱私權政策 URL |
| 8 | [ ] | 填寫 App Privacy 資料收集聲明 | 如實聲明 Email、Usage Data（Firebase Auth、Firestore、RevenueCat 使用資料） |
| 9 | [ ] | 提交 App Store 審核 | 確認資訊齊全 → 選 build → Submit for Review，審核通常 24-48 小時 |

---

## 進度紀錄

### 2026-07-17
- IPA 上傳 App Store Connect 完成（Codemagic build），TestFlight build 進入 Processing。
- 建立 CHANGELOG2.md，放入 iOS 上架流程 9 項 to-do。
