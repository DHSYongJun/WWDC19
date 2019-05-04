import SpriteKit
import AVFoundation

// Declare global constants
struct Constants {
    static let width = 800 as CGFloat
    static let height = 1200 as CGFloat
    static let paddleHeight = 150 as CGFloat
    static let ballRadius = 30 as CGFloat
}

// 4 types of collision objects possible
enum CollisionTypes: UInt32 {
    case Ball = 1
    case Wall = 2
    case Paddle = 4
    case Mirror = 8
}

// Paddle/Mirror direction
enum Direction: Int {
    case None = 0
    case Up = 1
    case Down = 2
}

// SpriteKit scene
public class gameScene: SKScene, SKPhysicsContactDelegate {
    let paddleSpeed = 800.0
    var direction = Direction.None
    var score = 0
    var highScore = 0
    var gameRunning = false
    var yCoord = 600
    var seconds = 25
    var gameTimer: Timer!
    var loopCount = 0

    // Screen elements
    var paddle: SKShapeNode?
    var ball: SKShapeNode?
    var mirror: SKShapeNode?
    var wall: SKShapeNode?
    var separator: SKShapeNode?
    let scoreLabel = SKLabelNode()
    let highScoreLabel = SKLabelNode()
    let timeLabel = SKLabelNode()

    // Initialize objects during first start
    public override func sceneDidLoad() {
        super.sceneDidLoad()
        scoreLabel.fontSize = 100
        scoreLabel.fontName = "SanFranciscoDisplay-Black"
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        scoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
        scoreLabel.position = CGPoint(x: Constants.width / 2, y: Constants.height - 75)
        self.addChild(scoreLabel)
        highScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        highScoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
        highScoreLabel.fontSize = 55
        highScoreLabel.fontName = "SanFranciscoDisplay-Semibold"
        highScoreLabel.position = CGPoint(x: Constants.width - 25, y: Constants.height - 75)
        self.addChild(highScoreLabel)
        timeLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        timeLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
        timeLabel.fontSize = 55
        timeLabel.fontName = "SanFranciscoDisplay-Semibold"
        timeLabel.position = CGPoint(x: Constants.ballRadius * 2, y: Constants.height - 75)
        self.addChild(timeLabel)

        createWalls()
        createSeparator()
        createBall(position: CGPoint(x: Constants.width / 2, y: Constants.height / 2))
        createPaddle()
        createMirror()
        startNewGame()
        self.physicsWorld.contactDelegate = self
    }

    // Create the ball sprite
    public func createBall(position: CGPoint) {
        let physicsBody = SKPhysicsBody(circleOfRadius: Constants.ballRadius)
        ball = SKShapeNode(circleOfRadius: Constants.ballRadius)
        physicsBody.categoryBitMask = CollisionTypes.Ball.rawValue
        physicsBody.collisionBitMask = CollisionTypes.Wall.rawValue | CollisionTypes.Ball.rawValue | CollisionTypes.Paddle.rawValue
        physicsBody.affectedByGravity = false
        physicsBody.restitution = 1.0
        physicsBody.linearDamping = 0
        physicsBody.velocity = CGVector(dx: 550, dy: 550)
        ball!.physicsBody = physicsBody
        ball!.position = position
        ball!.strokeColor = UIColor.clear
        ball!.fillColor = UIColor.white
    }

    // Create the walls
    public func createWall(rect: CGRect) {
        let wall = SKShapeNode(rect: rect)
        wall.strokeColor = UIColor.clear
        wall.fillColor = UIColor(hue: 0.45, saturation: 1, brightness: 0.66, alpha: 1)
        wall.physicsBody = getWallPhysicsbody(rect: rect)
        self.addChild(wall)
    }

