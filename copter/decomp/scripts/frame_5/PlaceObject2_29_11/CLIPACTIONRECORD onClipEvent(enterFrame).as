onClipEvent(enterFrame){
   _root.dbgEvent++;
   trace("BC_TICK"
      + " e=" + _root.dbgEvent
      + " f=" + _root.dbgFrame
      + " y=" + this._y
      + " h=" + this._height
      + " ys=" + ySpeed
      + " y2=" + y2);
   if(_root.helicopter.scrollStart == true)
   {
      y1 = this._y;
      y1Max = _root.movieHeight - this._height / 2 - 5;
      y1Min = this._height / 2 + 5;
      range = y1Max - y1Min;
      if(y2 + 5 >= y1 && y1 >= y2 - 5)
      {
         y2 = random(range) + this._height / 2;
         x = random(60) + 1;
         ySpeed = (y2 - y1) / x;
         _root.dbgEvent++;
         trace("BC_RETARGET"
            + " e=" + _root.dbgEvent
            + " f=" + _root.dbgFrame
            + " y=" + this._y
            + " h=" + this._height
            + " y1=" + y1
            + " y2=" + y2
            + " range=" + range
            + " rng_target=" + (y2 - this._height / 2)
            + " x=" + x
            + " rng_duration=" + (x - 1)
            + " yspeed=" + ySpeed);
      }
      this._y += ySpeed;
      if(180 < this._height)
      {
         this._height -= shrinkSpeed;
      }
   }
   if(_root.restart == true)
   {
      this.removeMovieClip();
   }
}
