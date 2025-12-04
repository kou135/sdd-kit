#!/bin/bash

# DocDDプロジェクトの設定ファイルを別プロジェクトに移行するスクリプト（IDE非依存版）
# 使用方法: curl -fsSL https://raw.githubusercontent.com/imaimai17468/docdd/main/migrate.sh | bash -s -- <ターゲットプロジェクトのパス>
# または: bash <(curl -fsSL https://raw.githubusercontent.com/imaimai17468/docdd/main/migrate.sh) <ターゲットプロジェクトのパス>

set -e

# OS検出
detect_os() {
    case "$OSTYPE" in
        darwin*)  echo "macos" ;;
        linux*)   echo "linux" ;;
        msys*|cygwin*|win32) echo "windows" ;;
        *)        echo "unknown" ;;
    esac
}

OS_TYPE=$(detect_os)

# GitHubリポジトリ情報
REPO_OWNER="kou135"
REPO_NAME="SDD"
BRANCH="fix-agent-rules"
BASE_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}"

# カラー出力用
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 引数チェック
FORCE_OVERWRITE=false
TARGET_DIR=""

# 引数を解析
while [[ $# -gt 0 ]]; do
    case $1 in
        --yes|-y|--force|-f)
            FORCE_OVERWRITE=true
            shift
            ;;
        *)
            if [ -z "$TARGET_DIR" ]; then
                TARGET_DIR="$1"
            fi
            shift
            ;;
    esac
done

if [ -z "$TARGET_DIR" ]; then
    echo -e "${RED}エラー: ターゲットプロジェクトのパスを指定してください${NC}"
    echo ""
    echo "使用方法:"
    echo "  curl -fsSL https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}/migrate.sh | bash -s -- <ターゲットプロジェクトのパス>"
    echo "  または"
    echo "  bash <(curl -fsSL https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}/migrate.sh) <ターゲットプロジェクトのパス>"
    echo ""
    echo "オプション:"
    echo "  --yes, -y, --force, -f  既存ファイルを確認せずに上書き"
    echo ""
    echo "例:"
    echo "  curl -fsSL https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}/migrate.sh | bash -s -- /path/to/target-project"
    echo "  curl -fsSL https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}/migrate.sh | bash -s -- --yes /path/to/target-project"
    exit 1
fi

# ターゲットディレクトリの存在確認
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}エラー: ターゲットディレクトリが存在しません: $TARGET_DIR${NC}"
    exit 1
fi

# 絶対パスに変換
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

echo -e "${BLUE}SDD設定ファイルの移行を開始します${NC}"
echo -e "${BLUE}リポジトリ: https://github.com/${REPO_OWNER}/${REPO_NAME}${NC}"
echo -e "${BLUE}ターゲット: $TARGET_DIR${NC}"
echo -e "${BLUE}OS: $OS_TYPE${NC}"
echo ""

# 一時ディレクトリを作成
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo -e "${YELLOW}ファイルをダウンロード中...${NC}"

# ダウンロード関数
download_file() {
    local file_path="$1"
    local target_path="$2"
    local url="${BASE_URL}/${file_path}"

    echo -n "  ${file_path} ... "

    if curl -fsSL "$url" -o "$target_path" 2>/dev/null; then
        echo -e "${GREEN}✓${NC}"
        return 0
    else
        echo -e "${RED}✗${NC}"
        return 1
    fi
}

# ルートレベルのファイル
ROOT_FILES=(
    "WORKFLOW.md"
    "MCP_REFERENCE.md"
    ".mcp.json"
)

# .llm/agents/ のファイル
LLM_AGENTS=(
    "adr-memory-manager.md"
    "app-code-specialist.md"
    "project-onboarding.md"
    "spec-document-creator.md"
    "storybook-story-creator.md"
    "test-guideline-enforcer.md"
    "ui-design-advisor.md"
)

# プレースホルダー置換関数
replace_placeholders() {
    local file="$1"
    if [ -f "$file" ]; then
        # macOSとLinuxの両方で動作するsedコマンド
        if [[ "$OS_TYPE" == "macos" ]]; then
            sed -i '' "s|{{PROJECT_PATH}}|$TARGET_DIR|g" "$file"
        else
            sed -i "s|{{PROJECT_PATH}}|$TARGET_DIR|g" "$file"
        fi
    fi
}

