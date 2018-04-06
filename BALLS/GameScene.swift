//
//  GameScene.swift
//  BALLS
//
//  Created by Ryan Maksymic on 2018-02-17.
//  Copyright © 2018 Ryan Maksymic. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene
{
    // MARK: - Properties
    
    var motionManager : CMMotionManager!
    
    var timerCount: Int!
    var timerLabel: SKLabelNode!
    var timerAction: SKAction!
    var endgameMessage: SKLabelNode!
    
    var ball: SKSpriteNode!
    var ballYPosMin: CGFloat!
    
    var cameraPan: SKAction!
    
    var gameOn = false
    
    let backgroundHeight = CGFloat(3840)
    let backgroundCount = CGFloat(2)
    let cameraPanRate = CGFloat(4)
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    private var lastUpdateTime : TimeInterval = 0
    
    
    // MARK: - Setup
    
    override func sceneDidLoad() {
        setUpMotionManager()
        setUpCamera()
        setUpTimer()
        setUpBall()
        //self.physicsWorld.gravity = CGVector(dx: 0, dy: -30.0)
        self.lastUpdateTime = 0
    }
    
    func setUpMotionManager() {
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
    }
    
    func setUpCamera() {
        guard let camera = camera else {
            print("Error: Camera not found!")
            return
        }
        let cameraYLowerLimit = -backgroundHeight * (backgroundCount - 0.5)
        camera.position = CGPoint(x: 0.0, y: 0.0)
        let cameraXConstraint = SKConstraint.positionX(SKRange(lowerLimit: 0.0, upperLimit: 0.0))
        let cameraYConstraint = SKConstraint.positionY(SKRange(lowerLimit: cameraYLowerLimit, upperLimit: 0.0))
        camera.constraints = [cameraXConstraint, cameraYConstraint]
        cameraPan = SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: 0.04),
            SKAction.run {
                self.camera?.position.y -= self.cameraPanRate
            }
            ]))
    }
    
    func setUpTimer() {
        timerLabel = camera?.childNode(withName: "timerLabel") as! SKLabelNode
        timerCount = 0
        timerAction = SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.run {
                self.timerCount = self.timerCount + 1
                self.timerLabel.text = self.stringFromTime(time: self.timerCount)
            }
            ]))
        endgameMessage = camera?.childNode(withName: "endgameMessage") as! SKLabelNode
        endgameMessage.isHidden = true
    }
    
    func stringFromTime(time: Int) -> String {
        var result = ""
        let ti = NSInteger(time)
        let minutes = (ti / 60) % 60
        let seconds = ti % 60
        result.append("\(minutes)")
        result.append(seconds < 10 ? ":0\(seconds)" : ":\(seconds)")
        return result
    }
    
    func setUpBall() {
        ball = self.childNode(withName: "ball") as! SKSpriteNode
        ballYPosMin = ball.position.y
        ball.physicsBody!.isDynamic = false
    }
    
    
    // MARK: - Touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameOn == false {
            startGame()
        } else {
            jump()
        }
    }
    
    func startGame() {
        ball.physicsBody!.isDynamic = true
        run(timerAction)
        run(cameraPan)
        gameOn = true
    }
    
    func jump() {
        if let body = ball.physicsBody, body.velocity.dy == 0
        {
            let jumpPower = CGFloat(800)
            body.applyImpulse(CGVector(dx: 0, dy: jumpPower))
        }
    }
    
    func endGame() {
        removeAllActions()
        endgameMessage.isHidden = false
        gameOn = false
    }
    
    
    // MARK: - Update
    
    override func update(_ currentTime: TimeInterval) {
        if gameOn {
            updateGravity()
            updateCamera()
            checkForWin()
        }
        
        // Initialize _lastUpdateTime if it has not already been:
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        // Calculate time since last update:
        let dt = currentTime - self.lastUpdateTime
        // Update entities:
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        self.lastUpdateTime = currentTime
    }
    
    func updateGravity() {
        if let accelerometerData = motionManager.accelerometerData {
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.x * 50, dy: -50)
        }
    }
    
    func updateCamera() {
        if ball.position.y < ballYPosMin {
            ballYPosMin = ball.position.y
        }
        if camera!.position.y > ballYPosMin {
            camera!.position.y = ballYPosMin
        }
    }
    
    func checkForWin() {
        if ball.position.y < -(backgroundHeight * (backgroundCount - 0.25)) - ball.size.height/2 {
            endGame()
        }
    }
}
