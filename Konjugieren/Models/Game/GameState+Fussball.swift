// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

extension GameState {
  func spawnFussball() {
    let angle = CGFloat.random(in: 0.3...0.8) * (Bool.random() ? 1 : -1)
    fussball = Fussball(
      x: screenWidth / 2,
      y: topInset + 50,
      velocityX: Self.fussballBaseSpeed * angle,
      velocityY: Self.fussballBaseSpeed * abs(1 - abs(angle)),
      remainingTime: Self.fussballDuration
    )
  }

  func updateFussball(dt: CGFloat) {
    guard var ball = fussball else { return }
    ball.remainingTime -= dt
    if ball.remainingTime <= 0 {
      fussball = nil
      if activeMechanic == .fussball {
        activeMechanic = nil
      }
      return
    }
    ball.x += ball.velocityX * dt
    ball.y += ball.velocityY * dt
    let half = Self.fussballSize / 2
    if ball.x <= half {
      ball.x = half
      ball.velocityX = abs(ball.velocityX) * Self.fussballSpeedUpPerBounce
      ball.velocityY *= Self.fussballSpeedUpPerBounce
      ball.bounceCount += 1
      Current.soundPlayer.play(.soccerKick, shouldDebounce: true)
    } else if ball.x >= screenWidth - half {
      ball.x = screenWidth - half
      ball.velocityX = -abs(ball.velocityX) * Self.fussballSpeedUpPerBounce
      ball.velocityY *= Self.fussballSpeedUpPerBounce
      ball.bounceCount += 1
      Current.soundPlayer.play(.soccerKick, shouldDebounce: true)
    }
    if ball.y <= topInset + half {
      ball.y = topInset + half
      ball.velocityY = abs(ball.velocityY) * Self.fussballSpeedUpPerBounce
      ball.velocityX *= Self.fussballSpeedUpPerBounce
      ball.bounceCount += 1
      Current.soundPlayer.play(.soccerKick, shouldDebounce: true)
    } else if ball.y >= screenHeight - half {
      ball.y = screenHeight - half
      ball.velocityY = -abs(ball.velocityY) * Self.fussballSpeedUpPerBounce
      ball.velocityX *= Self.fussballSpeedUpPerBounce
      ball.bounceCount += 1
      Current.soundPlayer.play(.soccerKick, shouldDebounce: true)
    }
    fussball = ball
  }
}