# 既存ファイルの上書き確認関数
should_overwrite() {
    local file_path="$1"
    if [ "$FORCE_OVERWRITE" = true ]; then
        return 0  # 上書きする
    fi

    # 対話的に確認（/dev/ttyを使用して端末から直接入力を受け取る）
    echo -e "    ${YELLOW}警告: $file_path は既に存在します。上書きしますか？ (y/N)${NC}" >&2
    read -r response < /dev/tty
    if [[ "$response" =~ ^[Yy]$ ]]; then
        return 0  # 上書きする
    else
        return 1  # スキップする
    fi
}

# ルートレベルのファイルをダウンロード
echo -e "${YELLOW}ルートレベルのファイル:${NC}"
for file in "${ROOT_FILES[@]}"; do
    temp_file="$TEMP_DIR/$file"
    if download_file "$file" "$temp_file"; then
        # 既存ファイルの確認
        target_file="$TARGET_DIR/$file"
        if [ -f "$target_file" ]; then
            if [ "$FORCE_OVERWRITE" = true ]; then
                echo -e "    ${YELLOW}既存ファイルを上書き: $file${NC}"
            else
                if ! should_overwrite "$file"; then
                    echo "    スキップ: $file"
                    continue
                fi
            fi
        fi

        # ディレクトリが存在しない場合は作成
        target_dir=$(dirname "$target_file")
        mkdir -p "$target_dir"

        cp "$temp_file" "$target_file"
        # プレースホルダーを置換（.mcp.jsonの場合）
        if [ "$file" = ".mcp.json" ]; then
            replace_placeholders "$target_file"
        fi
        echo -e "    ${GREEN}コピー完了: $file${NC}"
    fi
done

# .llm/agents/ のファイルをダウンロード
echo ""
echo -e "${YELLOW}.llm/agents/ のファイル:${NC}"
mkdir -p "$TARGET_DIR/.llm/agents"
for file in "${LLM_AGENTS[@]}"; do
    temp_file="$TEMP_DIR/$file"
    if download_file ".llm/agents/$file" "$temp_file"; then
        target_file="$TARGET_DIR/.llm/agents/$file"

        if [ -f "$target_file" ]; then
            if [ "$FORCE_OVERWRITE" = true ]; then
                echo -e "    ${YELLOW}既存ファイルを上書き: .llm/agents/$file${NC}"
            else
                if ! should_overwrite ".llm/agents/$file"; then
                    echo "    スキップ: .llm/agents/$file"
                    continue
                fi
            fi
        fi

        cp "$temp_file" "$target_file"
        echo -e "    ${GREEN}コピー完了: .llm/agents/$file${NC}"
    fi
done

# .llm/settings.json をダウンロード
echo ""
echo -e "${YELLOW}.llm/settings.json:${NC}"
temp_file="$TEMP_DIR/llm-settings.json"
if download_file ".llm/settings.json" "$temp_file"; then
    target_file="$TARGET_DIR/.llm/settings.json"

    if [ -f "$target_file" ]; then
        if [ "$FORCE_OVERWRITE" = true ]; then
            echo -e "    ${YELLOW}既存ファイルを上書き: .llm/settings.json${NC}"
            mkdir -p "$(dirname "$target_file")"
            cp "$temp_file" "$target_file"
            echo -e "    ${GREEN}コピー完了: .llm/settings.json${NC}"
        else
            if should_overwrite ".llm/settings.json"; then
                mkdir -p "$(dirname "$target_file")"
                cp "$temp_file" "$target_file"
                echo -e "    ${GREEN}コピー完了: .llm/settings.json${NC}"
            else
                echo "    スキップ: .llm/settings.json"
            fi
        fi
    else
        mkdir -p "$(dirname "$target_file")"
        cp "$temp_file" "$target_file"
        echo -e "    ${GREEN}コピー完了: .llm/settings.json${NC}"
    fi
fi

# .ide/cursor/mcp.json をダウンロード
echo ""
echo -e "${YELLOW}.ide/cursor/mcp.json:${NC}"
temp_file="$TEMP_DIR/cursor-mcp.json"
if download_file ".ide/cursor/mcp.json" "$temp_file"; then
    target_file="$TARGET_DIR/.ide/cursor/mcp.json"

    if [ -f "$target_file" ]; then
        if [ "$FORCE_OVERWRITE" = true ]; then
            echo -e "    ${YELLOW}既存ファイルを上書き: .ide/cursor/mcp.json${NC}"
            mkdir -p "$(dirname "$target_file")"
            cp "$temp_file" "$target_file"
            replace_placeholders "$target_file"
            echo -e "    ${GREEN}コピー完了: .ide/cursor/mcp.json${NC}"
        else
            if should_overwrite ".ide/cursor/mcp.json"; then
                mkdir -p "$(dirname "$target_file")"
                cp "$temp_file" "$target_file"
                replace_placeholders "$target_file"
                echo -e "    ${GREEN}コピー完了: .ide/cursor/mcp.json${NC}"
            else
                echo "    スキップ: .ide/cursor/mcp.json"
            fi
        fi
    else
        mkdir -p "$(dirname "$target_file")"
        cp "$temp_file" "$target_file"
        replace_placeholders "$target_file"
        echo -e "    ${GREEN}コピー完了: .ide/cursor/mcp.json${NC}"
    fi
