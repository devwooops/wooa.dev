#!/bin/bash
# 새 블로그 포스트 생성 스크립트

# 사용법 체크
if [ -z "$1" ]; then
    echo "사용법: ./new-post.sh [포스트-제목-영문]"
    echo "예시: ./new-post.sh my-awesome-post"
    exit 1
fi

POST_SLUG="$1"
POST_DIR="content/posts/${POST_SLUG}"
POST_FILE="${POST_DIR}/index.md"

# 디렉토리 생성
mkdir -p "$POST_DIR"

# Front Matter 템플릿 생성
cat > "$POST_FILE" << 'EOF'
---
title: "포스트 제목을 여기에 작성"
date: $(date +%Y-%m-%dT%H:%M:%S+09:00)
draft: true
categories: ["카테고리1"]
tags: ["태그1", "태그2"]
summary: "포스트 요약을 여기에 작성하세요."
author: "Han Sangwoo"
ShowToc: true
TocOpen: false
---

## 서론

여기에 내용을 작성하세요...

## 본론

상세 내용...

## 결론

마무리 내용...

EOF

echo "✅ 새 포스트가 생성되었습니다: $POST_FILE"
echo "📝 편집 시작: nano $POST_FILE"
echo "🚀 로컬 미리보기: hugo server -D"
