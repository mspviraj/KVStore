//
//  KVStoreManager.swift
//  KVStore
//
//  Created by Pritesh Nandgaonkar on 9/2/17.
//  Copyright © 2017 Pritesh Nandgaonkar. All rights reserved.
//

import Foundation

protocol CRUDDelegate {
    func insert<T: Hashable>(value: Data, for key: T) throws
    func deleteValue<T: Hashable>(for key: T) throws
    func update<T: Hashable>(value: Data, for key: T) throws
    func getValue<T: Hashable>(for key: T) -> Data?
}

public final class KVStoreManager<F: Hashable>: CRUDDelegate {
    
    let db: SQLiteDatabase
    
    /// This init method would create the db file with name passed as parameter and would open the database connection. And if the file already exist it will just open the database connection.Also it would create a table in these file if its not already created.Sqlite is configured in serialised mode
    ///
    /// - parameter fileName: The sqlite filename.     
    ///
    /// - returns: KVStoreManager
    public init(with fileName: String) throws {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docPath = paths[0]
        db = try SQLiteDatabase.open(path: docPath + "/" + "\(fileName).sqlite")
        if !db.checkIfTableExist(table: RowModel.self) {
            try db.createTable(table: RowModel.self)
        }
        print("Successfully opened connection to database.")
    }
    
    /// Inserts or Updates the key value pair in the database in a syrialized way
    ///
    /// - parameter value: Its of type Data. This is stored as BLOB in sqlite for the unique key.
    /// - parameter key: Its a unique key which is of type `Hashable` and its also a primary key in a database
    ///
    /// - returns: Void
    public func insert<T: Hashable>(value: Data, for key: T) throws {
        let model = RowModel(id: (key.hashValue) , data: value)
        try db.insert(model: model)
        
    }
    
    /// Deletes the key value pair in the database in a syrialized way
    ///
    /// - parameter value: Its of type Data. This is stored as BLOB in sqlite for the unique key.
    /// - parameter key: Its a unique key which is of type `Hashable` and its also a primary key in a database
    ///
    /// - returns: Void
    public func deleteValue<T: Hashable>(for key: T) throws {
        try db.delete(key: key.hashValue)
    }
    
    /// Updates the key value pair in the database in a syrialized way
    ///
    /// - parameter key: Its a unique key which is of type `Hashable` and its also a primary key in a database
    ///
    /// - returns: Void
    public func update<T: Hashable>(value: Data, for key: T) throws {
        try db.update(model:  RowModel(id: (key.hashValue) , data: value))
    }
    
    /// Fetches the value for a key in a syrialized way
    ///
    /// - parameter key: Its a unique key which is of type `Hashable` and its also a primary key in a database
    ///
    /// - returns: Data
    public func getValue<T: Hashable>(for key: T) -> Data? {
        do {
            let data = try db.getValue(for: key.hashValue, tableName: RowModel.tableName)
            return data
        }
        catch {
            return nil;
        }
    }
    
    /// returns Data? for get query. You cannot set values through subscript
    public subscript(index: F) -> Data? {
        get {
            return getValue(for: index)
        }
    }
}
