---
title: "PaperMod에서 Hugo Book 테마로 전환하기"
weight: 2
bookToc: true
---

## TL;DR

- Book은 **문서(사이드바/목차) 중심 테마**라서 PaperMod와 성격이 다름
- 테마만 바꾸면 끝나는 게 아니라 **content 구조를 docs 중심으로 재정렬**하는 것이 정석
- Cloudflare Pages는 그대로 사용 가능 (빌드: `hugo --minify`, output: `public`)
- 테마를 submodule로 넣었다면 Cloudflare Pages에서 **Git submodules ON** 필요

---

## 1) Hugo Book 테마 설치 (권장: git submodule)

프로젝트 루트( `hugo.toml` 있는 위치 )에서:

```bash
git submodule add https://github.com/alex-shpak/hugo-book themes/hugo-book
git submodule update --init --recursive
```

커밋:

```bash
git add -A
git commit -m "Add Hugo Book theme"
```

> Cloudflare Pages 사용 시: Pages 프로젝트 설정에서 **Git submodules = ON**

---

## 2) hugo.toml 변경 (PaperMod → Book)

기존:

```toml
theme = "PaperMod"
```

변경:

```toml
theme = "hugo-book"
```

### Book용 권장 설정 (바로 사용 가능)

```toml
baseURL = "https://wooa.dev/"
languageCode = "ko-kr"
title = "WOOA.DEV"
theme = "hugo-book"

enableRobotsTXT = true

[params]
  BookTheme = "auto"          # auto | light | dark
  BookToC = true
  BookSection = "docs"        # 문서 루트 섹션
  BookRepo = "https://github.com/devwooops/wooa.dev"  # (선택) repo 링크
  BookEditPath = "edit/main"  # (선택) Edit this page 링크
```

---

## 3) 가장 중요한 변화: 콘텐츠 구조를 "docs" 중심으로

Book은 기본적으로 **문서 섹션**을 중심으로 사이드바 네비게이션을 만듭니다.

권장 구조:

```text
content/
  docs/
    _index.md
    intro/
      _index.md
      install.md
    hugo/
      _index.md
      cloudflare-pages.md
```

* 폴더의 `_index.md`는 섹션(목차) 역할
* 일반 `*.md`는 실제 문서 페이지

### 빠르게 시작용 파일 생성

```bash
hugo new docs/_index.md
hugo new docs/intro/_index.md
hugo new docs/intro/install.md
```

---

## 4) 사이드바(목차) 정렬: weight 사용

예: `content/docs/_index.md`

```md
---
title: "Docs"
weight: 1
---

문서 루트입니다.
```

예: `content/docs/intro/_index.md`

```md
---
title: "Getting Started"
weight: 1
---
```

* `weight`가 낮을수록 상단에 위치

---

## 5) PaperMod 커스터마이징에서 정리해야 할 것

PaperMod에서 적용했던 설정/커스터마이징은 Book에 그대로 적용되지 않는 경우가 많습니다.

### 점검 목록

* `assets/css/extended/` : PaperMod 전용 방식일 수 있음 → Book 방식으로 재설계 필요
* PaperMod 전용 params (`ShowToc`, `ShowCodeCopyButtons` 등) → Book에서 의미 없음
* `cover:` 기반 대표 이미지 흐름 → Book은 문서형이라 처리 방식 다름

👉 가능하면 **테마 파일 직접 수정 없이**, 오버라이드 방식으로 조정하는 것을 권장

---

## 6) Cloudflare Pages 배포 설정 (그대로 유지)

* **Build command**: `hugo --minify`
* **Build output directory**: `public`
* **Production branch**: `main`
* **Git submodules**: (테마가 submodule이면) **ON**

---

## 7) 전환 후 확인 체크리스트

### 로컬 실행

```bash
hugo server -D
```

브라우저에서 `http://localhost:1313` 접속하여:

- 사이드바 네비게이션이 정상적으로 표시되는지
- 문서 페이지가 올바르게 렌더링되는지
- 목차(ToC)가 작동하는지 확인

### 빌드 테스트

```bash
hugo --minify
```

에러 없이 빌드되는지 확인
