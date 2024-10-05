# ni.bash

ni for bash

## Installation

```bash
$ curl -o ni.bash https://raw.githubusercontent.com/sasaplus1/ni.bash/main/ni.bash
$ source ni.bash
```

## Usage

```bash
$ ni --help
Usage: ni [command] [options...] [args...]

  a, aa                                alias of package manager
  add [-D | --save-dev] <packages...>  same as add
  ci                                   same as ci
  dlx, npx [args...]                   same as dlx
  i, install                           same as install
  rm, remove <packages...>             same as remove
  run <script> [args...]               same as run
  t, test [args...]                    same as test
  up, upgrade                          same as upgrade
  which                                show package manager name

Usage: ni [option]

  -h, --help     show this message
  -v, --version  show version
```

## Requirements

- jq or node.js

## Inspired by

- https://github.com/antfu-collective/ni
- https://github.com/azu/ni.zsh

## License

The MIT license
