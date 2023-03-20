<img src="https://user-images.githubusercontent.com/64826110/226221361-e04f4546-f453-4fd2-ae2f-cb81b73900aa.jpeg">


### ⬇️ 친해질수록 직업이 드러나는 퓨어 다운로드하기
<img height=70 src="https://user-images.githubusercontent.com/64826110/226221903-ca096836-671f-4092-b123-8eafd46b9aa0.png">

> ## 퓨어: 편견없는 친구만들기 앱
> '퓨어'는 직업에 대한 편견없이 친구를 만들 수 있는 앱입니다. 친구와 충분히 대화하다보면 친구의 직업을 점점 알 수 있게 되는 앱 입니다. 퓨어에서 좋은 친구들을 만나보세요!

## 주요 기능
| 애플로그인 | 휴대폰로그인 | 프로필 등록 |
|--|--|--|
|![Simulator Screen Recording - iPhone 14 Pro - 2023-03-20 at 10 20 35](https://user-images.githubusercontent.com/64826110/226225351-49381d21-303b-494a-bb64-44a3cfabfa73.gif)|![Simulator Screen Recording - iPhone 14 Pro - 2023-03-20 at 10 23 56](https://user-images.githubusercontent.com/64826110/226225567-d5c31452-7c7e-4a80-a794-1c14fd742542.gif)|![Simulator Screen Recording - iPhone 14 Pro - 2023-03-20 at 10 25 57](https://user-images.githubusercontent.com/64826110/226226138-f63cc203-e9f3-472d-94d1-f26220d85847.gif)|
| 메시지보내기 | 필터 기능 | 밀어서 새로고침 |
|![Simulator Screen Recording - iPhone 14 Pro - 2023-03-20 at 10 35 44](https://user-images.githubusercontent.com/64826110/226227110-8ee2c1f5-6ac6-4161-b636-42f404401f26.gif)|![Simulator Screen Recording - iPhone 14 Pro - 2023-03-20 at 10 37 17](https://user-images.githubusercontent.com/64826110/226227272-4d86db21-34b7-47ed-8f58-4cfcfcfbd61a.gif)|![Simulator Screen Recording - iPhone 14 Pro - 2023-03-20 at 10 37 56](https://user-images.githubusercontent.com/64826110/226227324-92802679-a9c5-4c30-b040-5f8c762faeca.gif)|
| 좋아요보내기 | 채팅할수록 직업 블러 연하게하기 | 게시물 올리기 |
|![Simulator Screen Recording - iPhone 14 Pro - 2023-03-20 at 10 56 28](https://user-images.githubusercontent.com/64826110/226229277-12c9a445-bdbf-4fb6-b4a0-6ae0bf5998d1.gif)|![Simulator Screen Recording - iPhone 14 Pro - 2023-03-20 at 11 15 19](https://user-images.githubusercontent.com/64826110/226231257-0f969811-09f2-4117-8847-8a09831bed49.gif)|![Simulator Screen Recording - iPhone 14 Pro - 2023-03-20 at 11 10 50](https://user-images.githubusercontent.com/64826110/226230779-00718447-c330-4872-82e2-0253c738fe6b.gif)|


## ⚒️ 기술적 도전
### MVVM Architecture
- 뷰와 관련된 로직과 비즈니스 로직을 분리하고 싶어 도입하였습니다.
- 각 계층이 명확하게 분리되어있기 때문에 테스트 및 유지보수가 용이해집니다.

### SwiftConcurrency
- 기존의 콜백 방식에 의해 가독성이 떨어지는 부분을 보완할 수 있습니다.
- Swift Concurrency를 사용해서 코드를 작성하면 스레드 개수가 코어 수보다 늘어나지 않기 때문에 `thread explosion`이 미연에 방지되는 장점이 있습니다.
- 에러 핸들링을 보다 간편하게 할 수 있습니다.

# Firebase
- 인증 시스템을 지원합니다.
- Combine과 Swift Concurrency를 지원합니다.
- 서버를 간편하게 제작할 수 있습니다.
- 푸쉬알림을 간편하게 구현할 수 있는 FCM을 지원합니다.





