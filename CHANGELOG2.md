# Ludi 更新日誌（CHANGELOG2）

> 本檔接續記錄 Ludi 開發進度。舊日誌內容已整合至 `AGENTS.md` 各章節，本檔專注於 TestFlight 上傳後的上架流程追蹤。
> 日期：2026-07-17 起。

---

## 驗證 Codemagic Build 真的成功（優先於一切）

> 觸發點：2026-07-20 Gary 反映過去有「Codemagic 顯示 build 成功但實際有問題」的情況，需逐項確認後才能進入上架流程。
> 已從 log 確認（2026-07-20）：code signing 設定正確 -- profile = `Ludi App Store` [bdf586ef-...]、cert = Apple Distribution、Team Id = `HKT6H4B638`、Method = `app-store`、Signing Style = manual。這部分沒問題。
> 待確認的是：IPA 是否真的產生 + 是否真的上傳到 App Store Connect。

| # | 狀態 | 項目 | 說明 / 如何確認 |
|---|------|------|------|
| 0.1 | [ ] | Codemagic workflow 整體 status = success | Codemagic dashboard -> 該次 build -> 頂部狀態為綠色 Success（不是黃色/紅色） |
| 0.2 | [ ] | `Build IPA` script 步驟完成無錯誤 | log 出現綠色 ✓；無 stderr 紅字；`flutter build ipa --release` 正常結束 |
| 0.3 | [ ] | `List build artifacts` script 顯示 .ipa 檔案 | log 應出現 `build/ios/ipa/*.ipa` 路徑與實際檔名（例如 `Ludi.ipa`）+ 檔案大小 |
| 0.4 | [ ] | `publishing: app_store_connect` 步驟顯示上傳成功 | log 出現 `Successfully published` 或 `Uploaded to App Store Connect` 字樣 |
| 0.5 | [ ] | App Store Connect -> TestFlight 出現新 build | 登入 https://appstoreconnect.apple.com -> My Apps -> Ludi -> TestFlight -> Builds 區塊看到新 build |
| 0.6 | [ ] | build status = Processing（剛上傳）或 Available | 處理中通常 5-30 分鐘，完成後 Apple 會寄 email「Processing completed」 |
| 0.7 | [ ] | build number 與 Codemagic log 對應 | 確認 App Store Connect 顯示的 build number 就是這次 Codemagic build 的版本 |

> ⚠️ 只要 0.1-0.4 任一未確認，就代表 build 可能只是「code signing 步驟成功」而非「整個 build + 上傳成功」。請 Gary 貼上完整 Codemagic build log（特別是 `Build IPA` / `List build artifacts` / `publishing` 三個步驟）或截圖，才能逐項打勾。

---

## iOS 上架流程 To-Do List

> 觸發點：2026-07-17 IPA 已上傳 App Store Connect，TestFlight build 進入 Processing。
> 完成規則：每項完成後將 `[ ]` 改為 `[x]` 並補上完成日期。
> ⚠️ 本區塊所有項目需在「驗證 Codemagic Build 真的成功」全部打勾後才開始。

| # | 狀態 | 項目 | 說明 |
|---|------|------|------|
| 1 | [ ] | 確認 TestFlight Build 處理完成 | App Store Connect -> TestFlight，等 build status 從 Processing 變可用，會收到 Apple email 通知 |
| 2 | [ ] | 填寫 TestFlight 測試資訊 | 測試說明、回饋 email、隱私權政策 URL（https://garyhcy.github.io/mahjong-learning/legal/privacy.html） |
| 3 | [ ] | 加入內部測試員 | Internal Testers，需為 App Store Connect 帳號內 Admin / Account Holder / Developer 角色成員 |
| 4 | [ ] | 分發 Build 給內部測試群組 | 建立群組 -> 選 build -> 加測試員 -> 發送邀請，測試員透過 TestFlight app 安裝測試 |
| 5 | [ ] | 實機測試核心流程並收集回饋 | 登入、闖關、訂閱、雲端同步，透過 TestFlight 回饋或直接回報 |
| 6 | [ ] | 製作 App Store 商店截圖 | 6.7" iPhone（1290×2796）必要，6.5" / iPad 選填，可用模擬器截圖 |
| 7 | [ ] | 填寫 App Store 頁面資訊 | 描述、關鍵字、副標題、類別、年齡分級、版權、支援 URL、隱私權政策 URL |
| 8 | [ ] | 填寫 App Privacy 資料收集聲明 | 如實聲明 Email、Usage Data（Firebase Auth、Firestore、RevenueCat 使用資料） |
| 9 | [ ] | 提交 App Store 審核 | 確認資訊齊全 -> 選 build -> Submit for Review，審核通常 24-48 小時 |

---

## 進度紀錄

### 2026-07-17
- IPA 上傳 App Store Connect 完成（Codemagic build），TestFlight build 進入 Processing。
- 建立 CHANGELOG2.md，放入 iOS 上架流程 9 項 to-do。

### 2026-07-20
- Gary 反映過去有「build 成功但實際有問題」的情況，新增「驗證 Codemagic Build 真的成功」區塊（7 項檢查），優先於上架流程。
- 已從 Gary 貼的 code signing log 確認：profile / cert / Team Id / method 皆正確，使用新建立的 `Ludi App Store` provisioning profile。
- 待 Gary 提供完整 Codemagic build log（Build IPA / List build artifacts / publishing 三步驟）才能逐項打勾。
- Gary 多次確認 Codemagic 簽名設定（避免未來重複討論）：profile reference name = `Ludi Distribution`、UUID = `bdf586ef-f1a7-4e2b-8a34-700d15036abc`（仍有效，含 Push + Sign in with Apple）、certificate = `Ludi_codemagic`、App Store Connect 已無 Activity tab（build 在 TestFlight > Builds）。
- 將上述確認事項寫入 AGENTS.md 第 11.1 節。
- 確認 git 實際狀態：SESSION_LOG 所稱「8 項未提交變更」實際已於 commit `16cd7a7` 提交，本次只剩文件變更（AGENTS.md + CHANGELOG2.md）。
