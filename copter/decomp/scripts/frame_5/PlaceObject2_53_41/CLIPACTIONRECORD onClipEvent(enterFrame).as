onClipEvent(enterFrame){
   if(_root.helicopter.scrollStart == true)
   {
      if(flag == false)
      {
         flag = true;
         _root.wallBlock.duplicateMovieClip("wallBlock" + depthCounter,depthCounter);
         _root.wallBlock.duplicateMovieClip("wallBlock" + depthCounter + 1,depthCounter + 1);
         _root["wallBlock" + depthCounter]._y = _root.blockController._y - _root.blockController._height / 2 - _root.wallBlock._height / 2;
         _root["wallBlock" + depthCounter + 1]._y = _root.blockController._y + _root.blockController._height / 2 + _root.wallBlock._height / 2;
         _root.dbgEvent++;
         trace("WALL_SPAWN_INITIAL"
            + " e=" + _root.dbgEvent
            + " f=" + _root.dbgFrame
            + " depth=" + depthCounter
            + " ctl_y=" + _root.blockController._y
            + " ctl_h=" + _root.blockController._height
            + " ctl_yspeed=" + _root.blockController.ySpeed
            + " upper_x=" + _root["wallBlock" + depthCounter]._x
            + " upper_y=" + _root["wallBlock" + depthCounter]._y
            + " upper_w=" + _root["wallBlock" + depthCounter]._width
            + " upper_h=" + _root["wallBlock" + depthCounter]._height
            + " lower_x=" + _root["wallBlock" + depthCounter + 1]._x
            + " lower_y=" + _root["wallBlock" + depthCounter + 1]._y
            + " lower_w=" + _root["wallBlock" + depthCounter + 1]._width
            + " lower_h=" + _root["wallBlock" + depthCounter + 1]._height);
      }
      if(_root.wallBlock._x - 0.75 * _root.wallBlock._width >= _root["wallBlock" + depthCounter]._x && _root["wallBlock" + depthCounter]._x >= _root.wallBlock._x - 1.25 * _root.wallBlock._width)
      {
         depthCounter += 2;
         if(depthCounter >= 299)
         {
            depthCounter = 100;
         }
         _root.wallBlock.duplicateMovieClip("wallBlock" + depthCounter,depthCounter);
         _root.wallBlock.duplicateMovieClip("wallBlock" + depthCounter + 1,depthCounter + 1);
         _root["wallBlock" + depthCounter]._y = _root.blockController._y - _root.blockController._height / 2 - _root.wallBlock._height / 2;
         _root["wallBlock" + depthCounter + 1]._y = _root.blockController._y + _root.blockController._height / 2 + _root.wallBlock._height / 2;
         _root.dbgEvent++;
         trace("WALL_SPAWN"
            + " e=" + _root.dbgEvent
            + " f=" + _root.dbgFrame
            + " depth=" + depthCounter
            + " ctl_y=" + _root.blockController._y
            + " ctl_h=" + _root.blockController._height
            + " ctl_yspeed=" + _root.blockController.ySpeed
            + " upper_x=" + _root["wallBlock" + depthCounter]._x
            + " upper_y=" + _root["wallBlock" + depthCounter]._y
            + " lower_x=" + _root["wallBlock" + depthCounter + 1]._x
            + " lower_y=" + _root["wallBlock" + depthCounter + 1]._y);
      }
   }
}
