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

          ForEach(gameState.enemies.filter(\.isAlive)) { enemy in
            Image(enemy.imageName)
              .resizable()
              .scaledToFit()
              .frame(width: 30, height: 30)
              .position(
                x: enemy.x + gameState.sineOffset(forRow: enemy.row),
                y: enemy.y
              )
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

          if let horse = gameState.horse {
            Text("🐎")
              .font(.system(size: 40))
              .scaleEffect(x: horse.movingRight ? -1 : 1, y: 1)
              .position(x: horse.x, y: horse.y)
          }

          Image("Pretzel")
            .resizable()
            .scaledToFit()
            .frame(width: 40, height: 40)
            .opacity(max(0.1, gameState.playerHealth))
            .position(x: gameState.playerX, y: gameState.playerY)

          if gameState.phase != .playing {
            gameOverOverlay
          }
        }
        .onTapGesture {
          if gameState.phase == .playing {
            gameState.playerFire()
          } else {
            gameState.restartGame()
          }
        }
      }
      .onAppear {
        gameState.startGame(screenWidth: geometry.size.width, screenHeight: geometry.size.height, topInset: geometry.safeAreaInsets.top)
      }
    }
    .onDisappear {
      gameState.stopMotion()
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

        Text("\(L.Game.score) \(gameState.score)")
          .font(.caption)
          .bold()
          .foregroundStyle(.customYellow)

        Spacer()

        Text("\(L.Game.health) \(Int(gameState.playerHealth * 100))%")
          .font(.caption)
          .bold()
          .foregroundStyle(healthColor)
      }
      .padding(.horizontal)

      Spacer()
    }
  }

  private var gameOverOverlay: some View {
    ZStack {
      Color.black.opacity(0.7)
        .ignoresSafeArea()

      VStack(spacing: 20) {
        Text(gameState.phase == .won ? L.Game.youWin : L.Game.gameOver)
          .font(.largeTitle)
          .bold()
          .foregroundStyle(gameState.phase == .won ? .green : .customRed)

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
