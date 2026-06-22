// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

extension GameState {
  func spawnGeisterstunde() {
    let count = Int.random(in: Self.ghostCount)
    ghosts = (0..<count).map { i in
      let spacing = screenWidth / CGFloat(count + 1)
      return Ghost(x: spacing * CGFloat(i + 1), y: topInset + 20)
    }
    goldenDots = []
    kristallkugel = nil
    geisterjagdActive = false
    geisterjagdTimer = 0
    kristallkugelSpawnCount = 0
  }

  func updateGhosts(dt: CGFloat) {
    guard !ghosts.isEmpty || geisterjagdActive else { return }

    if geisterjagdActive {
      geisterjagdTimer -= dt
      if geisterjagdTimer <= 0 {
        geisterjagdActive = false
        geisterjagdTimer = 0
        for i in ghosts.indices {
          if ghosts[i].phase == .fleeing {
            ghosts[i].phase = .exiting
            score += Self.ghostExitScore
          }
        }
      }
    }

    let descentStart = topInset + 20
    let descentRange = playerY - descentStart
    var dotsToAdd: [GoldenDot] = []

    for i in ghosts.indices {
      switch ghosts[i].phase {
      case .descending:
        ghosts[i].y += Self.ghostDescentSpeed * dt
        ghosts[i].dotTimer += dt
        if ghosts[i].dotTimer >= Self.dotDropInterval {
          dotsToAdd.append(GoldenDot(x: ghosts[i].x, y: ghosts[i].y))
          ghosts[i].dotTimer = 0
        }
        if kristallkugel == nil && kristallkugelSpawnCount < Self.kristallkugelMaxSpawns {
          let threshold = descentStart + descentRange * Self.kristallkugelThresholds[kristallkugelSpawnCount]
          if ghosts[i].y >= threshold {
            kristallkugel = Kristallkugel(x: ghosts[i].x, y: ghosts[i].y)
            kristallkugelSpawnCount += 1
          }
        }
        if ghosts[i].y >= playerY {
          ghosts[i].phase = .pursuing
        }
      case .pursuing:
        if kristallkugel == nil && kristallkugelSpawnCount < Self.kristallkugelMaxSpawns {
          kristallkugel = Kristallkugel(x: ghosts[i].x, y: (topInset + ghosts[i].y) / 2)
          kristallkugelSpawnCount += 1
        }
        let dx = playerX - ghosts[i].x
        let direction: CGFloat = dx > 0 ? 1 : -1
        ghosts[i].x += direction * Self.ghostPursuitSpeed * dt
      case .fleeing:
        let dx = ghosts[i].x - playerX
        let direction: CGFloat = dx > 0 ? 1 : -1
        ghosts[i].x += direction * Self.ghostFleeSpeed * dt
        ghosts[i].x = max(Self.ghostSize / 2, min(screenWidth - Self.ghostSize / 2, ghosts[i].x))
      case .devoured:
        ghosts[i].dotTimer += dt
      case .exiting:
        ghosts[i].y -= Self.ghostExitSpeed * dt
      }
    }

    goldenDots.append(contentsOf: dotsToAdd)
    ghosts.removeAll { ghost in
      switch ghost.phase {
      case .devoured:
        return ghost.dotTimer >= 0.3
      case .exiting:
        return ghost.y < -Self.ghostSize
      default:
        return false
      }
    }

    if ghosts.isEmpty && !geisterjagdActive && activeMechanic == .geisterstunde {
      activeMechanic = nil
      goldenDots = []
      kristallkugel = nil
    }
  }
}
