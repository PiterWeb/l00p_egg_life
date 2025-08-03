open Raylib

let map_max_limit = 100.0
let map_min_limit = -.map_max_limit

let is_outside_map pos =
  (match Vector2.x pos with
    | x when x >= map_max_limit -> true
    | x when x <= map_min_limit -> true
    | _ -> false
  ) || (match Vector2.y pos with
    | y when y >= map_max_limit -> true
    | y when y <= map_min_limit -> true 
    | _ -> false
  )