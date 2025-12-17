#!/bin/bash

# OpenAPI仕様に基づくSyllabus APIテストスクリプト
# Usage: ./test_api_full.sh

set -e

# カラー設定
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ベースURL (実装に合わせて /api/syllabi に修正)
BASE_URL="http://localhost:8000/api/syllabi"

# 結果を格納する変数
PASSED=0
FAILED=0

echo "=================================================================="
echo "OpenAPI仕様に基づく Syllabus API テスト"
echo "=================================================================="
echo ""
echo "ベースURL: $BASE_URL"
echo "テスト開始: $(date)"
echo ""

# ヘルパー関数: HTTPステータスコードのチェック
check_status() {
    local expected=$1
    local actual=$2
    local test_name=$3
    
    if [ "$expected" = "$actual" ]; then
        echo -e "${GREEN}✓${NC} $test_name - ステータス: $actual"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $test_name - 期待値: $expected, 実際: $actual"
        ((FAILED++))
        return 1
    fi
}

# ヘルパー関数: JSONフィールドの存在チェック
check_field() {
    local json=$1
    local field=$2
    local test_name=$3
    
    if echo "$json" | python3 -c "import sys, json; data=json.load(sys.stdin); sys.exit(0 if '$field' in data else 1)" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} $test_name - フィールド '$field' が存在"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $test_name - フィールド '$field' が存在しません"
        ((FAILED++))
        return 1
    fi
}

echo "=================================================================="
echo "テスト 1: GET /syllabi/ - シラバス一覧取得"
echo "=================================================================="
RESPONSE=$(curl -s -w "\n%{http_code}" "$BASE_URL/")
BODY=$(echo "$RESPONSE" | sed '$d')
STATUS=$(echo "$RESPONSE" | tail -n 1)

check_status "200" "$STATUS" "GET /syllabi/"
if [ "$STATUS" = "200" ]; then
    echo "$BODY" | python3 -m json.tool > /tmp/test1.json 2>/dev/null || echo "$BODY" > /tmp/test1.json
    echo "レスポンス例 (最初の20行):"
    cat /tmp/test1.json | head -20
fi
echo ""

echo "=================================================================="
echo "テスト 2: POST /syllabi/ - シラバス新規登録"
echo "=================================================================="
# 実装のフィールド名に合わせる
PAYLOAD='{
  "subject_name": "テスト用科目",
  "regulation_subject_name": "学則テスト科目",
  "teacher_name": "テスト教員",
  "instructor_type": "実務教員",
  "teaching_method": "講義&演習",
  "num_sessions": 30,
  "recommended_grade": "2年～",
  "enrollment_classification": "必修選択",
  "academic_year": 2025,
  "semester": "後期",
  "eligible_departments": ["高度情報工学科", "情報システム科"],
  "course_overview": "これはテスト用のシラバスです。"
}'

RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD")
BODY=$(echo "$RESPONSE" | sed '$d')
STATUS=$(echo "$RESPONSE" | tail -n 1)

# 認証が必要なので401が返る
check_status "401" "$STATUS" "POST /syllabi/ (認証なし)"
echo "Note: 認証なしのため401が返されます（期待通り）"
echo ""

echo "=================================================================="
echo "テスト 3: GET /syllabi/{id}/ - シラバス詳細取得"
echo "=================================================================="
# 既存のID=1を使用
CREATED_ID=1
RESPONSE=$(curl -s -w "\n%{http_code}" "$BASE_URL/$CREATED_ID/")
BODY=$(echo "$RESPONSE" | sed '$d')
STATUS=$(echo "$RESPONSE" | tail -n 1)

check_status "200" "$STATUS" "GET /syllabi/$CREATED_ID/"
if [ "$STATUS" = "200" ]; then
    echo "$BODY" | python3 -m json.tool > /tmp/test3.json 2>/dev/null || echo "$BODY" > /tmp/test3.json
    check_field "$BODY" "id" "GET /syllabi/{id}/ レスポンス"
    check_field "$BODY" "subject_name" "GET /syllabi/{id}/ レスポンス"
    check_field "$BODY" "class_sessions" "GET /syllabi/{id}/ レスポンス"
    echo "レスポンス例 (最初の30行):"
    cat /tmp/test3.json | head -30
fi
echo ""

echo "=================================================================="
echo "テスト 4: PUT /syllabi/{id}/ - シラバス全更新"
echo "=================================================================="
PAYLOAD='{
  "subject_name": "更新後のテスト科目"
}'

