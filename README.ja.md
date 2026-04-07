# design-farmer

[![Skill Quality](https://github.com/ohprettyhak/design-farmer/actions/workflows/skill-quality.yml/badge.svg)](https://github.com/ohprettyhak/design-farmer/actions/workflows/skill-quality.yml)
[![Last Commit](https://img.shields.io/github/last-commit/ohprettyhak/design-farmer/main)](https://github.com/ohprettyhak/design-farmer/commits/main/)
[![Latest Release](https://img.shields.io/github/v/release/ohprettyhak/design-farmer?sort=semver)](https://github.com/ohprettyhak/design-farmer/releases)

[English](README.md) | [한국어](README.ko.md) | **日本語** | [中文](README.zh.md)

> 種からシステムへ — あらゆるコードベースからプロダクション品質のデザインシステムを育てます。

`design-farmer`はコーディングエージェント向けのスキルです。リポジトリを分析し、既存のデザインパターンを抽出したうえで、トークン・コンポーネント・テスト・ドキュメントを備えたOKLCHベースのデザインシステムへ育て上げます。

## なぜ必要?

AIエージェントとバイブコーディングをしていると、まずデザインの一貫性が崩れます。色はばらつき、余白は場当たり的になり、ダークモードは後回しに。エージェントに明確なデザイン制約を渡せば、はるかに一貫したUIが得られますが、その制約を手作業で用意するのは本末転倒です。

Design Farmerはこの工程をまるごと自動化します。コードベースを読み取り、すでにあるものを把握したうえで、プロダクション品質のデザインシステムを構築（またはアップグレード）します。トークンファイルの手書きも、カラーパレットのコピペも不要です。

## できること

Design Farmerはプロジェクトの状態に合わせ、フェーズごとに動作します：

| 開始状態 | 実行内容 | 結果 |
|---|---|---|
| **デザインシステムなし** | コード中の色・余白を検出し、OKLCHへ変換、トークン階層を作成 | プリミティブ＋セマンティックトークン、コントラスト検証済みのカラースケール |
| **部分的なシステム** | 既存トークンを監査し、欠落部分（状態、ロール、テーマ）を特定 | 既存の参照を壊さずにセマンティックカバレッジを補完 |
| **インタラクティブコンポーネントが未整備** | キーボード／フォーカス動作を持つButton、Input、Select、Dialogを構築 | インタラクションテスト付きの統一されたアクセシブルコンポーネント |
| **ライトテーマのみ** | OKLCH明度・彩度の調整でダークテーマを生成 | ひとつのセマンティック定義で切り替わるデュアルテーマ |
| **「本番対応済み」の主張** | 複数レビューアによる検証で、スタイルのずれやトークン誤用を検出 | 根拠に基づく完了判定と改善メモ |

フルパイプラインは全12フェーズで構成されます：プリフライト検出、ディスカバリーインタビュー、リポジトリ分析、OKLCHベースのパターン抽出、ビジュアルプレビュー、アーキテクチャ設計、テーマシステム、DESIGN.md生成、トークン実装、コンポーネントライブラリ、Storybook連携、複数レビューア検証、ライブビジュアルQA、ドキュメント整備、アプリ統合、リリース準備。

## 得られるもの

- **OKLCHカラーシステム** — コントラスト自動検証つきの、知覚的に均一なカラースケール
- **トークン階層** — プリミティブ → セマンティック → コンポーネントの順に整理されたトークン構造
- **アクセシブルコンポーネント** — キーボード操作、フォーカス管理、ARIAステートを標準搭載
- **デュアルテーマ** — 同じトークン定義でライト・ダークを切り替え
- **DESIGN.md** — デザイン判断を集約した、機械可読なリファレンスドキュメント
- **検証エビデンス** — 「良さそう」で済ませず、明確な合否基準に基づく多角的レビュー

## インストール

```bash
curl -fsSL https://raw.githubusercontent.com/ohprettyhak/design-farmer/main/install.sh | bash
```

インストーラが利用中のツールを検出し、スキルディレクトリの作成とバンドルのダウンロードを行います。対応ツール：**Claude Code**、**Codex CLI**、**Amp**、**Gemini CLI**、**OpenCode**。

手動インストールやトラブルシューティングは[INSTALLATION.md](INSTALLATION.md)を参照してください。

## ドキュメント

- [スキル仕様](skills/design-farmer/SKILL.md) — 実行時に参照される設定ファイル。
- [フェーズインデックス](skills/design-farmer/docs/PHASE-INDEX.md) — メンテナー向けの実行フロー。
- [品質ゲート](skills/design-farmer/docs/QUALITY-GATES.md) — 検証基準とリリースチェックリスト。
- [メンテナンスガイド](skills/design-farmer/docs/MAINTENANCE.md) — スタイルの一貫性維持とアップデート手順。
- [事例ギャラリー](skills/design-farmer/docs/EXAMPLES-GALLERY.md) — シナリオごとのビフォー／アフターとフェーズ対応表。

## コントリビューション

- [コントリビューションガイド](CONTRIBUTING.md)
