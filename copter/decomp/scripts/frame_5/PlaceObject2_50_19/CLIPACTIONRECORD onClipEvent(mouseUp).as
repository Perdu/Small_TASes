onClipEvent(mouseUp){
   _root.dbgEvent++;
   trace("INPUT_UP"
      + " e=" + _root.dbgEvent
      + " f=" + _root.dbgFrame
      + " y=" + this._y
      + " yspeed=" + yspeed);
   fly = false;
   if(broken != true)
   {
      upSound.stop();
      downSound.start();
   }
}
