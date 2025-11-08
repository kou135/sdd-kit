# DocDD

Cursor/Claude開発環境の設定ファイルとワークフロー定義を提供するプロジェクトです。

## クイックスタート

他のプロジェクトに設定ファイルを移行するには、以下のコマンドを実行するだけです：

```bash
curl -fsSL https://raw.githubusercontent.com/imaimai17468/docdd/main/migrate.sh | bash -s -- .
```

**リポジトリをクローンする必要はありません！**

### 実行例

```bash
# カレントディレクトリに移行
curl -fsSL https://raw.githubusercontent.com/imaimai17468/docdd/main/migrate.sh | bash -s -- .

# 特定のプロジェクトに移行
curl -fsSL https://raw.githubusercontent.com/imaimai17468/docdd/main/migrate.sh | bash -s -- /Users/username/my-project

# 相対パスでも指定可能
curl -fsSL https://raw.githubusercontent.com/imaimai17468/docdd/main/migrate.sh | bash -s -- ../my-project
```

### 別の実行方法

```bash
# プロセス置換方式（bash 4.0+）
bash <(curl -fsSL https://raw.githubusercontent.com/imaimai17468/docdd/main/migrate.sh) /path/to/target-project
```

## 移行されるファイル

### ルートレベル
- `CLAUDE.md` - 開発ワークフローの定義（Phase 1-11）
- `MCP_REFERENCE.md` - MCPコマンドの詳細リファレンス
- `.cursorrules` - Cursorの設定ルール
- `.mcp.json` - MCP設定

### .claude/ ディレクトリ
- `.claude/agents/*.md` - Claudeエージェント定義（7種類）
  - `adr-memory-manager.md`
  - `app-code-specialist.md`
  - `project-onboarding.md`
  - `spec-document-creator.md`
  - `storybook-story-creator.md`
  - `test-guideline-enforcer.md`
  - `ui-design-advisor.md`
- `.claude/settings.json` - Claude設定

### .cursor/ ディレクトリ
- `.cursor/commands/*.md` - Cursorコマンド定義（7種類）
  - `adr-memory-manager.md`
  - `app-code-specialist.md`
  - `project-onboarding.md`
  - `spec-document-creator.md`
  - `storybook-story-creator.md`
  - `test-guideline-enforcer.md`
  - `ui-design-advisor.md`
- `.cursor/mcp.json` - Cursor MCP設定
- `.cursor/settings.json` - Cursor設定

## 開発ワークフローについて

このプロジェクトには、Cursor/Claudeを使用した開発ワークフローが定義されています。`CLAUDE.md`に詳細な手順が記載されています。

### ワークフロー概要

開発作業は11のフェーズに分かれており、変更のタイプに応じて適切なフェーズを選択します：

| 変更タイプ | 推奨フロー | 所要時間目安 |
|-----------|-----------|-------------|
| **新機能追加** | Phase 1-11 全て | 60-120分 |
| **中規模バグ修正** | 1,4,5,6,8,9A,10,11 | 30-60分 |
| **UI/デザイン調整** | 1,3,4,5,8,9A,10,11 | 20-40分 |
| **小規模リファクタ** | 1,4,5,8,10,11 | 15-30分 |
| **タイポ修正** | 5,8,10,11 | 5分 |
| **ドキュメント更新** | 5,10,11 | 5-10分 |

### 必須フェーズ

ほぼすべてのケースで実行するフェーズ：

1. **Phase 1: Investigation & Research** - Context7/Kiriで調査
4. **Phase 4: Planning** - TodoWriteで計画立案
5. **Phase 5: Implementation** - Serenaでコード実装
8. **Phase 8: Quality Checks** - bun run でチェック実行
9. **Phase 9A: Runtime Verification** - Next.js MCPで動作確認
10. **Phase 10: Git Commit** - コミット作成
11. **Phase 11: Push** - リモートへプッシュ

### 状況に応じて実行（推奨）

- **Phase 2: Architecture Design** - 新機能や大規模変更時
- **Phase 3: UI/UX Design** - UI変更がある場合
- **Phase 6: Testing & Stories** - ロジック変更がある場合
- **Phase 7: Code Review** - リファクタリングが必要な場合
- **Phase 9B: Browser Verification** - 詳細な動作確認が必要な場合

詳細は [CLAUDE.md](./CLAUDE.md) を参照してください。

## MCP（Model Context Protocol）について

