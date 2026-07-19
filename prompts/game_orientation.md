**Status:** ✅ executed in `bbdb8ec` — the orientation hack was replaced by a size-driven
reflow. Kept for the rationale.

Historically, Konjugieren's supported iPhone orientations were Portrait, Landscape Left, and Landscape Right. This was problematic for the game, which essentially must run in Protrait only. The solution we came up with, which I dislike, was to use a UIKit hack/wrapper to block rotation for the game but not other screens.

I have changed Konjugieren's supported iPhone orientations to Portrait only.

Konjugieren's supported iPad orientations remain all four. Given platform conventions, I believe these are appropriate. 

I would like you to do the following:

1. Remove the UIKit hack/wrapper.
2. Fix the initial game setup so that, on iPad, enemies have three times as much horizontal space between columns of enemies. This will fix the bunched-up look in ~/Desktop/iPad.png .
3. Port Conjugar's approach to handling iPad rotation: just redraw the board on device (iPad) rotation. Conjugar lives in ../Conjugar.mig .

Before you begin work, ask any questions you have and suggestion any other relevant changes.