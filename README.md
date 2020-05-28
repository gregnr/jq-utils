# `jq` utils

This is a collection of [`jq`](https://stedolan.github.io/jq/) functions I commonly use. They exist as [`jq` modules](https://stedolan.github.io/jq/manual/#Modules).

## Installation
Clone this repo into `~/.jq`:
```shell
$ git clone git@github.com:gregnr/jq-utils.git ~/.jq
```

## Using the functions
Import the module, then call the function:

```shell
echo '[{"Sport": "Tennis", "WinningScore": 30}]' | jq -r 'import "utils" as utils; utils::arrayToCsv'
```
