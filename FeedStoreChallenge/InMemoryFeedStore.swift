//
//  InMemoryFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Alexander Nikolaychuk on 20.01.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public class InMemoryFeedStore: FeedStore {
	
	private struct Cache {
		var feed: [LocalFeedImage]
		var timestamp: Date
	}
	
	public init() {}
	
	private var storage: Cache?
	
	private let queue = DispatchQueue(label: "\(InMemoryFeedStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		queue.async(flags: .barrier) {
			self.storage = nil
			completion(nil)
		}
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		queue.async(flags: .barrier) {
			self.storage = Cache(feed: feed, timestamp: timestamp)
			completion(nil)
		}
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		queue.async {
			if let storage = self.storage {
				completion(.found(feed: storage.feed, timestamp: storage.timestamp))
			} else {
				completion(.empty)
			}
		}
	}
	
}
