#!/bin/bash

# NOTE: why assertTrue returns unexpected result?

. ./ni.bash

manager="$(__ni-detect-package-manager)"

clean() {
  command rm -rf ./package.json ./package-lock.json ./yarn.lock ./pnpm-lock.yml ./bun.lockb ./node_modules
  case "$manager" in
    bun)
      touch bun.lockb
      ;;
    pnpm)
      touch pnpm-lock.yml
      ;;
    yarn|yarn-berry)
      touch yarn.lock
      ;;
    npm)
      touch package-lock.json
      ;;
  esac
}

oneTimeSetUp() {
  echo "manager: $manager"
}

oneTimeTearDown() {
  clean
}

setUp() {
  clean
}

test_ni-aa() {
  ni aa --version >/dev/null 2>&1
  assertEquals $? 0
}

test_ni-add() {
  echo '{ "private": true }' > package.json
  ni add undici >/dev/null 2>&1
  command jq '.dependencies.undici' package.json >/dev/null 2>&1
  assertEquals $? 0
}

test_ni-ci() {
  clean
  ni add undici >/dev/null 2>&1
  command rm -rf ./node_modules
  ni ci >/dev/null 2>&1
  test -d ./node_modules
  assertEquals $? 0
}

test_ni-dlx() {
  ni dlx semver --help >/dev/null 2>&1
  assertEquals $? 0
}

test_ni-install() {
  echo '{ "private": true }' > package.json
  ni add undici >/dev/null 2>&1
  command rm -rf ./node_modules
  ni install >/dev/null 2>&1
  test -d ./node_modules
  assertEquals $? 0
}

test_ni-remove() {
  echo '{ "private": true }' > package.json
  ni add undici >/dev/null 2>&1
  ni remove undici >/dev/null 2>&1
  assertEquals "$(command jq -r '.dependencies.undici' package.json)" 'null'
}

test_ni-run() {
  echo '{ "private": true, "scripts": { "hello": "echo hello" } }' > package.json
  ni run hello >/dev/null 2>&1
  assertEquals $? 0
}

test_ni-test() {
  echo '{ "private": true, "scripts": { "test": "echo test" } }' > package.json
  ni t >/dev/null 2>&1
  assertEquals $? 0
  ni test >/dev/null 2>&1
  assertEquals $? 0
}

test_ni-upgrade() {
  echo '{ "private": true }' > package.json
  ni add undici@1 >/dev/null 2>&1
  ni upgrade >/dev/null 2>&1
  command jq '.dependencies.undici' package.json >/dev/null 2>&1
  assertEquals $? 0
}

test_ni-which() {
  assertEquals "$(ni which)" "$manager"
}

test_ni-option-help() {
  ni -h | grep -q 'Usage:'
  assertEquals $? 0
  ni --help | grep -q 'Usage:'
  assertEquals $? 0
}

test_ni-option-version() {
  assertEquals "$(ni -v)" 'ni.bash 0.1.0'
  assertEquals "$(ni --version)" 'ni.bash 0.1.0'
}

. ./shunit2/shunit2
