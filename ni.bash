#!/bin/bash
# NOTE: shebang need for shellcheck

### detect package manager
__ni-detect-package-manager() {
  local packageManager=
  local packageManagerName=
  local packageManagerVersion=

  if [ -f 'package.json' ]
  then
    if type jq >/dev/null 2>&1
    then
      packageManager="$(command jq -r '.packageManager // ""' package.json)"
    elif type node >/dev/null 2>&1
    then
      packageManager="$(command node -p 'require("./package.json").packageManager || ""')"
    fi
    packageManagerName="${packageManager%@*}"
    packageManagerVersion="${packageManager#*@}"
    [ "$packageManagerName" == 'yarn' ] && [ "${packageManagerVersion%%.*}" -gt 1 ] && packageManagerName='yarn-berry'
  fi

  [ -z "$packageManagerName" ] && [ -f 'bun.lockb' ] && packageManagerName='bun'
  [ -z "$packageManagerName" ] && [ -f 'pnpm-lock.yml' ] && packageManagerName='pnpm'
  # NOTE: bun can create yarn.lock via bun install -y
  [ -z "$packageManagerName" ] && [ -f 'yarn.lock' ] && packageManagerName='yarn'
  [ -z "$packageManagerName" ] && [ -f 'package-lock.json' ] && packageManagerName='npm'

  # fallback
  [ -z "$packageManagerName" ] && packageManagerName='npm'

  echo -n "$packageManagerName"
}

### agent alias
__ni-aa() {
  local -r manager="$(__ni-detect-package-manager)"
  command "$manager" "$@"
}

### add
__ni-add() {
  local args=()
  local flag_dev=
  while [[ $# -gt 0 ]]
  do
    case "$1" in
      -D|--save-dev)
        flag_dev=1
        shift
        ;;
      *)
        args+=("$1")
        shift
        ;;
    esac
  done

  local -r manager="$(__ni-detect-package-manager)"
  local flags=()
  if [ -n "$flag_dev" ]
  then
    # NOTE: bun doesn't have --save-dev option
    [ "$manager" == 'bun' ] && flags+=('--dev') || flags+=('--save-dev')
  fi

  case "$manager" in
    bun|pnpm|yarn|yarn-berry)
      command "$manager" add "${flags[@]}" "${args[@]}"
      ;;
    # npm has add subcommand, It's alias of npm install
    npm)
      command "$manager" install "${flags[@]}" "${args[@]}"
      ;;
  esac
}

### ci
__ni-ci() {
  local -r manager="$(__ni-detect-package-manager)"
  case "$manager" in
    bun|pnpm|yarn)
      command "$manager" install --frozen-lockfile
      ;;
    yarn-berry)
      command "$manager" install --immutable
      ;;
    npm)
      command "$manager" ci
      ;;
  esac
}

### dlx
__ni-dlx() {
  local -r manager="$(__ni-detect-package-manager)"
  case "$manager" in
    bun)
      command bunx "$@"
      ;;
    pnpm|yarn-berry)
      command "$manager" dlx "$@"
      ;;
    # NOTE: yarn classic doesn't have dlx command
    yarn|npm)
      command npx "$@"
      ;;
  esac
}

### install
__ni-install() {
  local -r manager="$(__ni-detect-package-manager)"
  case "$manager" in
    bun|pnpm|yarn|yarn-berry|npm)
      command "$manager" install
      ;;
  esac
}

### remove
__ni-remove() {
  local -r manager="$(__ni-detect-package-manager)"
  case "$manager" in
    bun|pnpm|yarn|yarn-berry)
      command "$manager" remove "$@"
      ;;
    npm)
      command "$manager" uninstall "$@"
      ;;
  esac
}

### run
__ni-run() {
  local -r manager="$(__ni-detect-package-manager)"
  case "$manager" in
    bun|pnpm|yarn|yarn-berry)
      command "$manager" run "$@"
      ;;
    npm)
      if [ $# -ge 2 ] && [ "$2" != '--' ]
      then
        command "$manager" run "$1" -- "${@:2}"
      else
        command "$manager" run "$@"
      fi
      ;;
  esac
}

### upgrade
__ni-upgrade() {
  local -r manager="$(__ni-detect-package-manager)"
  case "$manager" in
    bun|pnpm|yarn|yarn-berry|npm)
      command "$manager" upgrade
      ;;
  esac
}

### which
__ni-which() {
  printf -- '%s\n' "$(__ni-detect-package-manager)"
}

### --help
__ni-option-help() {
  # NOTE: Don't remove leading tabs
  cat <<-'EOB'
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
	EOB
}

### --version
__ni-option-version() {
  echo 'ni.bash 0.1.0'
}

ni() {
  # NOTE: execute install if argument is empty
  [ $# -eq 0 ] && set -- 'install'

  while [[ $# -gt 0 ]]
  do
    case $1 in
      a|aa)
        shift
        __ni-aa "$@"
        return $?
        ;;
      add)
        shift
        __ni-add "$@"
        return $?
        ;;
      ci)
        shift
        __ni-ci "$@"
        return $?
        ;;
      dlx|npx)
        shift
        __ni-dlx "$@"
        return $?
        ;;
      i|install)
        shift
        __ni-install "$@"
        return $?
        ;;
      rm|remove)
        shift
        __ni-remove "$@"
        return $?
        ;;
      run)
        shift
        __ni-run "$@"
        return $?
        ;;
      t|test)
        shift
        __ni-run test "$@"
        return $?
        ;;
      up|upgrade)
        shift
        __ni-upgrade "$@"
        return $?
        ;;
      which)
        shift
        __ni-which "$@"
        return $?
        ;;
      -h|--help)
        shift
        __ni-option-help "$@"
        return $?
        ;;
      -v|--version)
        shift
        __ni-option-version "$@"
        return $?
        ;;
      *)
        echo "Unknown subcommand: $1" >&2
        return 3
        ;;
    esac
  done
}

# vim:list:ts=2
