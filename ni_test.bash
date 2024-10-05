#!/bin/bash

# NOTE: why assertTrue returns unexpected result?

export SHUNIT_TEST_PREFIX='>>> '

. ./ni.bash

manager=

detect-package-manager() {
  manager="$(__ni-detect-package-manager)"
  echo "manager: $manager"
}

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
  detect-package-manager
  clean
}

oneTimeTearDown() {
  clean
}

setUp() {
  clean
}

test_ni-aa() {
  ni aa --version
  assertEquals $? 0
}

test_ni-add() {
  echo '{ "private": true }' > package.json
  ni add undici
  command jq '.dependencies.undici' package.json
  assertEquals $? 0
}

test_ni-ci() {
  clean
  ni add undici
  command rm -rf ./node_modules
  ni ci
  test -d ./node_modules
  assertEquals $? 0
}

test_ni-dlx() {
  ni dlx semver --help
  assertEquals $? 0
}

test_ni-install() {
  echo '{ "private": true }' > package.json
  ni add undici
  command rm -rf ./node_modules
  ni install
  test -d ./node_modules
  assertEquals $? 0
}

test_ni-remove() {
  echo '{ "private": true }' > package.json
  ni add undici
  ni remove undici
  assertEquals "$(command jq -r '.dependencies.undici' package.json)" 'null'
}

test_ni-run() {
  echo '{ "private": true, "scripts": { "hello": "echo hello" } }' > package.json
  ni run hello
  assertEquals $? 0
}

test_ni-test() {
  echo '{ "private": true, "scripts": { "test": "echo test" } }' > package.json
  ni t
  assertEquals $? 0
  ni test
  assertEquals $? 0
}

test_ni-upgrade() {
  echo '{ "private": true }' > package.json
  ni add undici@1
  ni upgrade
  command jq '.dependencies.undici' package.json
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

# shellcheck disable=SC1091
. ./shunit2/shunit2
