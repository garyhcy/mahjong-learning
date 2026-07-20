# Ludi Codemagic / TestFlight Debug 紀錄

> **用途**：專門記錄 Codemagic build 與 TestFlight 上傳相關的所有對話、提供的資訊、已嘗試的方法與結果。避免 Gary 重複提供相同資訊。
> **建立日期**：2026-07-20
> **最新更新**：2026-07-20（初次建立）

---

## 一、核心矛盾（當前問題）

| 項目 | 狀態 |
| --- | --- |
| Codemagic publishing → app_store_connect 步驟 | 🟢 SUCCESS（綠色） |
| App Store Connect → 商業 → 協議、稅務與銀行業務 → Paid Applications Agreement | 🟢 Active |
| App Store Connect → TestFlight → Builds 頁面 | 🔴 完全空白 |

**矛盾點**：理論上 publishing SUCCESS 代表 IPA 已交付 Apple 上傳端點，TestFlight 應至少顯示 processing 中的 build。完全空白代表 Apple 端未收到 / 未記錄 / 靜默拒絕。

---

## 二、已知事實（不需再問 Gary）

### 帳號與簽名（AGENTS.md 11.1 節已確認）

| 項目 | 值 |
| --- | --- |
| Bundle ID | `com.ludi.teach` |
| App Store Connect API Key integration | `Ludi-Codemagic` |
| Profile reference name | `Ludi Distribution` |
| Profile UUID | `bdf586ef-f1a7-4e2b-8a34-700d15036abc` |
| Profile 類型 | App Store distribution |
| Profile 含 capabilities | Push Notifications + Sign in with Apple |
| Certificate 名稱 | `Ludi_codemagic`（Codemagic 持有 private key） |
| Team ID | `HKT6H4B638` |
| Apple Developer Program | ✅ 已啟用 |
| Paid Applications Agreement | ✅ Active |

### codemagic.yaml 配置（已核對）

```yaml
publishing:
  app_store_connect:
    auth: integration        # 使用 Ludi-Codemagic integration
    submit_to_testflight: true
artifacts: build/ios/ipa/*.ipa
```

- `ios_signing` 用 automatic 模式（`distribution_type: app_store` + `bundle_identifier: com.ludi.teach`）
- Build IPA script 含 `set -e` + 診斷 script（列出 build/ios 目錄 + 全機搜尋 *.ipa）

### 版本

- `pubspec.yaml` version: `1.0.1+3`（Version 1.0.1 / Build 3）

### iOS 設定

- `Runner.entitlements` 含 `aps-environment`（development）+ `com.apple.developer.applesignin`（Default）
- `ios/ExportOptions.plist`：**不存在**（依賴 Codemagic 自動產生）

---

## 三、歷史軌跡（已嘗試過的方法）

### 2026-07-17 16:20 - 第一次診斷
- **問題**：Publishing < 1s，TestFlight 無 Builds
- **根因**：IPA 未產出（`No artifacts were found`）

### 2026-07-17 16:30 - 根因確認
- Codemagic Publishing log 顯示 `== Gathering artifacts ==` `No artifacts were found`
- `flutter build ipa` 的 Build IPA 步驟顯示綠色但實際未產出 .ipa
- 可能：.app build 成功但 export 階段失敗，exit code 未正確反映

### 2026-07-17 16:50 - 修正 codemagic.yaml
- Commit `16cd7a7`
- 加 `set -e` 確保 export 失敗時 build fail
- 加「List build artifacts」診斷 script
- artifacts 路徑維持 `build/ios/ipa/*.ipa`

### 2026-07-20 12:20 - Build IPA 仍失敗
- **Gary 提供的 build log**：
  - Archive 成功：`✓ Built build/ios/archive/Runner.xcarchive (282.4MB)`
  - App Settings Validation 通過（Version 1.0.1 / Build 3 / com.ludi.teach）
  - **Build App Store IPA 失敗（921ms）**：`error: exportArchive "Runner.app" requires a provisioning profile with the Push Notifications and Sign in with Apple features.`
  - `=== all .ipa files in workspace ===` 空
  - `=== build/ios/ipa/ does not exist`
  - Publishing：`No artifacts were found`
- **根因**：Codemagic 使用的 profile 不含 Push + Apple Sign-In capabilities
- **Gary 補充**：新 profile（含 capabilities）已上傳 Codemagic dashboard 並選用，但 build 仍失敗
- **疑點**：`ios_signing` automatic 模式可能不使用 dashboard 手動上傳的 profile

