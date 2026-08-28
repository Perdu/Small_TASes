onClipEvent(load){
   this.swapDepths(500);
   _root.trail._visible = false;
   depthCounter = 1;
   gravity = 0;
   friction = 0.9;
   scrollx = _root.mainGround.ground._width / 2;
   scrollStart = false;
   maxScrollSpeed = 30;
   trailStart = 1;
   upSound = new Sound();
   upSound.attachSound("upSound");
   downSound = new Sound();
   downSound.attachSound("downSound");
   upSound.setVolume(50);
   downSound.setVolume(100);
   _root.dbgEvent++;
   trace("HELI_LOAD"
      + " e=" + _root.dbgEvent
      + " f=" + _root.dbgFrame
      + " x=" + this._x
      + " y=" + this._y
      + " w=" + this._width
      + " h=" + this._height
      + " gravity=" + gravity
      + " friction=" + friction
      + " scrollStart=" + scrollStart
      + " maxScroll=" + maxScrollSpeed);
}
