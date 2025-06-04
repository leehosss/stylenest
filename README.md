# StyleNest

StyleNest는 Flutter와 Firebase를 기반으로 한 패션 이커머스 애플리케이션입니다.  
사용자는 다양한 패션 아이템을 탐색하고, 장바구니에 담아 주문할 수 있으며, 리뷰 작성 및 관리, 사용자 프로필 관리 등 다양한 기능을 제공합니다.

---

## 🏗️ 프로젝트 구조

```
lib/
├── firebase_options.dart      # Firebase 설정
├── main.dart                 # 앱 진입점
├── models/                   # 데이터 모델 (User, Product, Cart 등)
├── screens/                  # 주요 화면 (홈, 상품, 장바구니, 주문, 프로필 등)
├── services/                 # 비즈니스 로직 및 API 통신
├── widgets/                  # 공통/재사용 위젯
└── utils/                    # 유틸리티 함수 및 상수
```

---

## 🚀 주요 기능

- **회원가입/로그인**  
  Firebase Authentication을 통한 이메일/비밀번호 기반 회원가입 및 로그인 지원

- **상품 탐색 및 검색**  
  다양한 카테고리별 상품 목록 제공, 키워드 검색 기능

- **상품 상세 페이지**  
  상품 이미지, 설명, 가격, 리뷰 등 상세 정보 제공

- **장바구니**  
  상품을 장바구니에 추가/삭제, 수량 조절, 총 금액 확인

- **주문 및 결제**  
  장바구니 상품 주문, 주문 내역 확인

- **리뷰 작성 및 조회**  
  상품별 리뷰 작성, 별점 평가, 리뷰 목록 확인

- **프로필 관리**  
  사용자 정보 수정, 주문 내역 및 리뷰 관리

- **관리자 기능**  
  상품 등록/수정/삭제, 주문 및 사용자 관리(선택적)

---

## ⚙️ 설치 및 실행 방법

1. **Flutter 설치**  
   [Flutter 공식 문서](https://docs.flutter.dev/get-started/install) 참고

2. **Firebase 프로젝트 연동**  
   - Firebase 콘솔에서 프로젝트 생성  
   - `google-services.json` 및 `GoogleService-Info.plist` 파일 추가  
   - `firebase_options.dart` 자동 생성

3. **패키지 설치**
   ```
   flutter pub get
   ```

4. **앱 실행**
   ```
   flutter run
   ```

---

## 📦 사용된 주요 기술

- Flutter 3.x
- Firebase (Auth, Firestore, Storage)
- Provider (상태 관리)
- 기타: HTTP, 이미지 업로드, 폼 검증 등

---

## 📝 기여 방법

1. 이슈 등록 및 토론
2. Fork & Pull Request
3. 코드 리뷰 후 병합

---


