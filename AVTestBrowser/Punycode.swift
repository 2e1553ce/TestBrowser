//
//  Punycode.swift
//
//  Created by Mike Kasianowicz on 9/7/15.
//  Copyright © 2015 Mike Kasianowicz. All rights reserved.
//

import Foundation

open class Punycode {
    //MARK: public static
    
    // RFC 3492 implementation
    open static let official = Punycode(
        delimiter: "-",
        encodeTable: "abcdefghijklmnopqrstuvwxyz0123456789"
    )
    
    // used for Swift name mangling - presumably to avoid digit interference
    open static let swift = Punycode(
        delimiter: "_",
        encodeTable: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJ"
    )
    
    //MARK: variables
    fileprivate let base = 36
    fileprivate let tMin = 1
    fileprivate let tMax = 26
    fileprivate let skew = 38
    fileprivate let damp = 700
    fileprivate let initialBias = 72
    fileprivate let initialN = 0x80
    
    fileprivate let delimiter : Character
    fileprivate let encodeTable : [Character]
    fileprivate let decodeTable : [Character : Int]
    
    
    //MARK: initializers
    public convenience init(delimiter: Character, encodeTable: String) {
        self.init(delimiter: delimiter, encodeTable: [Character](encodeTable.characters))
        
    }
    
    public required init(delimiter: Character, encodeTable: [Character]) {
        self.delimiter = delimiter
        self.encodeTable = encodeTable
        var decodeTable = [Character : Int]()
        encodeTable.enumerated().forEach { ( kvp: (Int, Character)) -> () in
            decodeTable[kvp.1] = kvp.0
        }
        self.decodeTable = decodeTable
    }
    
    //MARK: encode
    open func encode(_ unicode: String) -> String {
        var retval = ""
        var extendedChars = [Int]()
        
        for c in unicode.unicodeScalars {
            let ci = Int(c.value)
            if ci < initialN {
                retval.append(String(c))
            } else {
                extendedChars.append(ci)
            }
        }
        
        if extendedChars.count == 0 {
            return retval
        }
        
        retval.append(delimiter)
        
        extendedChars.sort()
        
        var bias = initialBias
        var delta = 0
        var n = initialN
        var h = retval.unicodeScalars.count - 1
        let b = retval.unicodeScalars.count - 1
        
        for i in h ..< unicode.unicodeScalars.count {
            
        print("\(unicode.unicodeScalars.count)")
        //for var i in stride(from: 0, to: unicode.unicodeScalars.count, by: 1) {
        //for var i = 0; h < unicode.unicodeScalars.count; { //i in stride(from: 0, to: 10, by: 1)
            let char = extendedChars[i]
            delta = delta + (char - n) * (h + 1)
            n = char
            
            for c in unicode.unicodeScalars {
                let ci = Int(c.value)
                if ci < n || ci < initialN {
                    delta += 1
                }
                
                if ci == n {
                    var q = delta
                    
                    let k = self.base
                    var t = 0
                    repeat {
                        
                        t = max(min(k - bias, self.tMax), self.tMin)
                        if q < t {
                            break
                        }
                        
                        let code = t + ((q - t) % (self.base - t))
                        retval.append(self.encodeTable[code])
                        
                        q = (q - t) / (self.base - t)
                        
                    } while true
                    /*
                    for var k = self.base; ; k += base {
                        let t = max(min(k - bias, self.tMax), self.tMin)
                        if q < t {
                            break
                        }
                        
                        let code = t + ((q - t) % (self.base - t))
                        retval.append(self.encodeTable[code])
                        
                        q = (q - t) / (self.base - t)
                    }
                    */
                    
                    retval.append(self.encodeTable[q])
                    bias = self.adapt(delta, h + 1, h == b)
                    delta = 0
                    h += 1
                }
            }
            
            delta += 1
            n += 1
        }
        return retval
    }
    
    private func adapt(_ delta: Int, _ numPoints: Int, _ firstTime: Bool) -> Int {
        var delta = delta
        delta = delta / (firstTime ? self.damp : 2)
        
        delta += delta / numPoints
        var k = 0
        while (delta > ((self.base - self.tMin) * self.tMax) / 2) {
            delta = delta / (self.base - self.tMin)
            k = k + self.base
        }
        k += ((self.base - self.tMin + 1) * delta) / (delta + self.skew)
        return k
    }
    
    //MARK: decode
    
    open func decode(_ punycode: String) -> String {
        var input = [Character](punycode.characters)
        var n = self.initialN
        var i = 0
        var bias = self.initialBias
        var output = [Character]()
        
        var pos = 0
        if let ipos = input.index(of: self.delimiter) {
            pos = ipos
            output.append(contentsOf: input[0 ..< pos + 1])
        }
        
        var outputLength = output.count
        let inputLength = input.count
        while pos < inputLength {
            let oldi = i
            var w = 1
            
            var t = 0
            let k = self.base
            var digit = self.decodeTable[input[pos + 1]]!
            repeat {
                
                digit = self.decodeTable[input[pos + 1]]!
                i = i + (digit * w)
                t = max(min(k - bias, self.tMax), self.tMin)
                if (digit < t) {
                    break
                }
                w = w * (self.base - t)
                
            } while true
            /*
            for var k = self.base;; k += self.base {
                let digit = self.decodeTable[input[pos + 1]]!
                i = i + (digit * w)
                let t = max(min(k - bias, self.tMax), self.tMin)
                if (digit < t) {
                    break
                }
                w = w * (self.base - t)
            }
            */
            
            bias = self.adapt(i - oldi, outputLength + 1, (oldi == 0))
            n = n + i / outputLength
            i = i % outputLength
            output.insert(Character(UnicodeScalar(n)!), at: i)
            i += 1
        }
        return String(output)
    }
}
