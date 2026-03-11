open Raylib

let width = get_screen_width()
let height = get_screen_height()

let setup () =
  init_window width height "lOOp Egg life";
  set_target_fps 70;
  toggle_fullscreen ();
  hide_cursor()