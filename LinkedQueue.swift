//
//  LinkedQueue.swift
//  VIB3
//
//  Created by Nathan Barta on 5/10/21.
//  Copyright © 2021 Nathan Barta. All rights reserved.
//

import Foundation

final class LinkedQueue {
    private var size: Int!
    private var frontNode: Node?
    private var backNode: Node?
    private var currentNode: Node?
    
    init() {
        self.size = 0
    }
    
    init(urls: [URL]!) {
        guard urls.count > 0 else { print("URL array must have at least one entry"); return }
        self.size = urls.count
        
        for (index, url) in urls.enumerated() {
            let newNode = Node(url: url)
            newNode.setPreviousNode(currentNode)
            self.currentNode?.setNextNode(newNode)
            
            if (index == 0) {
                self.frontNode = newNode
            }
            if (index == urls.count - 1) {
                self.backNode = newNode
            }
            self.currentNode = newNode
        }
        self.currentNode = frontNode
    }
    
    ///Clears all elements from LinkedQueue
    public func clear() {
        size = 0
        frontNode = nil
        backNode = nil
        currentNode = nil
    }
    
    ///Returns elements in an array
    public func toArray() -> [URL] {//MAKE PRECONDITIONS
        var temp = frontNode
        var result: [URL] = [URL]()
        for _ in 0...(size - 1) {
            result.append(temp!.getURL())
            temp = temp?.getNextNode()
        }
        print("Result toArray: \(result)")
        return result
    }
    
    ///Enqueues new URL to end of queue
    public func enqueue(url: URL) {
        let newNode = Node(url: url)
        if size == 0 {
            frontNode = newNode
            backNode = newNode
        }
        else {
            newNode.setPreviousNode(backNode)
            self.backNode?.setNextNode(newNode)
        }
        backNode = newNode
        size += 1
    }
    
    ///Inserts new URL after currentNode
    public func enqueueNext(url: URL) {
        let newNode = Node(url: url)
        if size == 0 {
            print("Queue was empty. URL inserted as first item")
            frontNode = newNode
            backNode = newNode
        }
        else {
            //Get the node after current; set it's prev to newNode
            //set currentNext to newNode
            //set newNode prev to curentNext
            //set newNode next to afterCurrent
            if let currentPlusOne = currentNode?.getNextNode() {
                currentPlusOne.setPreviousNode(newNode)
                currentNode?.setNextNode(newNode)
                newNode.setPreviousNode(currentNode)
                newNode.setNextNode(currentPlusOne)
            }
            else {
                enqueue(url: url)
            }
        }
        size += 1
    }
    
    ///Destructive removal of first item in queue
    public func dequeue() -> URL? {
        if size == 0 {
            return nil
        }
        if size == 1 {
            let temp = frontNode
            clear()
            return temp?.getURL()
        }
        else {
            let temp = frontNode
            frontNode = frontNode?.getNextNode()
            frontNode?.setPreviousNode(nil)
            size -= 1
            return temp?.getURL()
        }
    }
    
    ///Inserts new element at given index (before old element).
    public func insert(url: URL, at index: Int) {
        let newNode = Node(url: url)
        if index == 0 {
            newNode.setNextNode(frontNode)
            frontNode?.setPreviousNode(newNode)
            frontNode = newNode
        }
        else if index == size {
            enqueue(url: url)
            return
        }
        else {
            do {
                let insertBefore = try get(at: index)
                insertBefore.getPreviousNode()?.setNextNode(newNode)
                newNode.setPreviousNode(insertBefore.getPreviousNode())
                insertBefore.setPreviousNode(newNode)
                newNode.setNextNode(insertBefore)
            }
            catch {
                print(error)
            }
        }
        size += 1
    }
    