### 2026-07-20（12:20 之後，AGENTS.md 11.1 記載）- 重新 build 成功
- Profile UUID `bdf586ef-...` 成功用於 target Runner（Debug/Profile/Release configurations）
- App Store provisioning profile 已 regenerate，含 Push + Apple Sign-In
- 新 profile 已上傳 Codemagic dashboard 替換舊 profile
- **但 TestFlight 仍無 build**（memory 記載 "in TestFlight processing" 但 Gary 確認空白）

### 2026-07-20（現在）- 新狀態
- **Codemagic publishing 步驟：綠色 SUCCESS**（與之前 "No artifacts were found" 不同）
- **TestFlight → Builds：完全空白**
- 這是新的矛盾：publishing SUCCESS 但 TestFlight 空白

---

## 四、最可能的原因（依機率排序）

### 原因 1：Apple 在 processing 階段靜默拒絕 build（最可能）

- Apple 收到 IPA 後會 async processing（15-30 分鐘）
- 若 processing 失敗，Apple 通常發 email 通知，但有時進垃圾信箱
- TestFlight 不會顯示被拒絕的 build
- **常見拒絕原因**：
  - 缺少 Privacy Manifest（`PrivacyInfo.xcprivacy`）- iOS 17+ 新要求
  - Info.plist 缺少必要 key
  - 使用 deprecated API（如 UIWebView）
  - 缺少 required device capability

### 原因 2：Codemagic publishing SUCCESS 是假象

- publishing 步驟綠色可能只代表「嘗試上傳」完成（HTTP 200）
- 並未真正完成 Apple 端的 build 處理
- 需看 publishing 步驟的「完整文字 log」確認

### 原因 3：build 仍在 Apple processing 中

- 若 build 是剛觸發的（< 30 分鐘），可能還在處理
- 但 Gary 說「已提供過兩次截圖」，暗示已等過一段時間
- processing 中的 build 通常也會顯示在 TestFlight

### 原因 4：版本號衝突

- IPA 的 CFBundleVersion = 3
- 若 App Store Connect 已有 build 3（即使失敗），Apple 會靜默拒絕重複
- 但 Gary 說 TestFlight 空白，不太可能

### 原因 5：build 上傳到錯誤的 App Store Connect app record

- bundle ID 不匹配
- 但通常會在 publishing 階段就報錯

---

## 五、需要 Gary 提供的新資訊（非重複要求）

> 以下為「新」請求，基於目前矛盾點設計，不是重複要舊截圖。

### 請求 1：Codemagic publishing 步驟的「完整文字 log」

- 不是看步驟的綠色狀態列，而是**點開 publishing → app_store_connect 步驟，看裡面的文字輸出**
- 我要看是否有以下訊息：
  - `Uploading IPA to App Store Connect`
  - `Upload succeeded`
  - `Build received by App Store Connect`
  - `No artifacts were found`
  - 任何 error / warning 訊息
- **複製文字貼上即可**（不需要截圖）

### 請求 2：檢查 email（含垃圾信箱）是否有 Apple 通知

- Gary 的 Apple ID 關聯 email（zero1993329@gmail.com）
- 搜尋關鍵字：`App Store Connect`、`TestFlight`、`build`、`processing`
- Apple 通常會在 build 處理完成或失敗時發 email
- **回報有沒有收到任何相關 email**（不用貼內容，只要說有/沒有）

### 請求 3：這次 SUCCESS 的 build 觸發時間

- 這次顯示 SUCCESS 的 build 是什麼時候觸發的？
- 距離現在多久了？
- 如果是剛剛（< 30 分鐘），可能還在 Apple processing

### 請求 4：App Store Connect 左側欄完整結構

- App Store Connect → My Apps → Ludi → 左側欄的所有分頁名稱
- 截圖左側欄即可，我想確認導覽結構（Apple UI 變動頻繁）

---

## 六、已排除的方向

| 方向 | 排除原因 |
| --- | --- |
| Profile 缺 capabilities | AGENTS.md 11.1 已確認新 profile 含 Push + Apple Sign-In |
| Certificate private key 遺失 | 已解決（Codemagic 持有） |
| Paid Apps Agreement 未生效 | Gary 確認 Active |
| Apple Developer Program 未啟用 | 已啟用 |
| artifacts 路徑不符 | publishing SUCCESS 代表有 artifacts 可上傳 |
| Bundle ID 不匹配 | AGENTS.md 已確認統一 com.ludi.teach |

---

## 七、對話紀錄（每次更新往下方追加）

### 2026-07-20 14:20 - 初始建立
- Gary 要求建立此檔案，避免重複提供資訊
- Gary 提供當前狀態：publishing SUCCESS + TestFlight 空白 + Paid Apps Active
- 已讀完 CHANGELOG2.md，確認歷史軌跡
- 下一步：等 Gary 回覆第五節的 4 個請求
