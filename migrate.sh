#!/bin/bash

# DocDDプロジェクトの設定ファイルを別プロジェクトに移行するスクリプト
# 使用方法: curl -fsSL https://raw.githubusercontent.com/imaimai17468/docdd/main/migrate.sh | bash -s -- <ターゲットプロジェクトのパス>
# または: bash <(curl -fsSL https://raw.githubusercontent.com/imaimai17468/docdd/main/migrate.sh) <ターゲットプロジェクトのパス>

set -e

# GitHubリポジトリ情報
REPO_OWNER="imaimai17468"
REPO_NAME="docdd"
BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}"

# カラー出力用
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 引数チェック
if [ $# -eq 0 ]; then
    echo -e "${RED}エラー: ターゲットプロジェクトのパスを指定してください${NC}"
    echo ""
    echo "使用方法:"
    echo "  curl -fsSL https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}/migrate.sh | bash -s -- <ターゲットプロジェクトのパス>"
    echo "  または"
    echo "  bash <(curl -fsSL https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}/migrate.sh) <ターゲットプロジェクトのパス>"
    echo ""
    echo "例:"
    echo "  curl -fsSL https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}/migrate.sh | bash -s -- /path/to/target-project"
    exit 1
fi

TARGET_DIR="$1"

# ターゲットディレクトリの存在確認
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}エラー: ターゲットディレクトリが存在しません: $TARGET_DIR${NC}"
    exit 1
fi

# 絶対パスに変換
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

echo -e "${BLUE}DocDD設定ファイルの移行を開始します${NC}"
echo -e "${BLUE}リポジトリ: https://github.com/${REPO_OWNER}/${REPO_NAME}${NC}"
echo -e "${BLUE}ターゲット: $TARGET_DIR${NC}"
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
    "CLAUDE.md"
    "MCP_REFERENCE.md"
    ".cursorrules"
    ".mcp.json"
)

# .claude/agents/ のファイル
CLAUDE_AGENTS=(
    "adr-memory-manager.md"
    "app-code-specialist.md"
    "project-onboarding.md"
    "spec-document-creator.md"
    "storybook-story-creator.md"
    "test-guideline-enforcer.md"
    "ui-design-advisor.md"
)

# .cursor/commands/ のファイル
CURSOR_COMMANDS=(
    "adr-memory-manager.md"
    "app-code-specialist.md"
    "project-onboarding.md"
    "spec-document-creator.md"
    "storybook-story-creator.md"
    "test-guideline-enforcer.md"
    "ui-design-advisor.md"
)

# ルートレベルのファイルをダウンロード
echo -e "${YELLOW}ルートレベルのファイル:${NC}"
for file in "${ROOT_FILES[@]}"; do
    temp_file="$TEMP_DIR/$file"
    if download_file "$file" "$temp_file"; then
        # 既存ファイルの確認
        target_file="$TARGET_DIR/$file"
        if [ -f "$target_file" ]; then
            echo -e "    ${YELLOW}警告: $file は既に存在します。上書きしますか？ (y/N)${NC}"
            read -r response
            if [[ ! "$response" =~ ^[Yy]$ ]]; then
                echo "    スキップ: $file"
                continue
            fi
        fi

        # ディレクトリが存在しない場合は作成
        target_dir=$(dirname "$target_file")
        mkdir -p "$target_dir"

        cp "$temp_file" "$target_file"
        echo -e "    ${GREEN}コピー完了: $file${NC}"
    fi
done

# .claude/agents/ のファイルをダウンロード
echo ""
echo -e "${YELLOW}.claude/agents/ のファイル:${NC}"
mkdir -p "$TARGET_DIR/.claude/agents"
for file in "${CLAUDE_AGENTS[@]}"; do
    temp_file="$TEMP_DIR/$file"
    if download_file ".claude/agents/$file" "$temp_file"; then
        target_file="$TARGET_DIR/.claude/agents/$file"

        if [ -f "$target_file" ]; then
            echo -e "    ${YELLOW}警告: .claude/agents/$file は既に存在します。上書きしますか？ (y/N)${NC}"
            read -r response
            if [[ ! "$response" =~ ^[Yy]$ ]]; then
                echo "    スキップ: .claude/agents/$file"
                continue
            fi
        fi

        cp "$temp_file" "$target_file"
        echo -e "    ${GREEN}コピー完了: .claude/agents/$file${NC}"
    fi
done

