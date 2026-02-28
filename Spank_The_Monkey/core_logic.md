The core of the logic to handle all of this is:

```
function swayHand()
{
   if(bax.handState != "autoOff")
   {
      checkOffscreen();
   }
   getAccel();
   handFrame = hand._currentframe;
   handFrameOffset = (handFrame - 51) * -1;
   spring = handFrameOffset / springStrength * fps.speedFactor;
   if(handFrame < 51)
   {
      spring = Math.max(1,spring);
   }
   else if(51 < handFrame)
   {
      spring = Math.min(-1,spring);
   }
   else
   {
      spring = 0;
   }
   sway = vNew / wind;
   sway += spring;
   handFrameNew = handFrame + sway;
   handFrameNew = Math.max(handFrameNew,1);
   handFrameNew = Math.min(handFrameNew,100);
   hand.gotoAndStop(Math.round(handFrameNew));
   checkHit();
}

function checkHit()
{
   if(10 < hand._x && hand._x < 350)
   {
      if(Key.isDown(72))   // There's a small trick where you can just press h to get a score of 690
      {
         vNew = 690;
      }
      else
      {
         vNew = Math.floor(vNew);
      }
      if(slapSpeed < vNew && monkeyUp)
      {
         if(bigSlapSpeed < vNew)
         {
            resultText = "NICE ONE !\rYOU SPANKED THE MONKEY AT " + vNew + " MILES PER HOUR";
            monkey.gotoAndPlay("bigHit");
         }
         else
         {
            resultText = "YOU SPANKED THE MONKEY AT " + vNew + " MILES PER HOUR";
            monkey.gotoAndPlay("hit");
         }
         monkeyUp = 0;
         handRelease();
         offScreenHand();
      }
   }
}

function getAccel()
{
   xOld = xNew;
   xNew = hand._x;
   vNew = (xOld - xNew) / fps.speedFactor;
}
```
with:
```
   wind = 1.5;
   springStrength = 15;
   weight = 1;
   sway = 0;
   slapSpeed = 50;
   bigSlapSpeed = 200;
   offScreenX = -200;

```

and:
```
onClipEvent(enterFrame){
   if(_root.bax.handState == "auto" || _root.bax.handState == "endAuto" || _root.bax.handState == "autoOff")
   {
      slow = 6.1 * gain;
      var dX = _parent.destX - _parent._x;
      var parent_x_orig = _parent._x;
      var xSpeed_orig = xSpeed;
      xSpeed = (xSpeed + dx) * gain / slow;
      var dY = _parent.destY - _parent._y;
      ySpeed = (ySpeed + dy) * gain / slow;
      _parent._x += xSpeed;
      _parent._y += ySpeed;
      if(dx * dx + dy * dy < 2 && _root.bax.handState != "autoOff")
      {
         _root.bax.handState = "endAuto";
      }
   }
}
```
where:
```
onClipEvent(enterFrame){
   currentTicks = getTimer();
   frameDelay = currentTicks - oldTicks;
   speedFactor = frameDelay / targetDelay;
   if(0 >= speedFactor)
   {
      speedFactor = 1;
   }
   oldTicks = currentTicks;
}
```

