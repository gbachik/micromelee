//
//  GameScene.swift
//  MicroMelee
//
//  Created by Christian Gage Bachik on 1/16/16.
//  Copyright (c) 2016 MG. All rights reserved.
//

import SpriteKit
import Foundation

extension CollectionType {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollectionType where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}

class MeleeScene: SKScene {
    
    var selectedCard = SKSpriteNode()
    var manaBar = SKSpriteNode()
    var manaLabel = SKLabelNode()
    var deck = [0,0,0,0,9,8,8,1,1,1,1,2,2,3,4,5,6,6,7,7].shuffle()
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        let sSize = floor((size.height*1.00)/20)
        let offset = (size.height-(sSize*20))/2
        for i in 0...599 {
            let sprite = SKSpriteNode()
            sprite.size = CGSizeMake(sSize, sSize)
            sprite.color = .redColor()
            sprite.name = "sprite\(i)"
            sprite.anchorPoint = CGPoint(x:0,y:0)
            let xPos = (Int(sSize)*((i%30)))+Int(offset)
            let yPos = (Int(sSize)*((i)/30))+Int(offset)
            sprite.position = CGPoint(x: xPos, y: yPos)
            addChild(sprite)
        }
        
        let cardXPos = 2*offset + 30*sSize
        let cSize = sSize*4
        let card0 = generateCard(self.deck.removeFirst(), cardSize: CGSizeMake(cSize, cSize), cardPosition: CGPoint(x: cardXPos, y: offset))
        let card1 = generateCard(self.deck.removeFirst(), cardSize: CGSizeMake(cSize, cSize), cardPosition: CGPoint(x: cardXPos, y: cSize + 2*offset))
        let card2 = generateCard(self.deck.removeFirst(), cardSize: CGSizeMake(cSize, cSize), cardPosition: CGPoint(x: cardXPos, y: 2*cSize + 3*offset))
        let card3 = generateCard(self.deck.removeFirst(), cardSize: CGSizeMake(cSize, cSize), cardPosition: CGPoint(x: cardXPos, y: 3*cSize + 4*offset))
        print("card: \(card0)")
        print("card: \(card1)")
        print("card: \(card2)")
        print("card: \(card3)")
        addChild(card0)
        addChild(card1)
        addChild(card2)
        addChild(card3)
        
        let maxManaHeight = size.height - offset*2
        manaBar.size = CGSizeMake(offset*2, maxManaHeight/10)
        manaBar.color = .blueColor()
        manaBar.anchorPoint = CGPoint(x: 0, y: 0)
        manaBar.name = "Mana Bar"
        manaBar.position = CGPoint(x: sSize*34 + offset*4, y: offset)
        addChild(manaBar)
        
        let totalMana = (manaBar.size.height/maxManaHeight) * 1000
        manaLabel.text = String(Int(totalMana))
        manaLabel.fontColor = .blackColor()
        manaLabel.verticalAlignmentMode = .Top
        manaLabel.horizontalAlignmentMode = .Left
        manaLabel.position = CGPoint(x: cardXPos, y: size.height - offset)
        addChild(manaLabel)
        
        let manaTimer = SKAction.waitForDuration(1)
        let manaSizeChange = SKAction.runBlock {
            if self.manaBar.size.height < maxManaHeight {
                
                if let mana = Int(self.manaLabel.text!) {
                    if mana < 1000{
                        let newMana = mana + 5
                        self.manaLabel.text = "\(newMana)"
                    }
                }
                
                self.manaBar.size = CGSizeMake(offset*2, self.manaBar.size.height + maxManaHeight/200)
                
            }
        }
        manaBar.runAction(SKAction.repeatActionForever(SKAction.sequence([manaTimer, manaSizeChange])))
    }
    
    func drawCard(){
        selectedCard.removeFromParent()
        if (deck.isEmpty == false){
            let newCard = deck.removeFirst()
            generateCard(newCard, cardSize: selectedCard.size, cardPosition: selectedCard.position)
        }
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        for touch in touches{
            let positionInScene = touch.locationInNode(self)
            let touchedNode = self.nodeAtPoint(positionInScene)
            if let sprite = touchedNode as? SKSpriteNode {
                selectedCard = sprite
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches{
            let positionInScene = touch.locationInNode(self)
            let touchedNode = self.nodeAtPoint(positionInScene)
            print("position:\(touchedNode.position)")
            if let name = touchedNode.name {
                if name.rangeOfString("sprite") != nil {
                    let id = name.substringFromIndex(name.startIndex.advancedBy(6))
                    print("id: \(id)")
                    if Int(id) <= 299 {
                        if let name = selectedCard.name {
                            if name == "Nigga"{
                                let monster = SKSpriteNode()
                                monster.size = CGSizeMake(20, 20)
                                monster.color = .blackColor()
                                monster.anchorPoint = CGPoint(x: 0,y: 0)
                                monster.name = "NiggaMon"
                                monster.position = touchedNode.position
                                let ppm = self.manaBar.size.height / CGFloat(Float(self.manaLabel.text!)!)
                                let cost = 20*ppm
                                if manaBar.size.height > cost {
                                    addChild(monster)
                                    manaBar.size.height -= cost
                                    let newVal = Int(manaLabel.text!)! - 20
                                    manaLabel.text = "\(newVal)"
                                    drawCard()
                                }
                            }else if name == "White" {
                                let monster = SKSpriteNode()
                                monster.size = CGSizeMake(20, 20)
                                monster.color = .whiteColor()
                                monster.anchorPoint = CGPoint(x: 0,y: 0)
                                monster.name = "WhiteMon"
                                monster.position = touchedNode.position
                                let ppm = self.manaBar.size.height / CGFloat(Float(self.manaLabel.text!)!)
                                let cost = 30*ppm
                                if manaBar.size.height > cost {
                                    addChild(monster)
                                    manaBar.size.height -= cost
                                    let newVal = Int(manaLabel.text!)! - 30
                                    manaLabel.text = "\(newVal)"
                                    drawCard()
                                }
                            }else if name == "Green" {
                                let monster = SKSpriteNode()
                                monster.size = CGSizeMake(20, 20)
                                monster.color = .greenColor()
                                monster.anchorPoint = CGPoint(x: 0,y: 0)
                                monster.name = "GreenMon"
                                monster.position = touchedNode.position
                                let ppm = self.manaBar.size.height / CGFloat(Float(self.manaLabel.text!)!)
                                let cost = 80*ppm
                                if manaBar.size.height > cost {
                                    addChild(monster)
                                    manaBar.size.height -= cost
                                    let newVal = Int(manaLabel.text!)! - 80
                                    manaLabel.text = "\(newVal)"
                                    drawCard()
                                }
                            }else if name == "Yellow" {
                                let monster = SKSpriteNode()
                                monster.size = CGSizeMake(20, 20)
                                monster.color = .yellowColor()
                                monster.anchorPoint = CGPoint(x: 0,y: 0)
                                monster.name = "YellowMon"
                                monster.position = touchedNode.position
                                let ppm = self.manaBar.size.height / CGFloat(Float(self.manaLabel.text!)!)
                                let cost = 200*ppm
                                if manaBar.size.height > cost {
                                    addChild(monster)
                                    manaBar.size.height -= cost
                                    let newVal = Int(manaLabel.text!)! - 200
                                    manaLabel.text = "\(newVal)"
                                    drawCard()
                                }
                            }

                        }
                        
                    }
                }
            }
        }
        selectedCard = SKSpriteNode()
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
