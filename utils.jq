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
# $delimiter: the delimiter between nested keys
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

# Flatten an object or array recursively to be used as
# environment variables
#
# eg. echo '{ "database": { "port": 1234 } }' | jq -r 'to_env'
#   DATABASE_PORT=1234
#
# eg. echo '["a", "b", "c"]' | jq -r '{ config: . } | to_env'
#   CONFIG_0=a
#   CONFIG_1=b
#   CONFIG_2=c
#
def to_env:
  deep_flatten("_"; ascii_upcase) |
  to_entries[] |
  [.key, .value] |
  join("=");