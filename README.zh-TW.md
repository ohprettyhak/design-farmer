# design-farmer

[![Skill Quality](https://github.com/ohprettyhak/design-farmer/actions/workflows/skill-quality.yml/badge.svg)](https://github.com/ohprettyhak/design-farmer/actions/workflows/skill-quality.yml)
[![Last Commit](https://img.shields.io/github/last-commit/ohprettyhak/design-farmer/main)](https://github.com/ohprettyhak/design-farmer/commits/main/)
[![Latest Release](https://img.shields.io/github/v/release/ohprettyhak/design-farmer?sort=semver)](https://github.com/ohprettyhak/design-farmer/releases)

[English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md) | [简体中文](README.zh.md) | **繁體中文**

> 從種子到系統——從任何程式碼庫中培育出生產級設計系統。

`design-farmer` 是一個面向 AI 編碼助手的技能。它會分析你的repo，提取現有的設計模式，並將其培育為結構化、無障礙的 OKLCH 原生設計系統，涵蓋 token、元件、測試和文件。

## 為什麼需要它？

用 AI 助手進行 vibe coding 時，設計一致性往往最先失控——顏色不統一、間距隨意、深色模式缺失。雖然給助手明確的設計約束確實能提高 UI 一致性，但手動搭建這套約束本身就違背了初衷。

Design Farmer 將整個流程自動化：讀取程式碼庫，理解現有內容，然後在此基礎上建構（或升級）生產級設計系統。不用手寫 token 檔案，不用複製貼上調色盤，無需憑空想像。

## 核心功能

Design Farmer 根據專案狀態分階段工作：

| 起始狀態 | 執行內容 | 結果 |
|---|---|---|
| **沒有設計系統** | 發現程式碼中的顏色與間距，轉換為 OKLCH，建立 token 層級 | 基礎 token + 語義 token，經過對比度驗證的色階 |
| **部分系統** | 審核現有 token，識別缺失部分（狀態、角色、主題） | 在不影響現有引用的前提下補全語義覆蓋 |
| **缺少互動元件** | 建構具有鍵盤/焦點行為的 Button、Input、Select、Dialog | 附帶互動測試的統一無障礙元件 |
| **僅有淺色主題** | 透過 OKLCH 明度/色度調整產生深色主題 | 基於同一套語義定義的雙主題系統 |
| **聲稱「生產就緒」** | 多人審查驗證，發現樣式漂移和 token 誤用 | 有據可查的完成狀態與改進建議 |

完整流程涵蓋：預檢、需求訪談、repo 分析、OKLCH 模式提取、視覺預覽、架構設計、主題系統、DESIGN.md 產生、token 實作、元件庫、Storybook 整合、多人審查、即時視覺 QA、文件輸出、應用整合、發布準備。

## 產出成果

- **OKLCH 顏色系統**：自動驗證對比度的感知均勻色階
- **Token 層級**：按基礎 → 語義 → 元件層級組織的 token 體系
- **無障礙元件**：原生支援鍵盤導航、焦點管理與 ARIA 狀態
- **雙主題支援**：同一套 token 定義下的淺色與深色模式切換
- **DESIGN.md**：記錄設計決策的機器可讀參考文件，充當專案唯一事實來源
- **驗證證據**：用清晰的通過/失敗標準替代「差不多」式的審批

<img src="assets/storybook-components.png" alt="Design Farmer 產生的元件庫展示" width="100%" />

以上截圖來自一個從零開始的全新專案——沒有 token、元件或設計決策。如果你的 repo 已有部分實作（如元件、顏色變數、樣式指南等），Design Farmer 會在此基礎上繼續建構，產出更精細的結果。

> [!TIP]
> **想要更好的效果？** 執行前在專案根目錄放一個 [`DESIGN.md`](https://github.com/VoltAgent/awesome-design-md)。
> - 用 [Stitch](https://stitch.withgoogle.com) 產生，或者
> - 從 [awesome-design-md](https://github.com/VoltAgent/awesome-design-md) 取得現成檔案——收錄了 Vercel、Linear、Stripe 等 58 個以上真實站點的設計系統。

## 安裝

### Claude Code — 市集（推薦）

透過 Claude Code 市集直接安裝，外掛生命週期由 Claude Code 統一管理：

1. 開啟 Claude Code 設定，進入 **Plugins → Marketplace**。
2. 搜尋 **design-farmer** 並點擊 **Install**。

### 所有工具 — curl 安裝腳本

```bash
curl -fsSL https://raw.githubusercontent.com/ohprettyhak/design-farmer/main/install.sh | bash
```

自動偵測並安裝到 **Claude Code**、**Codex CLI**、**Amp**、**Gemini CLI** 和 **OpenCode**。

選擇性安裝旗標（`--tool`、`--interactive`、`--dry-run`）、手動安裝、問題排查及解除安裝方法詳見 [INSTALLATION.md](INSTALLATION.md)。

## 文件

- [安裝指南](INSTALLATION.md)：涵蓋市集／curl 安裝、手動安裝、問題排查與解除安裝的官方參考
- [技能規範](skills/design-farmer/SKILL.md)：執行時參考的指令檔

維護者與貢獻者參考：

- [內部專案契約](docs/README.md)：repo 實作契約與規劃紀錄
- [階段索引](skills/design-farmer/docs/PHASE-INDEX.md)：維護者參考的執行流程
- [品質關卡](skills/design-farmer/docs/QUALITY-GATES.md)：驗證標準與發布檢查清單
- [維護指南](skills/design-farmer/docs/MAINTENANCE.md)：樣式一致性維護與更新流程
- [範例畫廊](skills/design-farmer/docs/EXAMPLES-GALLERY.md)：按場景展示的前後對比與階段對照

## 貢獻

- [貢獻指南](CONTRIBUTING.md)
