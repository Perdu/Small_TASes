onClipEvent(enterFrame){
   if(_root.helicopter.scrollStart == true)
   {
      distance += 1;
   }
   if(_root.restart == true)
   {
      if(_root.best < distance)
      {
         _root.best = distance;
      }
      this.removeMovieClip();
   }
}
