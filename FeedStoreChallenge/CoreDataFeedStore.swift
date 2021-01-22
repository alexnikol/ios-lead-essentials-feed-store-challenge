//
//  CoreDataFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Alexander Nikolaychuk on 21.01.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataFeedStore: FeedStore {
	
	private let container: NSPersistentContainer
	private let context: NSManagedObjectContext
	private let modelName = "CoreDataFeedModel"
	private let storeURL: URL!
	
	public init(storeURL: URL) throws {
		
		self.storeURL = storeURL
		
		guard let modelURL = Bundle(for: CoreDataFeedStore.self).url(forResource: modelName, withExtension:"momd"),
			  let model = NSManagedObjectModel(contentsOf: modelURL) else {
			throw NSError()
		}
		
		let description = NSPersistentStoreDescription(url: storeURL)
		container = NSPersistentContainer(name: modelName, managedObjectModel: model)
		container.persistentStoreDescriptions = [description]
				
		var loadError: Swift.Error?
		container.loadPersistentStores { loadError = $1 }
		try loadError.map { throw $0 }
		
		context = container.newBackgroundContext()
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		let context = self.context
		context.perform {
			do {
				let request = NSFetchRequest<CDCache>(entityName: CDCache.entity().name!)
				request.returnsObjectsAsFaults = false
				if let cache = try context.fetch(request).first {
					let feed = cache.feed
						.compactMap { ($0 as? CDFeedImage) }
						.map {
							LocalFeedImage(id: $0.id, description: $0.imageDescription, location: $0.location, url: $0.url)
						}
					completion(.found(feed: feed, timestamp: cache.timeStamp))
				} else {
					completion(.empty)
				}
			} catch {
				completion(.failure(error))
			}
		}
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		let context = self.context
		context.perform {
			do {
				let cache = CDCache(context: context)
				cache.timeStamp = timestamp
				cache.feed = NSOrderedSet(array: feed.map { local in
					let feed = CDFeedImage(context: context)
					feed.id = local.id
					feed.imageDescription = local.description
					feed.location = local.location
					feed.url = local.url
					return feed
				})
				try context.save()
				completion(nil)
			} catch {
				completion(error)
			}
		}
	}
	
}

private extension NSPersistentContainer {
	
	enum LoadingError: Swift.Error {
		case modelNotFound
		case failedToLoadPersistentStores(Swift.Error)
	}

	static func load(modelName name: String, in bundle: Bundle) throws -> NSPersistentContainer {
		guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
			throw LoadingError.modelNotFound
		}

		let container = NSPersistentContainer(name: name, managedObjectModel: model)
		var loadError: Swift.Error?
		container.loadPersistentStores { loadError = $1 }
		try loadError.map { throw LoadingError.failedToLoadPersistentStores($0) }
		return container
	}
 }

  private extension NSManagedObjectModel {
	
	static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
		return bundle
			.url(forResource: name, withExtension: "momd")
			.flatMap { NSManagedObjectModel(contentsOf: $0) }
	}
	
 }
