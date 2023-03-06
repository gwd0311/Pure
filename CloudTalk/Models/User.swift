//
//  User.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/19.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct User: Identifiable, Decodable {
    @DocumentID var id: String?
    let nickname: String
    let gender: Gender
    let age: Int
    let region: Region
    let introduction: String
    let profileImageUrl: String
    let timestamp: Timestamp
    let blackUids: [String]
    let point: Int
    let isPushOn: Bool
    let lastPointDate: Timestamp
}

enum Gender: Int, CaseIterable, Codable {
    case man
    case woman
    
    var title: String {
        switch self {
        case .man:
            return "남자"
        case .woman:
            return "여자"
        }
    }
}

enum Region: Int, CaseIterable, Codable, Identifiable {
    case seoul
    case daejeon
    case daegu
    case busan
    case incheon
    case gwangju
    case ulsan
    case sejong
    case gyeonggi
    case gangwon
    case chungbuk
    case chungnam
    case jeonbuk
    case jeonnam
    case gyeongbuk
    case gyeongnam
    case jeju
    case overseas
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .seoul:
            return "서울"
        case .daejeon:
            return "대전"
        case .daegu:
            return "대구"
        case .busan:
            return "부산"
        case .incheon:
            return "인천"
        case .gwangju:
            return "광주"
        case .ulsan:
            return "울산"
        case .sejong:
            return "세종"
        case .gyeonggi:
            return "경기"
        case .gangwon:
            return "강원"
        case .chungbuk:
            return "충북"
        case .chungnam:
            return "충남"
        case .jeonbuk:
            return "전북"
        case .jeonnam:
            return "전남"
        case .gyeongbuk:
            return "경북"
        case .gyeongnam:
            return "경남"
        case .jeju:
            return "제주"
        case .overseas:
            return "외국"
        }
    }
}

let MOCK_USER = User(
    nickname: "    ",
    gender: .man,
    age: 24,
    region: .daejeon,
    introduction: "데이터를 불러오지 못했습니다.",
    profileImageUrl: "",
    timestamp: Timestamp(date: Date(timeInterval: TimeInterval(-20000), since: Date())),
    blackUids: [],
    point: 100,
    isPushOn: true,
    lastPointDate: Timestamp(date: Date(timeInterval: TimeInterval(-3600), since: Date()))
)
