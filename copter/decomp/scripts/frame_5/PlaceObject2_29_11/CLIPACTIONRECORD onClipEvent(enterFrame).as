onClipEvent(enterFrame){
   if(_root.helicopter.scrollStart == true)
   {
      y1 = this._y;
      y1Max = _root.movieHeight - this._height / 2 - 5;
      y1Min = this._height / 2 + 5;
      range = y1Max - y1Min;
      if(y2 + 5 >= y1 && y1 >= y2 - 5)
      {
         y2 = random(range) + this._height / 2;
         x = random(60) + 1;
         ySpeed = (y2 - y1) / x;
      }
      this._y += ySpeed;
      if(180 < this._height)
      {
         this._height -= shrinkSpeed;
      }
   }
   if(_root.restart == true)
   {
      this.removeMovieClip();
   }
}
