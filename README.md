# DocDD (Documentation-Driven Development)

IDE非依存のLLM開発環境設定とワークフロー定義を提供するプロジェクトです。

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

# 既存ファイルを確認せずに上書き（--yes または -y オプション）
curl -fsSL https://raw.githubusercontent.com/imaimai17468/docdd/main/migrate.sh | bash -s -- --yes /path/to/target-project
```

### 別の実行方法

```bash
# プロセス置換方式（bash 4.0+）
bash <(curl -fsSL https://raw.githubusercontent.com/imaimai17468/docdd/main/migrate.sh) /path/to/target-project
```

## 移行されるファイル

### ルートレベル
- `WORKFLOW.md` - 開発ワークフローの定義（Phase 1-11）※IDE非依存
- `MCP_REFERENCE.md` - MCPコマンドの詳細リファレンス
- `.mcp.json` - MCP設定

### .llm/ ディレクトリ（LLM共通設定）
- `.llm/agents/*.md` - LLMエージェント定義（8種類）
  - `adr-memory-manager.md` - ADR記録管理
  - `app-code-specialist.md` - Reactコンポーネントリファクタリング
  - `e2e-test-executor.md` - E2Eテスト自動生成・実行 ⭐NEW
  - `project-onboarding.md` - プロジェクトオンボーディング
  - `spec-document-creator.md` - 仕様書作成
  - `storybook-story-creator.md` - Storybookストーリー作成
  - `test-guideline-enforcer.md` - 単体・コンポーネントテスト
  - `ui-design-advisor.md` - UI/UXデザインレビュー（Figma MCP対応） ⭐UPDATE
- `.llm/settings.json` - エージェント実行権限設定

### .ide/ ディレクトリ（IDE固有設定）
- `.ide/cursor/mcp.json` - Cursor MCP設定
- `.ide/cursor/.cursorrules` → `WORKFLOW.md`（シンボリックリンク）
- `.ide/cursor/settings.json` → `.llm/settings.json`（シンボリックリンク）
- `.ide/claude/.clauderc` → `WORKFLOW.md`（シンボリックリンク）
- `.ide/claude/settings.json` → `.llm/settings.json`（シンボリックリンク）

**注意**: CLI ツール（GitHub Copilot CLI、Gemini CLI など）は手動設定が必要です。詳細は下記「CLIツールでの使用方法」を参照してください。

## 開発ワークフローについて

このプロジェクトには、IDE非依存のLLM開発ワークフローが定義されています。`WORKFLOW.md`に詳細な手順が記載されています。Cursor、Claude、Copilot CLI、Gemini CLIなど、様々なAIツールで利用可能です。

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
  - Phase 6A: Unit/Component Tests（単体・コンポーネントテスト）
  - Phase 6B: E2E Tests（E2Eテスト）⭐NEW
  - Phase 6C: Storybook Stories（ストーリー作成）
- **Phase 7: Code Review** - リファクタリングが必要な場合
- **Phase 9B: Browser Verification** - 詳細な動作確認が必要な場合

詳細は [WORKFLOW.md](./WORKFLOW.md) を参照してください。

## MCP（Model Context Protocol）について

このプロジェクトでは、MCP（Model Context Protocol）を活用して開発効率を向上させています。MCPは、AIアシスタントが外部ツールやサービスと連携するためのプロトコルです。

### 使用するMCP

| MCP | 用途 | フェーズ |
|-----|------|---------|
| **Kiri MCP** | コードベース検索、コンテキスト抽出、依存関係分析 | Phase 1（調査） |
| **Serena MCP** | シンボルベース編集、リネーム、挿入・置換 | Phase 5（実装） |
| **Playwright MCP** ⭐NEW | E2Eテスト自動化、ブラウザ操作、スクリーンショット | Phase 6B（E2Eテスト） |
| **Figma MCP** ⭐NEW | Figmaデザイン取得、デザイントークン抽出 | Phase 3（UI/UXデザイン） |
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

#### Playwright MCP（E2Eテスト） ⭐NEW
- **E2Eテスト自動化**: 受け入れ条件からテストコード自動生成
- **ブラウザ操作**: ページ遷移、クリック、フォーム入力
- **スクリーンショット取得**: テスト失敗時の証跡保存
- **アサーション**: ページ表示やテキスト内容の検証

#### Figma MCP（UI/UXデザイン） ⭐NEW
- **デザイン取得**: Figmaファイルからデザイン仕様を取得
- **デザイントークン抽出**: 色、タイポグラフィ、スペーシングの抽出
- **デザイン実装**: Figmaデザイン通りのコード実装
- **デザイン差分確認**: 実装とFigmaデザインの比較（オプション）

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

移行先に既に同名のファイルが存在する場合の動作：

### 対話モード（標準入力がTTYの場合）

上書きするか確認されます：

```
警告: CLAUDE.md は既に存在します。上書きしますか？ (y/N)
```

- `y` または `Y` を入力: 上書き
- その他: スキップ

### 非対話モード（--yesオプション使用時）

`--yes`（または`-y`、`--force`、`-f`）オプションを使用すると、既存ファイルを確認せずに上書きします：

```bash
curl -fsSL https://raw.githubusercontent.com/imaimai17468/docdd/main/migrate.sh | bash -s -- --yes /path/to/target-project
```

**注意**: パイプ経由で実行しても、`--yes`オプションがない場合は対話的に確認されます。端末から`y`または`n`を入力してください。

## 注意事項

### ディレクトリ構造

新しいIDE非依存のディレクトリ構造を採用しています：

```
.llm/              # LLM共通設定（単一ソース）
├── agents/        # エージェント定義
└── settings.json  # 実行権限設定

.ide/              # IDE固有設定
├── cursor/        # Cursor設定（シンボリックリンク）
└── claude/        # Claude設定（シンボリックリンク）
```

シンボリックリンクにより、各IDE は共通の`WORKFLOW.md`と`settings.json`を参照します。

**注意**: CLI ツール（GitHub Copilot CLI、Gemini CLI など）は手動設定が必要です。詳細は「CLIツールでの使用方法」セクションを参照してください。

### CLIツールでの使用方法

CLI ツール（GitHub Copilot CLI、Gemini CLI など）はシンボリックリンクを直接参照できないため、**手動で設定ファイルをコピー**する必要があります。

#### 必要な設定ファイル

CLI ツールで DocDD を使用するには、以下のファイルを設定する必要があります：

| ファイル | 用途 | 必須/任意 |
|---------|------|-----------|
| `WORKFLOW.md` | 開発ワークフロー定義 | 必須 |
| `.llm/settings.json` | エージェント実行権限設定 | 推奨 |
| `.mcp.json` | MCP サーバー設定 | 推奨 |

---

#### 1. システムプロンプトの設定（WORKFLOW.md）

##### GitHub Copilot CLI の場合

```bash
# システムプロンプトディレクトリを作成
mkdir -p ~/.config/github-copilot

# WORKFLOW.mdをコピー
cp WORKFLOW.md ~/.config/github-copilot/instructions.md

# 確認
cat ~/.config/github-copilot/instructions.md | head -5
```

##### Gemini CLI の場合

```bash
# システムプロンプトディレクトリを作成
mkdir -p ~/.config/gemini-cli

# WORKFLOW.mdをコピー
cp WORKFLOW.md ~/.config/gemini-cli/system-prompt.md

# 確認
cat ~/.config/gemini-cli/system-prompt.md | head -5
```

##### その他の AI CLI ツール

各ツールのドキュメントを参照して、システムプロンプトの配置場所を確認してください：

```bash
# 1. ツールの設定ディレクトリを確認
# 2. WORKFLOW.mdをコピー
cp WORKFLOW.md <ツールの設定ディレクトリ>/

# 3. 確認
cat <ツールの設定ディレクトリ>/WORKFLOW.md | head -5
```

---

#### 2. エージェント実行権限の設定（settings.json）

CLI ツールでエージェントを使用する場合、実行権限を設定する必要があります。

```bash
# settings.json の内容を確認
cat .llm/settings.json

# 出力例:
# {
#   "permissions": {
#     "allow": [
#       "mcp__*",
#       "Bash(tree:*)",
#       "Bash(find:*)",
#       ...
#     ]
#   }
# }
```

**設定方法**（ツールによって異なります）:
- **GitHub Copilot CLI**: 現在 settings.json のサポートはありません（2024年12月時点）
- **Gemini CLI**: 各ツールのドキュメントを参照
- **その他**: ツール固有の権限設定方法を確認

---

#### 3. MCP 設定（.mcp.json）

CLI ツールで MCP を使用する場合、MCP サーバーの設定が必要です。

##### 3-1. プロジェクトパスの置換

`.mcp.json` には `{{PROJECT_PATH}}` というプレースホルダーが含まれています。
これを実際のプロジェクトパスに置換する必要があります。

**macOS/Linux:**
```bash
# プロジェクトパスを取得
PROJECT_PATH=$(pwd)

# プレースホルダーを置換（Linux）
sed -i.bak "s|{{PROJECT_PATH}}|$PROJECT_PATH|g" .mcp.json

# プレースホルダーを置換（macOS）
sed -i '' "s|{{PROJECT_PATH}}|$PROJECT_PATH|g" .mcp.json
```

**Windows (PowerShell):**
```powershell
# プロジェクトパスを取得
$PROJECT_PATH = (Get-Location).Path

# プレースホルダーを置換
(Get-Content .mcp.json) -replace '{{PROJECT_PATH}}', $PROJECT_PATH | Set-Content .mcp.json
```

##### 3-2. CLI ツール固有の MCP 設定

以下 CLI ツールの MCP 設定方法(copilot CLI例)：

**GitHub Copilot CLI:**
```bash
vim $HOME/.copilot/mcp-config.json
# 公式ドキュメントの案内に沿って設定

```


---

#### 4. 更新時の手順

WORKFLOW.md や設定を更新した場合、**再度手動でコピー**する必要があります。

```bash
# WORKFLOW.md を更新した場合
cp WORKFLOW.md ~/.config/github-copilot/instructions.md

# settings.json を更新した場合（該当ツールのみ）
cp .llm/settings.json <ツールの設定ディレクトリ>/

# .mcp.json を更新した場合
sed -i '' "s|{{PROJECT_PATH}}|$(pwd)|g" .mcp.json
cp .mcp.json <ツールの設定ディレクトリ>/
```

---

#### ⚠️ 注意事項

- **自動同期なし**: CLI ツールでは、ファイルを更新するたびに手動でコピーが必要
- **プレースホルダー置換**: `.mcp.json` の `{{PROJECT_PATH}}` は必ず置換すること
- **ツール依存**: 各 CLI ツールのドキュメントを確認して正しい配置場所を確認
- **権限設定**: settings.json のサポート有無はツールによって異なる

---

#### 推奨: IDE ツールの使用

CLI ツールは手動設定が必要なため、以下の IDE ツールの使用を推奨します：

| ツール | シンボリックリンク | 自動同期 | MCP サポート |
|--------|-------------------|----------|--------------|
| **Cursor** | ✅ | ✅ | ✅ |
| **Claude Desktop** | ✅ | ✅ | ✅ |
| GitHub Copilot CLI | ❌ | ❌ | ❌ |
| Gemini CLI | ❌ | ❌ | △ |

IDE ツールを使用すれば、シンボリックリンクによる自動同期で、設定ファイルのコピーが不要になります。

### プロジェクト固有の設定

移行後、以下の設定をプロジェクトに合わせて調整してください：

1. **MCP設定** (`.mcp.json`, `.ide/cursor/mcp.json`)
   - プロジェクト固有のMCPサーバー設定を確認

2. **エージェント実行権限** (`.llm/settings.json`)
   - プロジェクト固有の実行権限を確認

3. **ワークフロー定義** (`WORKFLOW.md`)
   - プロジェクトの技術スタックに合わせて調整

### Git管理

移行されたファイルは通常、Gitで管理することを推奨します：

```bash
cd /path/to/target-project
git add .llm/ .ide/ WORKFLOW.md MCP_REFERENCE.md .mcp.json
git commit -m "chore: add DocDD development workflow configuration (IDE-independent)"
```

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

- [WORKFLOW.md](./WORKFLOW.md) - 開発ワークフローの詳細（IDE非依存）
- [MCP_REFERENCE.md](./MCP_REFERENCE.md) - MCPコマンドリファレンス
- [docs/adr/](./docs/adr/) - アーキテクチャ決定記録（ADR）

## ライセンス

このプロジェクトの設定ファイルは、MITライセンスの下で公開されています。

詳細は [LICENSE](./LICENSE) ファイルを参照してください。