fi

# シンボリックリンク作成
echo ""
echo -e "${YELLOW}シンボリックリンクを作成中...${NC}"

# Windows環境のチェック
if [[ "$OS_TYPE" == "windows" ]]; then
    echo -e "${YELLOW}注意: Windows環境ではシンボリックリンクの作成に管理者権限が必要な場合があります${NC}"
fi

# .ide/ ディレクトリ作成
mkdir -p "$TARGET_DIR/.ide/cursor"
mkdir -p "$TARGET_DIR/.ide/claude"

# Cursorのシンボリックリンク
cd "$TARGET_DIR/.ide/cursor"
ln -sf ../../WORKFLOW.md .cursorrules 2>/dev/null && echo -e "  ${GREEN}✓${NC} .ide/cursor/.cursorrules -> WORKFLOW.md" || echo -e "  ${RED}✗${NC} .ide/cursor/.cursorrules (failed)"
ln -sf ../../.llm/settings.json settings.json 2>/dev/null && echo -e "  ${GREEN}✓${NC} .ide/cursor/settings.json -> .llm/settings.json" || echo -e "  ${RED}✗${NC} .ide/cursor/settings.json (failed)"

# Claudeのシンボリックリンク
cd "$TARGET_DIR/.ide/claude"
ln -sf ../../WORKFLOW.md .clauderc 2>/dev/null && echo -e "  ${GREEN}✓${NC} .ide/claude/.clauderc -> WORKFLOW.md" || echo -e "  ${RED}✗${NC} .ide/claude/.clauderc (failed)"
ln -sf ../../.llm/settings.json settings.json 2>/dev/null && echo -e "  ${GREEN}✓${NC} .ide/claude/settings.json -> .llm/settings.json" || echo -e "  ${RED}✗${NC} .ide/claude/settings.json (failed)"

cd "$TARGET_DIR"

echo ""
echo -e "${GREEN}移行が完了しました！${NC}"
echo ""
echo "移行されたファイル:"
echo "  - WORKFLOW.md (開発ワークフロー定義 - IDE非依存)"
echo "  - MCP_REFERENCE.md (MCPコマンドリファレンス)"
echo "  - .mcp.json (MCP設定)"
echo "  - .llm/agents/*.md (LLMエージェント定義)"
echo "  - .llm/settings.json (エージェント実行権限設定)"
echo "  - .ide/cursor/mcp.json (Cursor MCP設定)"
echo ""
echo "作成されたシンボリックリンク:"
echo "  - .ide/cursor/.cursorrules -> WORKFLOW.md"
echo "  - .ide/cursor/settings.json -> .llm/settings.json"
echo "  - .ide/claude/.clauderc -> WORKFLOW.md"
echo "  - .ide/claude/settings.json -> .llm/settings.json"
echo ""
echo "ディレクトリ構造:"
echo "  .llm/              # LLM共通設定"
echo "    ├── agents/      # エージェント定義（単一ソース）"
echo "    └── settings.json # 実行権限設定（単一ソース）"
echo "  .ide/              # IDE固有設定"
echo "    ├── cursor/      # Cursor設定（シンボリックリンク）"
echo "    └── claude/      # Claude設定（シンボリックリンク）"
echo ""
echo "次のステップ:"
echo "  1. ターゲットプロジェクトで設定を確認してください"
echo "  2. 必要に応じて設定をカスタマイズしてください"
echo "  3. WORKFLOW.mdを参照して開発ワークフローを確認してください"
echo ""
echo -e "${YELLOW}CLIツール（GitHub Copilot CLI、Gemini CLI など）を使用する場合:${NC}"
echo "  CLIツールはシンボリックリンクを直接参照できないため、手動設定が必要です。"
echo "  詳細は README.md の「CLIツールでの使用方法」セクションを参照してください。"
echo ""
echo "  設定が必要なファイル:"
echo "    - WORKFLOW.md（開発ワークフロー）"
echo "    - .llm/settings.json（エージェント実行権限）"
echo "    - .mcp.json（MCP設定）"
