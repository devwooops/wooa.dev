---
title: "Hugo + Cloudflare Pages로 기술 블로그 만들기"
weight: 1
bookToc: true
---

## TL;DR

- **Hugo**: Go 기반 초고속 정적 사이트 생성기
- **Cloudflare Pages**: Git 연동 자동 빌드/배포 + 글로벌 CDN
- 서버·DB·보안 패치 없이 **무료로 고성능 블로그 운영**
- 마크다운으로 글 쓰고, Git으로 푸시하면 끝
- 이미지가 많은 기술 블로그에 특히 적합

---

## 왜 Hugo + Cloudflare Pages를 선택했는가

기술 블로그를 운영하면서 항상 고민되는 부분들이 있다.

- ❌ 서버 관리하고 싶지 않다
- ❌ WordPress 같은 무거운 CMS는 부담스럽다
- ✅ 마크다운으로 편하게 글을 쓰고 싶다
- ✅ 이미지와 코드 블록이 많아도 빠르게 로딩되어야 한다
- ✅ 나중에 플랫폼 이전이 쉬워야 한다 (종속성 최소화)
- ✅ 모든 글은 Git으로 버전 관리하고 싶다

이 모든 조건을 만족하는 조합이 **Hugo + Cloudflare Pages**였다.

### Hugo의 장점

- **Go 언어 기반** → 빌드 속도가 미친듯이 빠름 (수천 페이지도 1초 이내)
- **순수 정적 사이트** → 서버 취약점, PHP 버전 업데이트 걱정 없음
- **마크다운 기반** → 글 작성에만 집중 가능
- **Git으로 모든 히스토리 관리** → 백업, 복구, 이전 모두 간단
- **플랫폼 독립적** → 특정 서비스에 종속되지 않음

### Cloudflare Pages의 장점

- **Git push → 자동 빌드/배포** → CI/CD 별도 구성 불필요
- **전 세계 300+ 지역 CDN** → 글로벌 사용자도 빠른 로딩
- **무료 플랜이 매우 관대함** → 월 500회 빌드, 무제한 대역폭
- **HTTPS 자동 적용** → SSL 인증서 관리 불필요
- **Preview Deployment** → PR마다 미리보기 URL 자동 생성

---

## 전체 아키텍처

```text
┌─────────────┐
│  Local PC   │  1. 마크다운으로 글 작성
│             │  2. git commit & push
└──────┬──────┘
       │
       ▼
┌─────────────────────┐
│  Git Repository     │  3. Cloudflare Pages가 변경 감지
│  (GitHub/GitLab)    │
└──────┬──────────────┘
       │
       ▼
┌──────────────────────────────┐
│   Cloudflare Pages           │  4. hugo build 자동 실행
│   ├─ Hugo Build              │  5. /public 디렉터리 배포
│   └─ Global CDN Distribution │  6. 전 세계 CDN에 배포
└──────────────────────────────┘
       │
       ▼
    🌍 Users
```

**운영 중에 내가 하는 일:**
1. 마크다운으로 글 쓰기
2. `git commit && git push`

끝.

---

## 구축 과정

### 1. Hugo 설치

#### Windows
```powershell
winget install Hugo.Hugo.Extended
```

#### macOS
```bash
brew install hugo
```

#### Linux (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install hugo
```

설치 확인:
```bash
hugo version
# hugo v0.xxx.x+extended ...
```

> **주의**: PaperMod 같은 일부 테마는 **Extended 버전**이 필요하다.

---

### 2. 새 Hugo 사이트 생성

```bash
hugo new site wooa.dev
cd wooa.dev
git init
```

생성된 디렉터리 구조:
```text
wooa.dev/
├─ archetypes/      # 새 글 템플릿
├─ content/         # 실제 포스트가 들어갈 곳
├─ layouts/         # 커스텀 레이아웃
├─ static/          # 정적 파일 (이미지, CSS 등)
├─ themes/          # 테마
└─ hugo.toml        # 설정 파일
```

---

### 3. 테마 설치 (PaperMod)

PaperMod는 깔끔하고 빠르며 기능이 풍부한 Hugo 테마다.

```bash
git submodule add --depth=1 https://github.com/adityatelange/hugo-PaperMod.git themes/PaperMod
```

> Git submodule로 설치하면 나중에 테마 업데이트가 쉽다.

---

### 4. `hugo.toml` 기본 설정

```toml
baseURL = "https://wooa.dev/"
languageCode = "ko-kr"
title = "WOOA.DEV"
theme = "PaperMod"

enableRobotsTXT = true
buildDrafts = false
buildFuture = false
buildExpired = false

[pagination]
  pagerSize = 10

[minify]
  disableXML = true
  minifyOutput = true

[params]
  author = "Han Sangwoo"
  description = "인프라 · 리눅스 · 보안 실무 기록"
  ShowReadingTime = true
  ShowShareButtons = true
  ShowPostNavLinks = true
  ShowBreadCrumbs = true
  ShowCodeCopyButtons = true
  ShowWordCount = true
  ShowRssButtonInSectionTermList = true
  UseHugoToc = true
  disableSpecial1stPost = false
  disableScrollToTop = false
  comments = false
  hidemeta = false
  hideSummary = false
  showtoc = true
  tocopen = false

