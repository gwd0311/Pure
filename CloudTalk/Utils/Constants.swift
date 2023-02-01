//
//  Constants.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/19.
//

import Firebase

let COLLECTION_USERS = Firestore.firestore().collection("users")

// User
let KEY_NICKNAME = "nickname"
let KEY_GENDER = "gender"
let KEY_AGE = "age"
let KEY_REGION = "region"
let KEY_INTRODUCTION = "introduction"
let KEY_PROFILE_IMAGE_URL = "profileImageUrl"
let KEY_TIMESTAMP = "timestamp"

// UserDefaults
let DEFAULTS_MAIN_GENDER = "main.gender"
let DEFAULTS_MAIN_REGION = "main.region"
let DEFAULTS_MAIN_AGERANGE_LOWERBOUND = "main.ageRange.lowerBound"
let DEFAULTS_MAIN_AGERANGE_UPPERBOUND = "main.ageRange.upperBound"
