def arrayToCsv:
  (.[0] | keys_unsorted) as $cols |
  map(
    . as $row |
    $cols |
    map(
      $row[.] as $val |
      $val |
      if type=="array"
        then (
          $val |
          map(
            . |
            if type=="object"
              then join(",")
              else .
            end
          ) |
          join("\n")
        )
        else $val
      end
    )
  ) as $rows |
  $cols,$rows[] |
  @csv;