[params.homeInfoParams]
  Title = "인프라 엔지니어의 기술 노트"
  Content = "실무에서 겪은 문제와 해결 과정을 기록합니다"

[[params.socialIcons]]
  name = "github"
  url = "https://github.com/devwooops"

[[params.socialIcons]]
  name = "rss"
  url = "/index.xml"

[outputs]
  home = ["HTML", "RSS", "JSON"]

[markup.highlight]
  noClasses = false
  anchorLineNos = false
  codeFences = true
  guessSyntax = false
  lineNos = false
  style = "monokai"
```

---

### 5. 글 작성: Page Bundle 방식 (권장)

이미지가 많은 기술 글은 **Page Bundle** 방식이 압도적으로 편하다.

#### 기존 방식 (불편함)
```text
content/posts/my-post.md
static/images/2025/01/screenshot1.png
static/images/2025/01/screenshot2.png
```
→ Markdown에서 `![](/images/2025/01/screenshot1.png)` 같은 긴 경로 필요

#### Page Bundle 방식 (권장)
```text
content/posts/hugo-cloudflare-pages/
├─ index.md          # 본문
├─ cover.webp        # 커버 이미지
├─ img-01.png        # 본문 이미지 1
└─ img-02.png        # 본문 이미지 2
```

Markdown에서는 **경로 없이** 바로 사용:
```markdown
![설명](img-01.png)
```

#### 새 글 만들기
```bash
hugo new posts/hugo-cloudflare-pages/index.md
```

Front matter 예시:
```yaml
---
title: "Hugo + Cloudflare Pages로 기술 블로그 만들기"
date: 2025-12-28T00:00:00+09:00
draft: false
categories: ["Blog", "Infra"]
tags: ["Hugo", "Cloudflare Pages"]
summary: "간단한 요약"
cover:
  image: "cover.webp"
  alt: "커버 이미지 설명"
  caption: "이미지 출처"
ShowToc: true
---
```

---

### 6. 로컬에서 미리보기

```bash
hugo server -D
```

브라우저에서 `http://localhost:1313` 접속

> `-D` 옵션: draft 상태 글도 표시

파일 저장하면 **실시간 자동 새로고침**된다.

---

### 7. Git 저장소 연결

```bash
git add .
git commit -m "Initial Hugo site"
git branch -M main
git remote add origin https://github.com/devwooops/wooa.dev.git
git push -u origin main
```

---

### 8. Cloudflare Pages 연동

#### ⚠️ 중요: Workers가 아니라 Pages로 생성

Cloudflare 대시보드에서:

1. **Workers & Pages** 메뉴 진입
2. **"Create application"** 클릭
3. **"Pages"** 탭 선택 (Workers 아님!)
4. **"Connect to Git"** 선택

#### Git 연결

- GitHub/GitLab 계정 연동
- Repository 선택: `wooa.dev`
- 빌드 설정:

| 항목 | 값 |
|-----|-----|
| **Framework preset** | Hugo |
| **Build command** | `hugo --minify` |
| **Build output directory** | `public` |
| **Root directory** | `/` (비워둠) |
| **Branch** | `main` |

> Hugo 버전을 고정하려면 **Environment variables**에 추가:
> ```
> HUGO_VERSION = 0.121.0
> ```

**Save and Deploy** 클릭하면 첫 빌드가 시작된다.

---

### 9. 커스텀 도메인 연결

Pages 프로젝트 → **Custom domains** → **Set up a custom domain**

```
wooa.dev
```

입력 후 Add domain.

**Cloudflare DNS를 사용 중이라면:**
- CNAME 레코드 자동 생성
- HTTPS 자동 활성화 (무료 SSL)

**외부 DNS를 사용한다면:**
- 제시된 CNAME 레코드를 DNS에 수동 추가

---

## 이미지 최적화 전략

### WebP 변환

PNG/JPG보다 30~50% 용량 감소:
```bash
# ImageMagick 사용
convert screenshot.png -quality 85 screenshot.webp

# cwebp 사용
cwebp -q 85 screenshot.png -o screenshot.webp
```

### 적절한 해상도

- 스크린샷: 1920px 이하로 리사이즈
- 아이콘/로고: 원본 크기 유지
- 커버 이미지: 1200x630 권장

---

## Cloudflare 캐시 최적화

### Cache Rule 설정 (선택사항)

**Pages → 프로젝트 → Settings → Cache**

이미지는 적극 캐싱해도 안전:

**조건:**
- Hostname equals `wooa.dev`
- File extension in: `png`, `jpg`, `jpeg`, `webp`, `gif`, `svg`, `ico`, `woff`, `woff2`

**설정:**
- Edge Cache TTL: **30 days**
- Browser Cache TTL: **7 days**

> CSS/JS는 Hugo가 빌드할 때마다 변경될 수 있으니 초기에는 건드리지 않는 게 안전하다.

