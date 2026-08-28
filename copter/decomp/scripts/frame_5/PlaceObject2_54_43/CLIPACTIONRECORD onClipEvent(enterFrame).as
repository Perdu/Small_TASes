onClipEvent(enterFrame){
   _root.dbgEvent++;
   trace("OBSGEN_TICK"
      + " e=" + _root.dbgEvent
      + " f=" + _root.dbgFrame);
   if(_root.helicopter.scrollStart == true)
   {
      if(flag == false)
      {
         flag = true;
         _root.obstacle.duplicateMovieClip("obstacle" + depthCounter,depthCounter);
         _root["obstacle" + depthCounter]._y = random(100) + 100;
         _root.dbgEvent++;
         trace("OBS_SPAWN_INITIAL"
            + " e=" + _root.dbgEvent
            + " f=" + _root.dbgFrame
            + " depth=" + depthCounter
            + " name=" + _root["obstacle" + depthCounter]._name
            + " x=" + _root["obstacle" + depthCounter]._x
            + " y=" + _root["obstacle" + depthCounter]._y
            + " w=" + _root["obstacle" + depthCounter]._width
            + " h=" + _root["obstacle" + depthCounter]._height
            + " rng=" + (_root["obstacle" + depthCounter]._y - 100)
            + " rootScroll=" + _root.scrollSpeed);
      }
      if(_root.movieWidth / 2 >= _root["obstacle" + depthCounter]._x && _root.movieWidth / 2 - _root.obstacle._width >= _root["obstacle" + depthCounter]._x)
      {
         depthCounter++;
         if(depthCounter >= 420)
         {
            depthCounter = 400;
         }
         _root.obstacle.duplicateMovieClip("obstacle" + depthCounter,depthCounter);
         _root["obstacle" + depthCounter]._y = random(100) + 100;
         _root.dbgEvent++;
         trace("OBS_SPAWN"
            + " e=" + _root.dbgEvent
            + " f=" + _root.dbgFrame
            + " depth=" + depthCounter
            + " name=" + _root["obstacle" + depthCounter]._name
            + " x=" + _root["obstacle" + depthCounter]._x
            + " y=" + _root["obstacle" + depthCounter]._y
            + " w=" + _root["obstacle" + depthCounter]._width
            + " h=" + _root["obstacle" + depthCounter]._height
            + " rng=" + (_root["obstacle" + depthCounter]._y - 100)
            + " rootScroll=" + _root.scrollSpeed);
      }
   }
}
