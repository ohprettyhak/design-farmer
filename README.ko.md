# design-farmer

[![Skill Quality](https://github.com/ohprettyhak/design-farmer/actions/workflows/skill-quality.yml/badge.svg)](https://github.com/ohprettyhak/design-farmer/actions/workflows/skill-quality.yml)
[![Last Commit](https://img.shields.io/github/last-commit/ohprettyhak/design-farmer/main)](https://github.com/ohprettyhak/design-farmer/commits/main/)
[![Latest Release](https://img.shields.io/github/v/release/ohprettyhak/design-farmer?sort=semver)](https://github.com/ohprettyhak/design-farmer/releases)

[English](README.md) | **한국어** | [日本語](README.ja.md) | [简体中文](README.zh.md) | [繁體中文](README.zh-TW.md)

> 씨앗에서 시스템까지. 어떤 코드베이스든 프로덕션 수준의 디자인 시스템으로 키워냅니다.

`design-farmer`는 코딩 에이전트용 스킬입니다. 레포지토리를 분석하고 기존 디자인 패턴을 추출한 뒤, 토큰, 컴포넌트, 테스트, 문서를 갖춘 OKLCH 기반 디자인 시스템으로 키워냅니다.

## 왜 필요한가요?

AI 에이전트와 바이브 코딩을 하다 보면 디자인 일관성이 가장 먼저 무너집니다. 색상은 제각각이고, 간격은 들쭉날쭉하고, 다크 모드는 뒷전입니다. 에이전트에게 명확한 디자인 제약을 주면 훨씬 일관된 UI가 나오지만, 그걸 직접 만드는 건 배보다 배꼽이 큰 일입니다.

Design Farmer는 이 과정을 통째로 자동화합니다. 코드베이스를 읽고, 이미 있는 것을 파악한 뒤, 그 위에 프로덕션 수준의 디자인 시스템을 구축하거나 업그레이드합니다. 토큰 파일을 손으로 만들 필요도, 컬러 팔레트를 복붙할 필요도 없습니다.

## 하는 일

Design Farmer는 프로젝트 상태에 맞춰 단계별로 작동합니다:

| 시작 상태 | 수행 내용 | 결과 |
|---|---|---|
| **디자인 시스템 없음** | 코드에서 색상/간격을 탐지, OKLCH로 변환, 토큰 계층 생성 | 프리미티브 + 시맨틱 토큰, 명암비 검증을 거친 컬러 스케일 |
| **부분적 시스템** | 기존 토큰 감사, 누락된 부분(상태, 역할, 테마) 식별 | 기존 참조를 깨지 않으면서 시맨틱 커버리지 완성 |
| **인터랙티브 컴포넌트 부재** | 키보드/포커스 동작을 갖춘 Button, Input, Select, Dialog 구축 | 인터랙션 테스트가 포함된 일관된 접근성 컴포넌트 |
| **라이트 테마만 존재** | OKLCH 명도/채도 조정으로 다크 테마 생성 | 하나의 시맨틱 토큰 체계로 동작하는 듀얼 테마 |
| **"프로덕션 준비 완료" 주장** | 다중 리뷰어 검증, 스타일 불일치 및 토큰 오용 탐지 | 근거가 담긴 완료 판정과 개선 노트 |

전체 파이프라인 구성: 사전 점검, 디스커버리 인터뷰, 레포지토리 분석, OKLCH 변환을 통한 패턴 추출, 비주얼 프리뷰, 아키텍처 설계, 테마 시스템, DESIGN.md 생성, 토큰 구현, 컴포넌트 라이브러리, Storybook 통합, 다중 리뷰어 검증, 라이브 비주얼 QA, 문서화, 앱 통합, 릴리스 준비.

## 결과물

- **OKLCH 컬러 시스템**: 자동 명암비 검증이 포함된, 지각적으로 균등한 컬러 스케일
- **토큰 계층**: 프리미티브 → 시맨틱 → 컴포넌트 순으로 정리된 토큰 구조
- **접근성 컴포넌트**: 키보드 탐색, 포커스 관리, ARIA 속성을 기본 지원
- **듀얼 테마**: 같은 토큰 체계로 라이트·다크 모드 전환
- **DESIGN.md**: 디자인 결정을 집약한, 기계 판독 가능한 단일 참조 문서
- **검증 근거**: "괜찮아 보인다"식 승인 대신, 명시적 통과/실패 기준에 따른 다각도 리뷰

<img src="assets/storybook-components.png" alt="Design Farmer가 생성한 컴포넌트 갤러리" width="100%" />

위 스크린샷은 아무것도 없는 상태(greenfield)에서 생성한 결과물입니다. 토큰도, 컴포넌트도, 디자인 의사결정도 없는 상태에서요. 일부 구현이 이미 있는 레포지토리(컴포넌트 몇 개, 컬러 변수, 스타일 가이드 등)에서는 그 위에서 이어 작업하기 때문에 훨씬 더 정교한 결과를 만들어냅니다.

> [!TIP]
> **더 좋은 결과를 원한다면?** 프로젝트 루트에 [`DESIGN.md`](https://github.com/VoltAgent/awesome-design-md)를 넣어두고 실행해 보세요.
> - [Stitch](https://stitch.withgoogle.com)로 직접 생성하거나,
> - [awesome-design-md](https://github.com/VoltAgent/awesome-design-md)에서 가져오세요. Vercel, Linear, Stripe 등 실제 사이트에서 추출한 58개 이상의 디자인 시스템이 있습니다.

## 설치

### Claude Code — 마켓플레이스 (권장)

Claude Code 마켓플레이스에서 바로 설치하면 자동 업데이트까지 지원됩니다:

1. Claude Code 설정을 열고 **Plugins → Marketplace**로 이동합니다.
2. **design-farmer**를 검색한 뒤 **Install**을 클릭합니다.

### 모든 도구 — curl 설치 스크립트

```bash
curl -fsSL https://raw.githubusercontent.com/ohprettyhak/design-farmer/main/install.sh | bash
```

**Claude Code**, **Codex CLI**, **Amp**, **Gemini CLI**, **OpenCode**를 자동 감지해 설치합니다.

선택적 설치 플래그(`--tool`, `--interactive`, `--dry-run`), 수동 설치, 문제 해결, 제거 방법은 [INSTALLATION.md](INSTALLATION.md)를 참고하세요.

## 문서

- [스킬 명세](skills/design-farmer/SKILL.md): 실행 시 참조되는 명세 파일
- [단계 인덱스](skills/design-farmer/docs/PHASE-INDEX.md): 관리자를 위한 실행 흐름 요약
- [품질 게이트](skills/design-farmer/docs/QUALITY-GATES.md): 검증 기준과 릴리스 체크리스트
- [유지보수 가이드](skills/design-farmer/docs/MAINTENANCE.md): 스타일 일관성 유지 및 업데이트 절차
- [예시 갤러리](skills/design-farmer/docs/EXAMPLES-GALLERY.md): 시나리오별 전후 비교와 단계 매핑

## 기여

- [기여 가이드](CONTRIBUTING.md)
