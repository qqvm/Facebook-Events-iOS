//
//  Types.swift
//  fbevents
//
//  Created by User on 12.09.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import Foundation
import GRDB


protocol BasicActorData{
    var id: Int{get set}
    var name: String{get set}
    var picture: String{get set}
}

enum ActorType: String, Codable{
    case page = "Page"
    case user = "User"
}

struct Actor: BasicActorData, Codable, Equatable, Hashable, PersistableData{
    var id: Int
    var type: ActorType
    var name: String
    var picture: String
    
    static func ==(lhs: Actor, rhs: Actor) -> Bool {
        return lhs.id == rhs.id
    }
}

struct User: BasicActorData, Codable, Identifiable, Equatable, Hashable, PersistableData{
    var id: Int
    var name: String
    var picture: String
    var isFriend: Bool? = false
    var birthDay: Int?
    var birthMonth: Int?
    var birthdate: String?
    
    static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}

struct Page: BasicActorData, Codable, Identifiable, Equatable, Hashable, PersistableData{
    var id: Int
    var name: String
    var picture: String
    var address: String?
    
    static func ==(lhs: Page, rhs: Page) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum ParentType: String, Codable{
    case page = "Page"
    case user = "User"
    case post = "Post"
    case comment = "Comment"
}

struct Post: Codable, Equatable, Hashable, PersistableData{
    var id: Int
    var parentId: Int // references to Event.id
    var parentType: String
    var text: String
    var time: Int
    var actors: [Actor]
    var pinned: Bool = false
    var lastUpdate: Date
    
    static let event = belongsTo(Event.self)
    var event: QueryInterfaceRequest<Event> {
        request(for: Post.event)
        // In case we need to store posts of other types in future, reference mechanism should be redesigned.
    }
    static let comments = hasMany(Comment.self)
    var comments: QueryInterfaceRequest<Comment> {
        request(for: Post.comments)
    }
    
    static func ==(lhs: Post, rhs: Post) -> Bool {
        return lhs.id == rhs.id
    }
}

struct Comment: Codable, Equatable, Hashable, PersistableData{
    var id: Int
    var parentId: Int // references to Comment.id or Event.id
    var parentType: String
    var actor: Actor
    var text: String
    var comments = [Comment]()
    var time: Int
    var lastUpdate: Date
    
    static let post = belongsTo(Post.self)
    var post: QueryInterfaceRequest<Post> {
        request(for: Comment.post)
    }

    static func ==(lhs: Comment, rhs: Comment) -> Bool {
        return lhs.id == rhs.id
    }
}
