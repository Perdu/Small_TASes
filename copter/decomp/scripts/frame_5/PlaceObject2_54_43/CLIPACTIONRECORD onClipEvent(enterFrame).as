onClipEvent(enterFrame){
   if(_root.helicopter.scrollStart == true)
   {
      if(flag == false)
      {
         flag = true;
         _root.obstacle.duplicateMovieClip("obstacle" + depthCounter,depthCounter);
         _root["obstacle" + depthCounter]._y = random(100) + 100;
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
      }
   }
}