このプロジェクトでは、MCP（Model Context Protocol）を活用して開発効率を向上させています。MCPは、AIアシスタントが外部ツールやサービスと連携するためのプロトコルです。

### 使用するMCP

| MCP | 用途 | フェーズ |
|-----|------|---------|
| **Kiri MCP** | コードベース検索、コンテキスト抽出、依存関係分析 | Phase 1（調査） |
| **Serena MCP** | シンボルベース編集、リネーム、挿入・置換 | Phase 5（実装） |
| **Next.js Runtime MCP** | ランタイムエラー確認、ルート確認 | Phase 9A（動作確認） |
| **Chrome DevTools MCP** | ブラウザ検証、パフォーマンス測定 | Phase 9B（詳細検証） |
| **Context7 MCP** | ライブラリドキュメント取得 | 全フェーズ |

### MCPの主な機能

#### Kiri MCP（調査フェーズ）
- **コンテキスト自動取得**: タスクに関連するコードスニペットを自動ランク付け
- **セマンティック検索**: 意味的に類似したコードを検索
- **依存関係分析**: ファイル間の依存関係を可視化

#### Serena MCP（実装フェーズ）
- **シンボルベース編集**: 関数やクラス単位での正確な編集
- **自動リネーム**: プロジェクト全体での一括リネーム
- **参照検索**: 影響範囲の確認

#### Next.js Runtime MCP（動作確認）
- **エラー確認**: ビルド・ランタイムエラーの取得
- **ルート確認**: アプリケーションのルート構造を確認
- **ログ確認**: 開発サーバーのログを取得

#### Chrome DevTools MCP（詳細検証）
- **ページ構造確認**: アクセシビリティツリーの取得
- **インタラクションテスト**: クリック、入力などの操作
- **パフォーマンス測定**: Core Web Vitalsの測定

詳細は [MCP_REFERENCE.md](./MCP_REFERENCE.md) を参照してください。

## 移行スクリプトの動作の流れ

1. **引数チェック**: ターゲットプロジェクトのパスが指定されているか確認
2. **ディレクトリ確認**: ターゲットディレクトリが存在するか確認
3. **ファイルダウンロード**: GitHubから必要なファイルをダウンロード
4. **ファイルコピー**: ダウンロードしたファイルをターゲットプロジェクトにコピー
5. **既存ファイル確認**: 既存ファイルがある場合は上書き確認

## 既存ファイルの扱い

移行先に既に同名のファイルが存在する場合、上書きするか確認されます：

```
警告: CLAUDE.md は既に存在します。上書きしますか？ (y/N)
```

- `y` または `Y` を入力: 上書き
- その他: スキップ

## 注意事項

### 個人設定ファイル

`.claude/settings.local.json` は個人用の設定ファイルです。デフォルトでは移行されません。

### プロジェクト固有の設定

移行後、以下の設定をプロジェクトに合わせて調整してください：

1. **MCP設定** (`.mcp.json`, `.cursor/mcp.json`)
   - プロジェクト固有のMCPサーバー設定を確認

2. **設定ファイル** (`.claude/settings.json`, `.cursor/settings.json`)
   - プロジェクト固有の設定を確認

3. **ワークフロー定義** (`CLAUDE.md`)
   - プロジェクトの技術スタックに合わせて調整

### Git管理

移行されたファイルは通常、Gitで管理することを推奨します：

```bash
cd /path/to/target-project
git add .claude/ .cursor/ CLAUDE.md MCP_REFERENCE.md .cursorrules .mcp.json
git commit -m "chore: add DocDD development workflow configuration"
```

ただし、個人設定ファイル（`.claude/settings.local.json`）は `.gitignore` に追加することを推奨します。

## トラブルシューティング

### エラー: ターゲットディレクトリが存在しません

ターゲットプロジェクトのパスが正しいか確認してください。

```bash
# パスを確認
ls -la /path/to/target-project
```

### ダウンロードエラー

インターネット接続を確認し、GitHubにアクセスできるか確認してください。

```bash
# GitHubへの接続確認
curl -I https://raw.githubusercontent.com/imaimai17468/docdd/main/migrate.sh
```

## 詳細ドキュメント

- [CLAUDE.md](./CLAUDE.md) - 開発ワークフローの詳細
- [MCP_REFERENCE.md](./MCP_REFERENCE.md) - MCPコマンドリファレンス

## ライセンス

このプロジェクトの設定ファイルは、MITライセンスの下で公開されています。

詳細は [LICENSE](./LICENSE) ファイルを参照してください。
