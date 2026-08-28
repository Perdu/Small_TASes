onClipEvent(load){
   y1 = this._y;
   y1Max = _root.movieHeight - this._height / 2 - 5;
   y1Min = this._height / 2 + 5;
   range = y1Max - y1Min;
   y2 = random(range) + this._height / 2;
   x = random(30) + 30;
   ySpeed = (y2 - y1) / x;
   shrinkSpeed = 0.08;
   _root.dbgEvent++;
   trace("BC_LOAD"
      + " e=" + _root.dbgEvent
      + " f=" + _root.dbgFrame
      + " name=" + this._name
      + " y=" + this._y
      + " h=" + this._height
      + " y1=" + y1
      + " ymin=" + y1Min
      + " ymax=" + y1Max
      + " range=" + range
      + " y2=" + y2
      + " rng_target=" + (y2 - this._height / 2)
      + " x=" + x
      + " rng_duration=" + (x - 30)
      + " yspeed=" + ySpeed
      + " shrink=" + shrinkSpeed);
}
