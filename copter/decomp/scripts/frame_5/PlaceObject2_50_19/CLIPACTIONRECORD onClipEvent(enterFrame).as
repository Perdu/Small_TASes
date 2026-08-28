onClipEvent(enterFrame){
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
         _Y = _root.wall1._y - _height / 2;
         broken = true;
         yspeed = 0;
         gravity = 0;
         scrollStart = false;
         this.gotoAndPlay("floor");
      }
      else if(_root.wall3._y >= _Y + yspeed - _height / 2)
      {
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
   if(_root.restart == true)
   {
      this.removeMovieClip();
   }
}
