//
//  CoreDataFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Alexander Nikolaychuk on 21.01.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public class CoreDataFeedStore: FeedStore {
	
	public init() {}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		completion(.empty)
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {}
	
}
