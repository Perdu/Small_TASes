onClipEvent(load){
   y1 = this._y;
   y1Max = _root.movieHeight - this._height / 2 - 5;
   y1Min = this._height / 2 + 5;
   range = y1Max - y1Min;
   y2 = random(range) + this._height / 2;
   x = random(30) + 30;
   ySpeed = (y2 - y1) / x;
   shrinkSpeed = 0.08;
}
