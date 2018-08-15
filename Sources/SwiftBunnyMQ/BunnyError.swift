//
//  BunnyError.swift
//  SwiftBunnyMQ
//
//  Created by Antwan van Houdt on 14/08/2018.
//

public enum BunnyError: Error {
    case loginFailed

    case channelOpenFailed
    case consumingFailed
    case queueDeclarationFailed
}
