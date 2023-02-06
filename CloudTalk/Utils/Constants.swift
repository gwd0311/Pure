//
//  Constants.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/19.
//

import Firebase

let COLLECTION_USERS = Firestore.firestore().collection("users")
let COLLECTION_POSTS = Firestore.firestore().collection("posts")
let COLLECTION_CHATS = Firestore.firestore().collection("chats")

// User
let KEY_NICKNAME = "nickname"
let KEY_GENDER = "gender"
let KEY_AGE = "age"
let KEY_REGION = "region"
let KEY_INTRODUCTION = "introduction"
let KEY_PROFILE_IMAGE_URL = "profileImageUrl"
let KEY_TIMESTAMP = "timestamp"
// Post
let KEY_UID = "uid"
let KEY_CONTENT = "content"
let KEY_POST_IMAGE_URL = "postImageUrl"
let KEY_LIKE_COUNT = "likeCount"
let KEY_LIKE_UIDS = "likeUids"
let KEY_COMMENT_COUNT = "commentCount"
// Comment
let KEY_COMMENT = "comment"
// Chat
let KEY_UIDS = "uids"
let KEY_LASTMESSAGE = "lastMessage"
let KEY_UNREADMESSAGECOUNT = "unReadMessageCount"
// Message
let KEY_FROMID = "fromId"
let KEY_TOID = "toId"
let KEY_ISREAD = "isRead"
let KEY_TEXT = "text"

// UserDefaults
/// main scene
let DEFAULTS_MAIN_GENDER = "main.gender"
let DEFAULTS_MAIN_REGION = "main.region"
let DEFAULTS_MAIN_AGERANGE_LOWERBOUND = "main.ageRange.lowerBound"
let DEFAULTS_MAIN_AGERANGE_UPPERBOUND = "main.ageRange.upperBound"
/// post scene
let DEFAULTS_POST_GENDER = "post.gender"
let DEFAULTS_POST_REGION = "post.region"
let DEFAULTS_POST_AGERANGE_LOWERBOUND = "post.ageRange.lowerBound"
let DEFAULTS_POST_AGERANGE_UPPERBOUND = "post.ageRange.upperBound"
