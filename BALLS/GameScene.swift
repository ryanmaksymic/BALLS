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

enum GameState {
    case newGame, gameOn, gameOver, gameWon
}

class GameScene: SKScene
{
    // MARK: - Properties
    
    var motionManager : CMMotionManager!
    
    var timerCount: Int!
    var timerLabel: SKLabelNode!
    var timerAction: SKAction!
    
    var endgameAlert: SKSpriteNode!
    var endgameMessage: SKLabelNode!
    var endgameAction: SKLabelNode!
    
    var ball: SKSpriteNode!
    var ballYPosMin: CGFloat!
    
    var cameraPan: SKAction!
    
    var gameState = GameState.newGame
    
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
        setUpEndgameAlert()
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
            SKAction.wait(forDuration: 0.01),
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
    }
    
    func setUpEndgameAlert() {
        endgameAlert = camera?.childNode(withName: "engameAlert") as! SKSpriteNode
        endgameMessage = endgameAlert?.childNode(withName: "endgameMessage") as! SKLabelNode
        endgameAction = endgameAlert?.childNode(withName: "endgameAction") as! SKLabelNode
        endgameAlert.isHidden = true
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
        switch gameState {
        case .newGame:
            startGame()
        case .gameOver:
            if nodes(at: touches.first!.location(in: self)).first == endgameAction {
                restartGame()
            }
        case .gameOn:
            fallthrough
        default:
            jump()
        }
    }
    
    func startGame() {
        ball.physicsBody!.isDynamic = true
        run(timerAction)
        run(cameraPan)
        gameState = .gameOn
    }
    
    func jump() {
        if let body = ball.physicsBody, body.velocity.dy == 0
        {
            let jumpPower = CGFloat(800)
            body.applyImpulse(CGVector(dx: 0, dy: jumpPower))
        }
    }
    
    func endGame(win: Bool) {
        removeAllActions()
        ball.physicsBody!.isDynamic = false
        endgameMessage.text = win ? "YOU WIN!" : "GAME OVER!"
        endgameAction.text = win ? "CONTINUE" : "TRY AGAIN"
        endgameAlert.isHidden = false
        gameState = .gameOver
    }
    
    func restartGame() {
        if let scene = GKScene(fileNamed: "GameScene"), let sceneNode = scene.rootNode as? GameScene {
            let transition = SKTransition.fade(withDuration: 0.5)
            sceneNode.scaleMode = SKSceneScaleMode.fill
            self.view!.presentScene(sceneNode, transition: transition)
        }
    }
    
    
    // MARK: - Update
    
    override func update(_ currentTime: TimeInterval) {
        if gameState == .gameOn {
            updateGravity()
            updateCamera()
            checkForWin()
            checkForLoss()
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
            endGame(win: true)
        }
    }
    
    func checkForLoss() {
        if ballYPosMin > (camera!.position.y + self.frame.size.height/2 + ball.frame.size.height/2) && camera!.position.y < -100 {
            endGame(win: false)
        }
    }
}