---

## Google Search Console 등록

1. [Google Search Console](https://search.google.com/search-console) 접속
2. **도메인 속성** 방식으로 `wooa.dev` 등록
3. DNS TXT 레코드로 소유권 인증
4. Sitemap 제출:
   ```
   https://wooa.dev/sitemap.xml
   ```

Hugo는 기본적으로 sitemap.xml을 자동 생성한다.

---

## 개발 워크플로우

### 일반적인 작업 흐름

```bash
# 1. 새 글 생성
hugo new posts/my-new-post/index.md

# 2. 로컬 서버 실행 (draft 포함)
hugo server -D

# 3. 글 작성 + 이미지 추가

# 4. draft: false로 변경

# 5. Git commit & push
git add .
git commit -m "Add: 새로운 포스트"
git push

# 6. Cloudflare Pages가 자동 빌드/배포 (1~2분)
```

### Preview Deployment

PR을 만들면 Cloudflare Pages가 **미리보기 URL**을 자동 생성:
```
https://abc123.wooa-dev.pages.dev
```

병합 전에 실제 환경에서 확인 가능!

---

## 트러블슈팅

### 빌드 실패: `Error: Unable to locate config file`

**원인**: Hugo가 설정 파일을 찾지 못함

**해결**:
- Cloudflare Pages 설정에서 **Root directory**가 올바른지 확인
- `hugo.toml` (또는 `config.toml`) 파일이 저장소 루트에 있는지 확인

---

### 이미지가 표시되지 않음

**원인**: 상대 경로 문제 또는 baseURL 불일치

**해결**:
- Page Bundle 방식 사용 시 파일명만 적으면 됨: `![](image.png)`
- `hugo.toml`의 `baseURL`이 실제 도메인과 일치하는지 확인
- 빌드 로그에서 이미지 파일이 포함되었는지 확인

---

### 테마가 적용되지 않음

**원인**: Git submodule이 초기화되지 않음

**해결**:
```bash
git submodule update --init --recursive
```

Cloudflare Pages는 자동으로 submodule을 초기화하지만, 로컬에서는 수동으로 해야 한다.

---

### Syntax Highlighting이 이상함

**원인**: PaperMod 테마와 Hugo 기본 설정 충돌

**해결**: `hugo.toml`에 추가
```toml
[markup.highlight]
  noClasses = false
  style = "monokai"  # 또는 dracula, github 등
```

---

## 운영하면서 느낀 장단점

### ✅ 장점

- **서버 관리 완전 제거**: 보안 패치, OS 업데이트, 백업 걱정 없음
- **압도적인 속도**: 정적 파일이라 로딩 속도가 미친듯이 빠름
- **Git 기반 안정감**: 모든 변경사항이 기록되고, 언제든 롤백 가능
- **무료**: Cloudflare Pages 무료 플랜으로 충분 (월 500회 빌드, 무제한 대역폭)
- **플랫폼 독립성**: 언제든 다른 호스팅으로 이전 가능 (Netlify, Vercel 등)
- **글로벌 CDN**: 전 세계 어디서든 빠른 접속

### ❌ 단점

- **초기 세팅 러닝 커브**: Hugo, Git, Markdown에 익숙하지 않으면 처음이 어려움
- **웹 에디터 없음**: 웹 브라우저에서 직접 글을 쓸 수 없음 (로컬 환경 필요)
- **댓글 시스템 별도 구성**: Disqus, utterances 등 외부 서비스 연동 필요
- **동적 기능 제한**: 검색, 방명록 등은 별도 구현 필요

---

## 마무리

Hugo + Cloudflare Pages 조합은 **"블로그 플랫폼"이라기보다 "자동 배포되는 기술 문서 아카이브"**에 가깝다.

### 이런 분들께 추천

- ✅ 기술 기록을 오래 남기고 싶다
- ✅ 서버 관리에 시간을 쓰고 싶지 않다
- ✅ 이미지와 코드 블록이 많은 글을 쓴다
- ✅ Git과 Markdown에 익숙하다 (또는 배우고 싶다)

### 추천하지 않는 경우

- ❌ 웹 브라우저에서 바로바로 글을 쓰고 싶다
- ❌ 명령줄(CLI) 사용이 부담스럽다
- ❌ WordPress 같은 플러그인 생태계가 필요하다

---

## 다음 계획

인프라 쪽 일을 하다 보면 **"나는 이 정도 해봤고, 이 정도까지 할 줄 안다"**를 보여줄 마땅한 지표가 없다.
자격증이나 학위로는 실무 경험을 증명하기 어렵고, 면접에서 말로만 설명하는 것도 한계가 있다.

그래서 이 블로그는 **실제 운영하면서 겪은 문제와 해결 과정**을 계속 기록할 예정이다.

- 리눅스 시스템 트러블슈팅
- Docker/Kubernetes 실전 경험
- 네트워크 및 보안 이슈 대응
- 모니터링 및 로그 분석
- 인프라 자동화 (Terraform, Ansible 등)

**기록은 거짓말하지 않는다.**
