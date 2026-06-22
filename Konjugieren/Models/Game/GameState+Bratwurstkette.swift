// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

extension GameState {
  func spawnBratwurstkette() {
    var segments: [WurstSegment] = []
    let startX = (screenWidth - CGFloat(Self.wurstSegmentCount - 1) * Self.wurstSegmentSpacing) / 2
    let startY = topInset + 30
    for i in 0..<Self.wurstSegmentCount {
      segments.append(WurstSegment(x: startX + CGFloat(i) * Self.wurstSegmentSpacing, y: startY))
    }
    wurstChains = [WurstChain(segments: segments, movingRight: Bool.random(), speed: Self.wurstBaseSpeed)]
  }

  func updateWurstChains(dt: CGFloat) {
    guard !wurstChains.isEmpty else { return }
    var chainsToRemove: [UUID] = []
    for i in wurstChains.indices {
      let nearPlayer = wurstChains[i].segments.contains { abs($0.y - playerY) < 100 }
      let speed = nearPlayer
        ? wurstChains[i].speed * Self.wurstPlayerRowSpeedMultiplier
        : wurstChains[i].speed
      let dx = speed * dt * (wurstChains[i].movingRight ? 1 : -1)
      var hitEdge = false
      for j in wurstChains[i].segments.indices {
        wurstChains[i].segments[j].x += dx
        let half = Self.wurstSegmentSize / 2
        if wurstChains[i].segments[j].x <= half || wurstChains[i].segments[j].x >= screenWidth - half {
          hitEdge = true
        }
      }
      if hitEdge {
        wurstChains[i].movingRight.toggle()
        for j in wurstChains[i].segments.indices {
          wurstChains[i].segments[j].y += Self.wurstDescentStep
          let half = Self.wurstSegmentSize / 2
          wurstChains[i].segments[j].x = max(half, min(screenWidth - half, wurstChains[i].segments[j].x))
        }
      }
      if wurstChains[i].segments.allSatisfy({ $0.y > screenHeight + Self.wurstSegmentSize }) {
        chainsToRemove.append(wurstChains[i].id)
      }
    }
    wurstChains.removeAll { chain in chainsToRemove.contains(chain.id) }
    if wurstChains.isEmpty && activeMechanic == .bratwurstkette {
      activeMechanic = nil
    }
  }

  func updatePretzelOpacities(dt: CGFloat) {
    let fadeSpeed: CGFloat = 3.0
    for i in pretzelObstacles.indices {
      let target: CGFloat = switch pretzelObstacles[i].hitsRemaining {
      case 2:
        1.0
      case 1:
        0.5
      default:
        0.0
      }
      if pretzelObstacles[i].opacity > target {
        pretzelObstacles[i].opacity = max(target, pretzelObstacles[i].opacity - fadeSpeed * dt)
      }
    }
    pretzelObstacles.removeAll { $0.opacity <= 0 }
  }
}
