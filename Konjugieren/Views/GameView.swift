// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

struct GameView: View {
  @State private var gameState = GameState()
  @Environment(\.dismiss) private var dismiss
  @Environment(\.scenePhase) private var scenePhase

  var body: some View {
    GeometryReader { geometry in
      TimelineView(.animation) { timeline in
        let _ = gameState.update(currentTime: timeline.date)

        ZStack {
          Color.black.ignoresSafeArea()

          hud

          if gameState.phase == .playing || gameState.phase == .waveComplete {
            ForEach(gameState.enemies.filter(\.isAlive)) { enemy in
              Image(enemy.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .scaleEffect(
                  x: gameState.enemyDirection * (enemy.isDiving ? 1.3 : 1.0) * (enemy.imageName == "Hat" ? -1 : 1),
                  y: enemy.isDiving ? 1.3 : 1.0
                )
                .position(
                  x: enemy.isDiving ? enemy.x : enemy.x + gameState.sineOffset(forRow: enemy.row),
                  y: enemy.y
                )
            }

            ForEach(gameState.deathEffects) { effect in
              let scale = 1.0 - effect.progress
              let opacity = Double(scale)

              Image(effect.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .scaleEffect(scale)
                .opacity(opacity)
                .position(x: effect.x, y: effect.y)

              ForEach(0..<DeathEffect.particleCount, id: \.self) { i in
                let angle = Double(i) * (.pi * 2.0 / Double(DeathEffect.particleCount))
                let radius = CGFloat(effect.progress) * 25
                Circle()
                  .fill(effect.useRed ? Color.customRed : Color.customYellow)
                  .frame(width: 6 * scale, height: 6 * scale)
                  .opacity(opacity)
                  .position(
                    x: effect.x + CGFloat(cos(angle)) * radius,
                    y: effect.y + CGFloat(sin(angle)) * radius
                  )
              }
            }

            if let bullet = gameState.playerBullet {
              Text("🇩🇪")
                .font(.system(size: 20))
                .position(x: bullet.x, y: bullet.y)
            }

            if let bullet = gameState.enemyBullet {
              Text("🏴󠁧󠁢󠁥󠁮󠁧󠁿")
                .font(.system(size: 20))
                .position(x: bullet.x, y: bullet.y)
            }

            if let zigzagger = gameState.zigzagger {
              Text(zigzagger.emoji)
                .font(.system(size: 40))
                .scaleEffect(x: zigzagger.movingRight ? -1 : 1, y: 1)
                .position(x: zigzagger.x, y: zigzagger.y)
            }

            ForEach(gameState.coins) { coin in
              Text("🪙")
                .font(.system(size: 25))
                .position(x: coin.x, y: coin.y)
            }

            ForEach(gameState.powerUps) { powerUp in
              Group {
                if powerUp.kind == .bratwurst {
                  Image("BratwurstPowerUp")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                } else {
                  Text(powerUp.kind.emoji)
                    .font(.system(size: 30))
                }
              }
              .position(x: powerUp.x, y: powerUp.y)
            }

            ForEach(gameState.eggs) { egg in
              Text("🥚")
                .font(.system(size: 25))
                .position(x: egg.x, y: egg.y)
            }

            ForEach(gameState.hatchlings) { hatchling in
              Text("🐣")
                .font(.system(size: 25))
                .position(x: hatchling.x, y: hatchling.y)
            }

            if let ball = gameState.fussball {
              Text("⚽")
                .font(.system(size: 30))
                .position(x: ball.x, y: ball.y)
            }

            ForEach(gameState.wurstChains) { chain in
              ForEach(chain.segments) { seg in
                Image("BratwurstChain")
                  .resizable()
                  .scaledToFit()
                  .frame(width: 30, height: 30)
                  .position(x: seg.x, y: seg.y)
              }
            }

            ForEach(gameState.pretzelObstacles) { pretzel in
              Text("🥨")
                .font(.system(size: 30))
                .opacity(pretzel.opacity)
                .position(x: pretzel.x, y: pretzel.y)
            }

            ForEach(gameState.goldenDots) { dot in
              Image(systemName: "circle.fill")
                .font(.system(size: 12))
                .foregroundStyle(.customYellow)
                .position(x: dot.x, y: dot.y)
            }

            ForEach(gameState.ghosts) { ghost in
              Text(ghost.phase == .fleeing ? "😱" : ghost.phase == .devoured ? "💨" : "👻")
                .font(.system(size: 35))
                .position(x: ghost.x, y: ghost.y)
            }

            if let kugel = gameState.kristallkugel {
              Text("🔮")
                .font(.system(size: 25))
                .position(x: kugel.x, y: kugel.y)
            }

            if let side = gameState.portalSide {
              Image(systemName: "arrow.down")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.customYellow)
                .position(
                  x: side == .left ? 30 : gameState.screenWidth - 30,
                  y: gameState.playerY - 40 + 6 * sin(gameState.sineTime * 4)
                )
            }

            Image("Pretzel")
              .resizable()
              .scaledToFit()
              .frame(width: 40, height: 40)
              .opacity(max(0.1, gameState.playerHealth))
              .overlay {
                if gameState.shieldActive {
                  Circle()
                    .stroke(.cyan, lineWidth: 3)
                    .frame(width: 50, height: 50)
                    .opacity(0.6 + 0.4 * sin(gameState.sineTime * 3))
                }
              }
              .position(x: gameState.playerX, y: gameState.playerY)

            if gameState.phase == .waveComplete {
              waveCompleteOverlay
            }
          } else {
            gameOverOverlay
          }

        }
        .onTapGesture(coordinateSpace: .local) { _ in
          if gameState.phase == .playing {
            gameState.playerFire()
          } else if gameState.phase == .lost && gameState.canRestart {
            gameState.restartGame()
          }
        }
      }
      .onAppear {
        AppDelegate.orientationLock = .portrait
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
          windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
        }
        gameState.startGame(screenWidth: geometry.size.width, screenHeight: geometry.size.height, topInset: geometry.safeAreaInsets.top)
      }
    }
    .onDisappear {
      gameState.stopMotion()
      AppDelegate.orientationLock = .allButUpsideDown
    }
    .onChange(of: scenePhase) { _, newPhase in
      switch newPhase {
      case .active:
        gameState.resumeMotion()
      case .inactive, .background:
        gameState.stopMotion()
      @unknown default:
        break
      }
    }
    .statusBarHidden()
    .preferredColorScheme(.dark)
  }

