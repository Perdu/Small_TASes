onClipEvent(enterFrame){
   if(this._name != "trail")
   {
      this._x -= trailMoveSpeed;
      if(this._x < 0)
      {
         this.removeMovieClip();
      }
   }
}
