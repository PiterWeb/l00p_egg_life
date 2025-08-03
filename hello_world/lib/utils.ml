let count_if predicate lst =
  List.fold_left (fun acc x -> if predicate x then acc + 1 else acc) 0 (List.flatten lst)