  private var healthColor: Color {
    let percent = Int(gameState.playerHealth * 100)
    if percent > 66 {
      return .green
    } else if percent > 33 {
      return .customYellow
    } else {
      return .customRed
    }
  }

  private var hud: some View {
    VStack {
      HStack {
        Button {
          dismiss()
        } label: {
          Image(systemName: "xmark.circle.fill")
            .font(.title2)
            .foregroundStyle(.customYellow)
        }

        Spacer()

        VStack(spacing: 2) {
          Text("\(L.Game.score) \(gameState.score)")
            .font(.caption)
            .bold()
            .foregroundStyle(.customYellow)

          Text("\(L.Game.wave) \(gameState.wave)")
            .font(.caption)
            .bold()
            .foregroundStyle(.customYellow)
        }

        Spacer()

        Text("\(L.Game.health) \(Int(gameState.playerHealth * 100))%")
          .font(.caption)
          .bold()
          .foregroundStyle(healthColor)

        if gameState.geisterjagdActive {
          Image(systemName: "wand.and.stars.inverse")
            .font(.caption)
            .foregroundStyle(.customYellow)
            .opacity(0.6 + 0.4 * sin(gameState.sineTime * 4))
        }
      }
      .padding(.horizontal)

      Spacer()
    }
  }

  private var waveCompleteOverlay: some View {
    ZStack {
      Color.black.opacity(0.5)
        .ignoresSafeArea()

      waveCompleteParticles

      Text("\(L.Game.waveScore) \(gameState.lastWaveScore)")
        .font(.title)
        .bold()
        .foregroundStyle(.customYellow)
    }
  }

  private var waveCompleteParticles: some View {
    TimelineView(.animation) { timeline in
      let time = timeline.date.timeIntervalSince1970
      Canvas { context, size in
        for i in 0..<40 {
          let seed = Double(i) * 137.508
          let baseX = (seed.truncatingRemainder(dividingBy: 1.0) + Double(i) * 0.025).truncatingRemainder(dividingBy: 1.0) * size.width
          let baseY = (seed * 0.618).truncatingRemainder(dividingBy: 1.0) * size.height
          let floatOffset = sin(time * 1.5 + seed) * 20
          let radius = 3.0 + (seed * 0.3).truncatingRemainder(dividingBy: 5.0)
          let rect = CGRect(x: baseX - radius, y: baseY + floatOffset - radius, width: radius * 2, height: radius * 2)
          context.fill(Path(ellipseIn: rect), with: .color(i.isMultiple(of: 2) ? .customRed : .customYellow))
        }
      }
    }
  }

  private var gameOverOverlay: some View {
    ZStack {
      Color.black.opacity(0.7)
        .ignoresSafeArea()

      VStack(spacing: 20) {
        Text(L.Game.gameOver)
          .font(.largeTitle)
          .bold()
          .foregroundStyle(.customRed)

        Text("\(L.Game.finalScore) \(gameState.finalScore)")
          .font(.title2)
          .foregroundStyle(.customYellow)

        if gameState.finalScore >= gameState.highScore && gameState.highScore > 0 {
          Text("\(L.Game.newHighScore) \(gameState.highScore)")
            .font(.headline)
            .foregroundStyle(.green)
        }

        Text(L.Game.tapToPlayAgain)
          .font(.body)
          .foregroundStyle(.white)
          .padding(.top, 10)

        Button(L.Game.quit) {
          dismiss()
        }
        .funButton()
        .padding(.top, 10)
      }
    }
  }
}
