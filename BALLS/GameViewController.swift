//
//  GameViewController.swift
//  BALLS
//
//  Created by Ryan Maksymic on 2018-02-17.
//  Copyright © 2018 Ryan Maksymic. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController
{
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    // Load 'GameScene.sks' as a GKScene:
    if let scene = GKScene(fileNamed: "GameScene")
    {
      // Get the SKScene from the loaded GKScene:
      if let sceneNode = scene.rootNode as! GameScene?
      {
        
        // Copy gameplay related content over to the scene:
        sceneNode.entities = scene.entities
        sceneNode.graphs = scene.graphs
        
        // Set the scale mode to scale to fit the window:
        sceneNode.scaleMode = .aspectFill
        
        // Present the scene:
        if let view = self.view as! SKView?
        {
          view.presentScene(sceneNode)
          
          view.ignoresSiblingOrder = true
          
          //view.showsFPS = true
          //view.showsNodeCount = true
          //view.showsPhysics = true
        }
      }
    }
  }
  
  override var shouldAutorotate: Bool
  {
    return true
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask
  {
    return .portrait
  }
  
  override func didReceiveMemoryWarning()
  {
    super.didReceiveMemoryWarning()
  }
  
  override var prefersStatusBarHidden: Bool
  {
    return true
  }
}
