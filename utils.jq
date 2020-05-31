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

# Flatten an object or array recursively into single list of
# key/values
#
# $delimeter: the delimiter between nested keys
# keyFormatter: filter used to format each nested key (eg. ascii_upcase)
#
# eg. echo '{ "a": { "b": 1 }, "c": 2 }' | jq -c 'deep_flatten("_"; .)'
#  {"a_b":1,"c":2}
#
# eg. echo '{ "a": { "b": 1 }, "c": 2 }' | jq -c 'deep_flatten("."; ascii_upcase)'
#  {"A.B":1,"C":2}
#
def deep_flatten($delimiter; keyFormatter):
  # Create internal recursive flatten function
  def _flatten:
    to_entries[] as { $key, $value } |
    $value |
    if type == "object" or type == "array"
      then _flatten |
        to_entries[0] |
        { (($key | tostring | keyFormatter) + $delimiter + .key): .value }
      else { ($key | tostring | keyFormatter): $value }
    end;
  # Merge key/values into single object
  [_flatten] | add;