    public func createWalls() {
        createWall(rect: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: Constants.ballRadius, height: Constants.height))) // left
        createWall(rect: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: Constants.width, height: Constants.ballRadius))) // bottom
        createWall(rect: CGRect(origin: CGPoint(x: 0, y: Constants.height - Constants.ballRadius), size: CGSize(width: Constants.width, height: Constants.ballRadius))) // top
    }

    // Create the physics objects to handle wall collisions
    public func getWallPhysicsbody(rect: CGRect) -> SKPhysicsBody {
        let physicsBody = SKPhysicsBody(rectangleOf: rect.size, center: CGPoint(x: rect.midX, y: rect.midY))
        physicsBody.affectedByGravity = false
        physicsBody.isDynamic = false
        physicsBody.collisionBitMask = CollisionTypes.Ball.rawValue
        physicsBody.categoryBitMask = CollisionTypes.Wall.rawValue
        physicsBody.contactTestBitMask = CollisionTypes.Ball.rawValue
        return physicsBody
    }

    // Create the separator sprite to differentiate top and bottom
    public func createSeparator() {
        separator =  SKShapeNode(rect: CGRect(origin: CGPoint.zero, size: CGSize(width: Constants.width - Constants.ballRadius, height: Constants.ballRadius / 3)))
        self.addChild(separator!)
        separator!.strokeColor = UIColor.clear
        separator!.fillColor = UIColor(hue: 0.11, saturation: 0.09, brightness: 0.99, alpha: 0.2)
    }

    // Create the paddle sprite & physics objects to handle paddle collisions
    public func createPaddle() {
        paddle =  SKShapeNode(rect: CGRect(origin: CGPoint.zero, size: CGSize(width: Constants.ballRadius, height: Constants.paddleHeight)))
        self.addChild(paddle!)
        paddle!.strokeColor = UIColor.clear
        paddle!.fillColor = UIColor(hue: 0.55, saturation: 1, brightness: 0.74, alpha: 1)
        let physicsBody = SKPhysicsBody(rectangleOf: paddle!.frame.size, center: CGPoint(x: paddle!.frame.midX, y: paddle!.frame.midY))
        physicsBody.affectedByGravity = false
        physicsBody.isDynamic = false
        physicsBody.collisionBitMask = CollisionTypes.Ball.rawValue
        physicsBody.categoryBitMask = CollisionTypes.Paddle.rawValue
        physicsBody.contactTestBitMask = CollisionTypes.Ball.rawValue
        paddle!.physicsBody = physicsBody
    }

    // Create the mirror sprite & physics objects to handle mirror collisions
    public func createMirror() {
        mirror = SKShapeNode(rect: CGRect(origin: CGPoint.zero, size: CGSize(width: Constants.ballRadius, height: Constants.paddleHeight * 1.4)))
        self.addChild(mirror!)
        mirror!.strokeColor = UIColor.clear
        mirror!.fillColor = UIColor(hue: 0.01, saturation: 0.81, brightness: 1, alpha: 1)
        let physicsBody = SKPhysicsBody(rectangleOf: mirror!.frame.size, center: CGPoint(x: mirror!.frame.midX, y: mirror!.frame.midY))
        physicsBody.affectedByGravity = false
        physicsBody.isDynamic = false
        physicsBody.collisionBitMask = CollisionTypes.Ball.rawValue
        physicsBody.categoryBitMask = CollisionTypes.Mirror.rawValue
        physicsBody.contactTestBitMask = CollisionTypes.Ball.rawValue
        mirror!.physicsBody = physicsBody
    }

    // Create function to update timer
    @objc public func updateTimer() {
        if gameRunning {
            timeLabel.text = "\(seconds)s left"
            seconds -= 1
        } else {
            gameTimer.invalidate()
            timeLabel.text = ""
        }
    }

    // Start a new game
    public func startNewGame() {
        score = 0
        seconds = 25
        scoreLabel.text = "\(score)"
        highScoreLabel.text = "Highest: \(highScore)"
        timeLabel.text = "\(seconds)s left"
        separator!.position = CGPoint(x: Constants.ballRadius, y: Constants.height / 2 - (Constants.ballRadius / 6))
        paddle!.position = CGPoint(x: Constants.width - Constants.ballRadius, y: Constants.height / 2 - Constants.paddleHeight / 2)
        mirror!.position = CGPoint(x: 0, y: Constants.height / 2 - (Constants.paddleHeight / 2 * 1.4))
        while yCoord >= 465 && yCoord <= 735 { // 495 - 30, 705 + 30 inclusive of radius of ball
            yCoord = Int.random(in: 0 ... 200 ) * 6 // greater variation
        }
        // Animated countdown
        let synthesizer = AVSpeechSynthesizer()
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let startLabel = SKLabelNode(text: "3")
        startLabel.position = CGPoint(x: Constants.width / 2, y: Constants.height / 2)
        startLabel.fontSize = 250
        startLabel.fontName = "SanFranciscoText-Black"
        self.addChild(startLabel)
        startLabel.text = "3"
        synthesizer.speak(AVSpeechUtterance(string: "3"))
        startLabel.run(SKAction.sequence([fadeIn, fadeOut]), completion: {
            startLabel.text = "2"
            synthesizer.speak(AVSpeechUtterance(string: "2"))
            startLabel.run(SKAction.sequence([fadeIn, fadeOut]), completion: {
                startLabel.text = "1"
                synthesizer.speak(AVSpeechUtterance(string: "1"))
                startLabel.run(SKAction.sequence([fadeIn, fadeOut]), completion: {
                    startLabel.text = "GO!"
                    synthesizer.speak(AVSpeechUtterance(string: "Go!"))
                    startLabel.run(SKAction.sequence([fadeIn, fadeOut]), completion: {
                        startLabel.removeFromParent()
                        self.gameRunning = true
                        self.ball!.position = CGPoint(x: 30, y: self.yCoord)
                        self.addChild(self.ball!)
                        self.gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
                    })
                })
            })
        })
    }

    // Handle touch events to move the paddle
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameRunning {
            for touch in touches {
                let location = touch.location(in: self)
                if location.y > Constants.height / 2 {
                    direction = Direction.Up
                } else if location.y < Constants.height / 2 {
                    direction = Direction.Down
                }
            }
        }
    }

    // Stop paddle movement
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        direction = Direction.None
    }

    // Game loop:
    // - Game status check
    // - Trigger paddle movement
    var dt = TimeInterval(0)
    public override func update(_ currentTime: TimeInterval) {
        if gameRunning {
            super.update(currentTime)
            checkGameStatus()
            if dt > 0 {
                movePaddle(dt: currentTime - dt)
            }
            dt = currentTime
        }
    }

    // Move the paddle up or down
    public func movePaddle(dt: TimeInterval) { // * dt to prevent paddle going out of screen
        if direction == Direction.Up && paddle!.position.y < Constants.height - Constants.paddleHeight {
            paddle!.position.y = paddle!.position.y + CGFloat(paddleSpeed * dt)
            mirror!.position.y = mirror!.position.y + CGFloat(paddleSpeed * dt)
        } else if direction == Direction.Down && paddle!.position.y > 0 {
            paddle!.position.y = paddle!.position.y - CGFloat(paddleSpeed * dt)
            mirror!.position.y = mirror!.position.y - CGFloat(paddleSpeed * dt)
        }
    }

    // Detect collisions between ball and paddle/mirror to vary the score
    public func didBegin(_ contact: SKPhysicsContact) {
        var dxSpeed = ball!.physicsBody!.velocity.dx
        var dySpeed = ball!.physicsBody!.velocity.dy
        var newDx = 6 + loopCount * 2
        var newDy = 4 + loopCount * 2
        if contact.bodyA.categoryBitMask == CollisionTypes.Paddle.rawValue || contact.bodyB.categoryBitMask == CollisionTypes.Paddle.rawValue {
            ball!.physicsBody!.applyImpulse(CGVector(dx: -newDx / 2, dy: 0))
            score += 1
            scoreLabel.text = "\(score)"
            // Sound effects obtained from https://www.zapsplat.com
            let hitSound = SKAction.playSoundFileNamed("Sounds/hit.mp3", waitForCompletion: true)
            run(hitSound)
        } else if contact.bodyA.categoryBitMask == CollisionTypes.Mirror.rawValue || contact.bodyB.categoryBitMask == CollisionTypes.Mirror.rawValue {
            seconds -= 3
            scoreLabel.text = "\(score)"
            ball!.physicsBody!.applyImpulse(CGVector(dx: newDx / 2, dy: 0))
            // Sound effects obtained from https://www.zapsplat.com
            let gaspSound = SKAction.playSoundFileNamed("Sounds/gasp.mp3", waitForCompletion: true)
            run(gaspSound)
        } else { // Prevent ball from only going up and down vertically
            if dxSpeed > 0 && dySpeed > 0 {
                ball!.physicsBody!.applyImpulse(CGVector(dx: newDx, dy: -newDy))
            } else if dxSpeed < 0 && dySpeed > 0 {
                ball!.physicsBody?.applyImpulse(CGVector(dx: -newDx, dy: -newDy))
            } else if dxSpeed > 0 && dySpeed < 0 {
                ball!.physicsBody!.applyImpulse(CGVector(dx: newDx, dy: newDy))
            } else {
                ball!.physicsBody!.applyImpulse(CGVector(dx: -newDx, dy: newDy))
            }
        }
    }

    public func checkGameStatus() {
        // Inform time running out
        if seconds == 5 {
            let warnSound = SKAction.playSoundFileNamed("Sounds/warning.mp3", waitForCompletion: false)
            run(warnSound)
        }
        // Check if the ball is still on screen/score less than 0/time elapsed
        if ball!.position.x > CGFloat(Constants.width - Constants.ballRadius) || score < 0 || seconds < 0 {
            if score > highScore {
                gameRunning = false
                ball!.removeFromParent()
                self.highScore = self.score
                highScoreLabel.text = "Highest: \(highScore)"
                let gameWonLabel = SKLabelNode(text: "Congrats, Top Scorer!")
                gameWonLabel.position = CGPoint(x: Constants.width / 2, y: Constants.height / 2)
                gameWonLabel.fontSize = 40
                gameWonLabel.fontName = "SanFranciscoText-Bold"
                self.addChild(gameWonLabel)
                let winSound = SKAction.playSoundFileNamed("Sounds/win.mp3", waitForCompletion: true)
                run(winSound)
                gameWonLabel.run(SKAction.scale(by: 1.8, duration: 2.5))
                gameWonLabel.run(SKAction.fadeAlpha(to: 0, duration: 5.5), completion: {
                    gameWonLabel.removeFromParent()
                    self.yCoord = 600
                    self.loopCount = 0
                    self.startNewGame()
                })
            } else {
                gameRunning = false
                ball!.removeFromParent()
                let gameOverLabel = SKLabelNode(text: "Game Over")
                gameOverLabel.position = CGPoint(x: Constants.width / 2, y: Constants.height / 2)
                gameOverLabel.fontSize = 80
                gameOverLabel.fontName = "SanFranciscoText-Bold"
                self.addChild(gameOverLabel)
                // Game Over animation
                let overSound = SKAction.playSoundFileNamed("Sounds/over.mp3", waitForCompletion: true)
                run(overSound)
                let rotateAction = SKAction.rotate(byAngle: CGFloat.pi, duration: 0.8)
                gameOverLabel.run(SKAction.repeat(rotateAction, count: 2))
                gameOverLabel.run(SKAction.scale(to: 0, duration: 3.5), completion: {
                    gameOverLabel.removeFromParent()
                    self.yCoord = 600
                    self.loopCount = 0
                    self.startNewGame()
                })
            }
        } else if score % 10 == 0 && score != 0 {
            // > 10s extra: 3pt, 5-9: 2pt, 1-4: 1pt
            if seconds >= 10 {
                score += 3
            } else if seconds >= 5 {
                score += 2
            } else {
                score += 1
            }
            scoreLabel.text = "\(score)"
            loopCount += 1
            seconds = 25 - loopCount * 2
            let clearSound = SKAction.playSoundFileNamed("Sounds/cleared.mp3", waitForCompletion: true)
            run(clearSound)
        }
    }
}