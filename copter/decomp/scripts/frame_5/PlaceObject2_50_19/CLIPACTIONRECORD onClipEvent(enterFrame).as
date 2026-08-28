onClipEvent(enterFrame){
   _root.dbgEvent++;
   trace("HB_PRE"
      + " e=" + _root.dbgEvent
      + " f=" + _root.dbgFrame
      + " cf=" + this._currentframe
      + " tf=" + this._totalframes
      + " rot=" + this._rotation
      + " x=" + this._x
      + " y=" + this._y
      + " w=" + this._width
      + " h=" + this._height
      + " vy=" + yspeed
      + " fly=" + fly);
   _root.dbgFrame++;
   _root.dbgEvent++;
   trace("HELI_PRE"
      + " e=" + _root.dbgEvent
      + " f=" + _root.dbgFrame
      + " x=" + this._x
      + " y=" + this._y
      + " w=" + this._width
      + " h=" + this._height
      + " xspeed=" + xspeed
      + " yspeed=" + yspeed
      + " fly=" + fly
      + " gravity=" + gravity
      + " friction=" + friction
      + " broken=" + broken
      + " crashed=" + crashed
      + " scrollStart=" + scrollStart
      + " localScroll=" + scrollSpeed
      + " rootScroll=" + _root.scrollSpeed);
   if(broken != true)
   {
      scrollSpeed = this._x / _root.mainGround.ground._width * maxScrollSpeed + 2;
      if(fly == true && crashed != true)
      {
         yspeed -= 2;
         gravity = 1.25;
         scrollStart = true;
         this._rotation = -5;
      }
      if(fly == false)
      {
         this._rotation = 1;
      }
      if(scrollStart == true)
      {
         _root.trail.duplicateMovieClip("trail" + depthCounter,depthCounter);
         _root["trail" + depthCounter]._visible = true;
         _root["trail" + depthCounter]._y = this._y;
         depthCounter++;
         if(depthCounter >= 99)
         {
            depthCounter = 1;
         }
      }
      yspeed += gravity;
      yspeed *= friction;
      if(_Y + yspeed + _height / 2 >= _root.wall1._y)
      {
         _root.dbgEvent++;
         trace("HELI_FLOOR_COLLISION"
            + " e=" + _root.dbgEvent
            + " f=" + _root.dbgFrame
            + " y=" + _Y
            + " nextY=" + (_Y + yspeed)
            + " yspeed=" + yspeed
            + " heli_h=" + _height
            + " floor_y=" + _root.wall1._y);
         _Y = _root.wall1._y - _height / 2;
         broken = true;
         yspeed = 0;
         gravity = 0;
         scrollStart = false;
         this.gotoAndPlay("floor");
      }
      else if(_root.wall3._y >= _Y + yspeed - _height / 2)
      {
         _root.dbgEvent++;
         trace("HELI_CEILING_COLLISION"
            + " e=" + _root.dbgEvent
            + " f=" + _root.dbgFrame
            + " y=" + _Y
            + " nextY=" + (_Y + yspeed)
            + " yspeed=" + yspeed
            + " heli_h=" + _height
            + " ceil_y=" + _root.wall3._y);
         _Y = _root.wall3._y + _height / 2;
         yspeed = - yspeed;
      }
      else
      {
         _Y = _Y + yspeed;
      }
      if(_X + xspeed + _width / 2 >= _root.wall2._x)
      {
         _X = _root.wall2._x - _width / 2;
         xspeed = - xspeed;
      }
      else if(_root.wall4._x >= _X + xspeed - _width / 2)
      {
         _X = _root.wall4._x + _width / 2;
         xspeed = - xspeed;
      }
      else
      {
         _X = _X + xspeed;
      }
      xspeed *= friction;
   }
   _root.dbgEvent++;
   trace("HELI_POST"
      + " e=" + _root.dbgEvent
      + " f=" + _root.dbgFrame
      + " x=" + this._x
      + " y=" + this._y
      + " xspeed=" + xspeed
      + " yspeed=" + yspeed
      + " fly=" + fly
      + " gravity=" + gravity
      + " broken=" + broken
      + " crashed=" + crashed
      + " scrollStart=" + scrollStart
      + " localScroll=" + scrollSpeed);
   _root.dbgEvent++;
   trace("HB_POST"
      + " e=" + _root.dbgEvent
      + " f=" + _root.dbgFrame
      + " cf=" + this._currentframe
      + " tf=" + this._totalframes
      + " rot=" + this._rotation
      + " x=" + this._x
      + " y=" + this._y
      + " w=" + this._width
      + " h=" + this._height
      + " vy=" + yspeed
      + " fly=" + fly);
   if(_root.restart == true)
   {
      this.removeMovieClip();
   }
}
