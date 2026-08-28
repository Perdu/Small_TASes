onClipEvent(enterFrame){
   if(this._name != "obstacle" && _root.helicopter.scrollStart == true)
   {
      this._x -= scrollSpeed;
      if(this.hitTest(_root.helicopter))
      {
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