# .claude/settings.json をダウンロード
echo ""
echo -e "${YELLOW}.claude/settings.json:${NC}"
temp_file="$TEMP_DIR/.claude-settings.json"
if download_file ".claude/settings.json" "$temp_file"; then
    target_file="$TARGET_DIR/.claude/settings.json"

    if [ -f "$target_file" ]; then
        echo -e "    ${YELLOW}警告: .claude/settings.json は既に存在します。上書きしますか？ (y/N)${NC}"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo "    スキップ: .claude/settings.json"
        else
            mkdir -p "$(dirname "$target_file")"
            cp "$temp_file" "$target_file"
            echo -e "    ${GREEN}コピー完了: .claude/settings.json${NC}"
        fi
    else
        mkdir -p "$(dirname "$target_file")"
        cp "$temp_file" "$target_file"
        echo -e "    ${GREEN}コピー完了: .claude/settings.json${NC}"
    fi
fi

# .cursor/commands/ のファイルをダウンロード
echo ""
echo -e "${YELLOW}.cursor/commands/ のファイル:${NC}"
mkdir -p "$TARGET_DIR/.cursor/commands"
for file in "${CURSOR_COMMANDS[@]}"; do
    temp_file="$TEMP_DIR/$file"
    if download_file ".cursor/commands/$file" "$temp_file"; then
        target_file="$TARGET_DIR/.cursor/commands/$file"

        if [ -f "$target_file" ]; then
            echo -e "    ${YELLOW}警告: .cursor/commands/$file は既に存在します。上書きしますか？ (y/N)${NC}"
            read -r response
            if [[ ! "$response" =~ ^[Yy]$ ]]; then
                echo "    スキップ: .cursor/commands/$file"
                continue
            fi
        fi

        cp "$temp_file" "$target_file"
        echo -e "    ${GREEN}コピー完了: .cursor/commands/$file${NC}"
    fi
done

# .cursor/mcp.json をダウンロード
echo ""
echo -e "${YELLOW}.cursor/mcp.json:${NC}"
temp_file="$TEMP_DIR/.cursor-mcp.json"
if download_file ".cursor/mcp.json" "$temp_file"; then
    target_file="$TARGET_DIR/.cursor/mcp.json"

    if [ -f "$target_file" ]; then
        echo -e "    ${YELLOW}警告: .cursor/mcp.json は既に存在します。上書きしますか？ (y/N)${NC}"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo "    スキップ: .cursor/mcp.json"
        else
            mkdir -p "$(dirname "$target_file")"
            cp "$temp_file" "$target_file"
            echo -e "    ${GREEN}コピー完了: .cursor/mcp.json${NC}"
        fi
    else
        mkdir -p "$(dirname "$target_file")"
        cp "$temp_file" "$target_file"
        echo -e "    ${GREEN}コピー完了: .cursor/mcp.json${NC}"
    fi
fi

# .cursor/settings.json をダウンロード
echo ""
echo -e "${YELLOW}.cursor/settings.json:${NC}"
temp_file="$TEMP_DIR/.cursor-settings.json"
if download_file ".cursor/settings.json" "$temp_file"; then
    target_file="$TARGET_DIR/.cursor/settings.json"

    if [ -f "$target_file" ]; then
        echo -e "    ${YELLOW}警告: .cursor/settings.json は既に存在します。上書きしますか？ (y/N)${NC}"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo "    スキップ: .cursor/settings.json"
        else
            mkdir -p "$(dirname "$target_file")"
            cp "$temp_file" "$target_file"
            echo -e "    ${GREEN}コピー完了: .cursor/settings.json${NC}"
        fi
    else
        mkdir -p "$(dirname "$target_file")"
        cp "$temp_file" "$target_file"
        echo -e "    ${GREEN}コピー完了: .cursor/settings.json${NC}"
    fi
fi

echo ""
echo -e "${GREEN}移行が完了しました！${NC}"
echo ""
echo "移行されたファイル:"
echo "  - CLAUDE.md (開発ワークフロー定義)"
echo "  - MCP_REFERENCE.md (MCPコマンドリファレンス)"
echo "  - .cursorrules (Cursor設定)"
echo "  - .mcp.json (MCP設定)"
echo "  - .claude/agents/*.md (Claudeエージェント定義)"
echo "  - .claude/settings.json (Claude設定)"
echo "  - .cursor/commands/*.md (Cursorコマンド定義)"
echo "  - .cursor/mcp.json (Cursor MCP設定)"
echo "  - .cursor/settings.json (Cursor設定)"
echo ""
echo "次のステップ:"
echo "  1. ターゲットプロジェクトで設定を確認してください"
echo "  2. 必要に応じて設定をカスタマイズしてください"
echo "  3. .claude/settings.local.json は個人設定なので、各自で設定してください"