    ///Destructive deletion of item at index
    public func remove(at index: Int) {
        if index == 0 { //Removing front
            frontNode = frontNode?.getNextNode()
            frontNode?.setPreviousNode(nil)
        }
        else if index == size - 1 { //Removing back
            backNode = backNode?.getPreviousNode()
            backNode?.setNextNode(nil)
        }
        else { //Removing anything else
            do {
                let toRemove = try get(at: index)
                toRemove.getPreviousNode()?.setNextNode(toRemove.getNextNode())
                toRemove.getNextNode()?.setPreviousNode(toRemove.getPreviousNode())
//                toRemove.clear()
            }
            catch {
                print(error)
            }
        }
        size -= 1
    }
    
    public func remove(node: Node) {
        var temp = frontNode
        for i in 0..<(size - 1) {
            if temp === node {
                remove(at: i)
                return
            }
            temp = temp?.getNextNode()
        }
    }
    
    ///Moves a single element at an index to a new index
    /// - Remark: This creates a new element to replace the old one. This function is expensive.
    /// - Precondition: Input must be bounded between 0..<size
    public func move(atIndex: Int, toIndex: Int) {
        do {
            let toMove = try get(at: atIndex)
            insert(url: toMove.getURL(), at: toIndex + 1)
            remove(node: toMove)
        }
        catch {
            print(error)
        }
    }
    
    ///Swaps URL's of two elements
    public func swap(atIndex: Int, toIndex: Int) {
        do {
            let n1 = try get(at: atIndex)
            let n2 = try get(at: toIndex)
            let temp: URL = n1.getURL()
            n1.setURL(url: n2.getURL())
            n2.setURL(url: temp)
        }
        catch {
            print(error)
        }
    }
    
    ///Gets node at index
    /// - Remark: Computations are slightly more expensive, so do not use if you already have a reference to the node you are trying to get (ie: frontNode, backNode, and either +/- those a known amount).
    /// - Precondition: Input must be bounded between 0..<size
    private func get(at index: Int) throws -> Node {
        guard index >= 0 && index < size else { throw LinkedQueueError.indexOutOfBounds(msg: "get(at:) index out of bounds")  }
        guard isEmpty() == false else { throw LinkedQueueError.sizeError(msg: "get(at:) requires a LinkedQueue of size >0") }
        if index == 0 { return frontNode! }
        if index == (size - 1) { return backNode! }
        var temp: Node = (frontNode?.getNextNode())!
        
        for _ in 1...(index - 1) {
            temp = temp.getNextNode()!
        }
        return temp
    }

    ///Non-destructive view of first item in queue
    public func peek() -> URL? {
        return frontNode?.getURL()
    }
    
    ///Checks if LinkedQueue has zero elements
    public func isEmpty() -> Bool {
        if size == 0 {
            return true
        }
        else {
            return false
        }
    }
    
    ///Returns size of LinkedQueue
    public func getSize() -> Int {
        return size
    }
    
    public func getCurrentURL() -> URL? {
        return currentNode?.getURL()
    }
    
    public func next() {
        currentNode = currentNode?.getNextNode()
    }
    
    public func previous() {
        currentNode = currentNode?.getPreviousNode()
    }
    
    public func restart() {
        currentNode = frontNode
    }
}

extension LinkedQueue {
    
    enum LinkedQueueError: Error {
        case indexOutOfBounds(msg: String)
        case sizeError(msg: String)
    }
    
    class Node {
        weak private var previousNode: Node?
        private var nextNode: Node?
//        private var _repeatNode: Int!
//        private var repeatNode: Int {
//            get {
//                return _repeatNode
//            }
//        }
        private var url: URL
        
        init(url: URL) {
            self.url = url
//            print("Node init with \(url)")
        }
        
        public func getURL() -> URL! {
//            print("Url fetched: \(self.url)")
            return self.url
        }
        
        public func setURL(url: URL) {
            self.url = url
        }
        
        public func getPreviousNode() -> Node? {
            return self.previousNode
        }
        
        public func getNextNode() -> Node? {
            return self.nextNode
        }
        
        public func setPreviousNode(_ node: Node?) {
            self.previousNode = node
        }
        
        public func setNextNode(_ node: Node?) {
            self.nextNode = node
        }
        
        public func clear() {
            previousNode = nil
            nextNode = nil
        }
    }
}
