onClipEvent(mouseDown){
   _root.dbgEvent++;
   trace("INPUT_DOWN"
      + " e=" + _root.dbgEvent
      + " f=" + _root.dbgFrame
      + " y=" + this._y
      + " yspeed=" + yspeed);
   fly = true;
   if(broken != true)
   {
      downSound.stop();
      upSound.start();
   }
}
