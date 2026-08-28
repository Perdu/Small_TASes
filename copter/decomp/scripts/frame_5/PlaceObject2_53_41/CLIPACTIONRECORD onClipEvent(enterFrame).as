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
      }
   }
}