RESPONSE=$(curl -s -w "\n%{http_code}" -X PUT "$BASE_URL/$CREATED_ID/" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD")
BODY=$(echo "$RESPONSE" | sed '$d')
STATUS=$(echo "$RESPONSE" | tail -n 1)

# 認証が必要なので401が返る
check_status "401" "$STATUS" "PUT /syllabi/$CREATED_ID/ (認証なし)"
echo "Note: 認証なしのため401が返されます（期待通り）"
echo ""

echo "=================================================================="
echo "テスト 5: PATCH /syllabi/{id}/ - シラバス部分更新"
echo "=================================================================="
PAYLOAD='{
  "subject_name": "部分更新後のテスト科目"
}'

RESPONSE=$(curl -s -w "\n%{http_code}" -X PATCH "$BASE_URL/$CREATED_ID/" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD")
BODY=$(echo "$RESPONSE" | sed '$d')
STATUS=$(echo "$RESPONSE" | tail -n 1)

# 認証が必要なので401が返る
check_status "401" "$STATUS" "PATCH /syllabi/$CREATED_ID/ (認証なし)"
echo "Note: 認証なしのため401が返されます（期待通り）"
echo ""

echo "=================================================================="
echo "テスト 6: DELETE /syllabi/{id}/ - シラバス削除"
echo "=================================================================="
RESPONSE=$(curl -s -w "\n%{http_code}" -X DELETE "$BASE_URL/$CREATED_ID/")
BODY=$(echo "$RESPONSE" | sed '$d')
STATUS=$(echo "$RESPONSE" | tail -n 1)

# 認証が必要なので401が返る
check_status "401" "$STATUS" "DELETE /syllabi/$CREATED_ID/ (認証なし)"
echo "Note: 認証なしのため401が返されます（期待通り）"
echo ""

echo "=================================================================="
echo "テスト 7: GET /syllabi/99999/ - 存在しないID (404エラー期待)"
echo "=================================================================="
RESPONSE=$(curl -s -w "\n%{http_code}" "$BASE_URL/99999/")
STATUS=$(echo "$RESPONSE" | tail -n 1)

check_status "404" "$STATUS" "GET /syllabi/99999/"
echo ""

echo "=================================================================="
echo "テスト 8: POST /syllabi/ - 必須フィールド欠落 (401エラー期待)"
echo "=================================================================="
PAYLOAD='{
  "teacher_name": "教員名のみ"
}'

RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD")
STATUS=$(echo "$RESPONSE" | tail -n 1)

# 認証チェックが先なので401が返る
check_status "401" "$STATUS" "POST /syllabi/ (認証なし、必須フィールド欠落)"
echo "Note: 認証チェックが先に行われるため401が返されます"
echo ""

echo "=================================================================="
echo "テスト 9: GET /syllabi/?academic_year=2025 - フィルタリング"
echo "=================================================================="
RESPONSE=$(curl -s -w "\n%{http_code}" "$BASE_URL/?academic_year=2025")
BODY=$(echo "$RESPONSE" | sed '$d')
STATUS=$(echo "$RESPONSE" | tail -n 1)

check_status "200" "$STATUS" "GET /syllabi/?academic_year=2025"
if [ "$STATUS" = "200" ]; then
    COUNT=$(echo "$BODY" | python3 -c "import sys, json; print(json.load(sys.stdin)['count'])" 2>/dev/null)
    echo "フィルタ結果: $COUNT 件"
fi
echo ""

echo "=================================================================="
echo "テスト 10: GET /syllabi/?search=Django - 検索"
echo "=================================================================="
RESPONSE=$(curl -s -w "\n%{http_code}" "$BASE_URL/?search=Django")
BODY=$(echo "$RESPONSE" | sed '$d')
STATUS=$(echo "$RESPONSE" | tail -n 1)

check_status "200" "$STATUS" "GET /syllabi/?search=Django"
if [ "$STATUS" = "200" ]; then
    COUNT=$(echo "$BODY" | python3 -c "import sys, json; print(json.load(sys.stdin)['count'])" 2>/dev/null)
    echo "検索結果: $COUNT 件"
fi
echo ""

echo "=================================================================="
echo "テスト結果サマリー"
echo "=================================================================="
TOTAL=$((PASSED + FAILED))
echo -e "合計テスト数: $TOTAL"
echo -e "${GREEN}成功: $PASSED${NC}"
echo -e "${RED}失敗: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ 全てのテストが成功しました！${NC}"
    exit 0
else
    echo -e "${RED}✗ いくつかのテストが失敗しました${NC}"
    exit 1
fi
