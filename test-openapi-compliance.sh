#!/bin/bash
# OpenAPI仕様に基づくAPI動作確認スクリプト

BASE_URL="http://localhost:8000"
TEST_RESULTS_FILE="api-test-openapi-compliance.md"

echo "# OpenAPI仕様準拠テスト結果" > $TEST_RESULTS_FILE
echo "" >> $TEST_RESULTS_FILE
echo "テスト実施日時: $(date '+%Y-%m-%d %H:%M:%S')" >> $TEST_RESULTS_FILE
echo "ベースURL: $BASE_URL" >> $TEST_RESULTS_FILE
echo "" >> $TEST_RESULTS_FILE

# カラー出力
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

test_count=0
pass_count=0
fail_count=0

# テスト関数
test_api() {
    local test_name="$1"
    local method="$2"
    local endpoint="$3"
    local expected_status="$4"
    local curl_args="${5:-}"
    
    test_count=$((test_count + 1))
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Test #$test_count: $test_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # リクエスト実行
    echo "→ $method $endpoint"
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" "$BASE_URL$endpoint" $curl_args)
    elif [ "$method" = "POST" ]; then
        response=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL$endpoint" $curl_args)
    elif [ "$method" = "PUT" ]; then
        response=$(curl -s -w "\n%{http_code}" -X PUT "$BASE_URL$endpoint" $curl_args)
    elif [ "$method" = "PATCH" ]; then
        response=$(curl -s -w "\n%{http_code}" -X PATCH "$BASE_URL$endpoint" $curl_args)
    elif [ "$method" = "DELETE" ]; then
        response=$(curl -s -w "\n%{http_code}" -X DELETE "$BASE_URL$endpoint" $curl_args)
    fi
    
    # ステータスコードを分離
    status_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    # 結果判定
    if [ "$status_code" = "$expected_status" ]; then
        echo -e "${GREEN}✓ PASS${NC} - Status: $status_code (期待値: $expected_status)"
        pass_count=$((pass_count + 1))
        result="✅ PASS"
    else
        echo -e "${RED}✗ FAIL${NC} - Status: $status_code (期待値: $expected_status)"
        fail_count=$((fail_count + 1))
        result="❌ FAIL"
    fi
    
    # レスポンス表示（最初の200文字のみ）
    echo "Response: ${body:0:200}..."
    
    # マークダウンに記録
    echo "" >> $TEST_RESULTS_FILE
    echo "## Test #$test_count: $test_name" >> $TEST_RESULTS_FILE
    echo "" >> $TEST_RESULTS_FILE
    echo "**リクエスト:**" >> $TEST_RESULTS_FILE
    echo '```' >> $TEST_RESULTS_FILE
    echo "$method $endpoint" >> $TEST_RESULTS_FILE
    echo '```' >> $TEST_RESULTS_FILE
    echo "" >> $TEST_RESULTS_FILE
    echo "**期待ステータス:** $expected_status" >> $TEST_RESULTS_FILE
    echo "**実際のステータス:** $status_code" >> $TEST_RESULTS_FILE
    echo "**結果:** $result" >> $TEST_RESULTS_FILE
    echo "" >> $TEST_RESULTS_FILE
    
    if [ ${#body} -gt 0 ]; then
        echo "**レスポンス概要:**" >> $TEST_RESULTS_FILE
        echo '```json' >> $TEST_RESULTS_FILE
        echo "$body" | python3 -m json.tool 2>/dev/null | head -20 >> $TEST_RESULTS_FILE
        echo '```' >> $TEST_RESULTS_FILE
    fi
    
    sleep 0.5
}

echo ""
echo "========================================="
echo "  OpenAPI仕様準拠テスト開始"
echo "========================================="
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 1. GET /syllabi - シラバス一覧取得
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
test_api \
    "シラバス一覧取得" \
    "GET" \
    "/api/syllabi/" \
    "200"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 2. GET /syllabi/{id} - シラバス詳細取得（存在するID）
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
test_api \
    "シラバス詳細取得（ID=1）" \
    "GET" \
    "/api/syllabi/1/" \
    "200"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 3. GET /syllabi/{id} - シラバス詳細取得（存在しないID）
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
test_api \
    "シラバス詳細取得（存在しないID=999）" \
    "GET" \
    "/api/syllabi/999/" \
    "404"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 4. POST /syllabi - シラバス作成（認証なし - 失敗するべき）
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
test_api \
    "シラバス作成（認証なし）- 401期待" \
    "POST" \
    "/api/syllabi/" \
    "401" \
    '-H "Content-Type: application/json"'

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 5. PUT /syllabi/{id} - シラバス更新（認証なし - 失敗するべき）
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
test_api \
    "シラバス更新（認証なし）- 401期待" \
    "PUT" \
    "/api/syllabi/1/" \
    "401" \
    '-H "Content-Type: application/json"'

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 6. DELETE /syllabi/{id} - シラバス削除（認証なし - 失敗するべき）
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
test_api \
    "シラバス削除（認証なし）- 401期待" \
    "DELETE" \
    "/api/syllabi/1/" \
    "401"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 7. GET /syllabi - フィルタリング（academic_year）
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
test_api \
    "フィルタリング: academic_year=2025" \
    "GET" \
    "/api/syllabi/?academic_year=2025" \
    "200"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 8. GET /syllabi - フィルタリング（semester）
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
test_api \
    "フィルタリング: semester=後期" \
    "GET" \
    "/api/syllabi/?semester=後期" \
    "200"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 9. GET /syllabi - 検索（search）
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
test_api \
    "検索: search=Django" \
    "GET" \
    "/api/syllabi/?search=Django" \
    "200"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 10. GET /syllabi - ページネーション
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
test_api \
    "ページネーション: page=1" \
    "GET" \
    "/api/syllabi/?page=1" \
    "200"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 結果サマリー
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo ""
echo "========================================="
echo "  テスト結果サマリー"
echo "========================================="
echo "総テスト数: $test_count"
echo -e "${GREEN}成功: $pass_count${NC}"
echo -e "${RED}失敗: $fail_count${NC}"
echo ""

if [ $fail_count -eq 0 ]; then
    echo -e "${GREEN}✓ すべてのテストに合格しました！${NC}"
    exit_code=0
else
    echo -e "${RED}✗ 一部のテストが失敗しました${NC}"
    exit_code=1
fi

# マークダウンにサマリーを追加
echo "" >> $TEST_RESULTS_FILE
echo "## テスト結果サマリー" >> $TEST_RESULTS_FILE
echo "" >> $TEST_RESULTS_FILE
echo "- 総テスト数: $test_count" >> $TEST_RESULTS_FILE
echo "- ✅ 成功: $pass_count" >> $TEST_RESULTS_FILE
echo "- ❌ 失敗: $fail_count" >> $TEST_RESULTS_FILE
echo "" >> $TEST_RESULTS_FILE

if [ $fail_count -eq 0 ]; then
    echo "**結果: ✅ すべてのテストに合格**" >> $TEST_RESULTS_FILE
else
    echo "**結果: ❌ 一部のテストが失敗**" >> $TEST_RESULTS_FILE
fi

echo ""
echo "詳細なテスト結果は $TEST_RESULTS_FILE に保存されました"
echo ""

exit $exit_code
