/*:
 # Speed Pong!
 ## GET READY FOR RUSH HOUR ... with Pong

 ## How to Play
 Tap the bottom half of the Live View to move the racket down, top half to move the racket up.

 But be careful, if you hit the red zone, your time is shortened.

 You must get a certain score within the time limit or else the game is over.

 Every 10 points you get, you earn 1-3 bonus points depending on how fast you progress.

 Be warned, the time will get shorter and the ball faster.

 Good luck!

 Made with ❤️ by Lim Yong Jun on an iPad (mostly) in Swift Playgrounds 2.2.

 Disclaimer: Play the game in landscape orientation. 👍
*/

//#-hidden-code
import AVFoundation
import SpriteKit
import PlaygroundSupport

// Initialize the playground and start the scene:

let sceneView = SKView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 800, height: 1200)))
let scene = gameScene(size: sceneView.frame.size)
sceneView.presentScene(scene)

PlaygroundPage.current.liveView = sceneView
//#-end-hidden-code