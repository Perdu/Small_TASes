onClipEvent(enterFrame){
   if(this._name != "obstacle" && _root.helicopter.scrollStart == true)
   {
      if(this._x >= 100 && this._x <= 180)
      {
         _root.dbgEvent++;
         trace("MOVING_PRE"
            + " e=" + _root.dbgEvent
            + " f=" + _root.dbgFrame
            + " src=PO30_13"
            + " name=" + this._name
            + " x=" + this._x
            + " y=" + this._y
            + " w=" + this._width
            + " h=" + this._height
            + " heli_x=" + _root.helicopter._x
            + " heli_y=" + _root.helicopter._y
            + " heli_vy=" + _root.helicopter.yspeed);
      }
      this._x -= scrollSpeed;
      if(this._x >= 100 && this._x <= 180)
      {
         _root.dbgEvent++;
         trace("MOVING_POST"
            + " e=" + _root.dbgEvent
            + " f=" + _root.dbgFrame
            + " src=PO30_13"
            + " name=" + this._name
            + " x=" + this._x
            + " y=" + this._y
            + " w=" + this._width
            + " h=" + this._height
            + " heli_x=" + _root.helicopter._x
            + " heli_y=" + _root.helicopter._y
            + " heli_vy=" + _root.helicopter.yspeed);
      }
      if(this.hitTest(_root.helicopter))
      {
         _root.dbgEvent++;
         trace("HIT_PO30_13"
            + " e=" + _root.dbgEvent
            + " f=" + _root.dbgFrame
            + " clip=" + this._name
            + " x=" + this._x
            + " y=" + this._y
            + " w=" + this._width
            + " h=" + this._height
            + " heli_x=" + _root.helicopter._x
            + " heli_y=" + _root.helicopter._y
            + " heli_w=" + _root.helicopter._width
            + " heli_h=" + _root.helicopter._height
            + " heli_vy=" + _root.helicopter.yspeed);
         _root.helicopter.broken = true;
         _root.helicopter.yspeed = 0;
         _root.helicopter.gravity = 0;
         _root.helicopter.scrollStart = false;
         _root.helicopter.play();
      }
      if(0 >= this._x)
      {
         this.removeMovieClip();
      }
   }
   if(_root.restart == true)
   {
      this.removeMovieClip();
   }
}
