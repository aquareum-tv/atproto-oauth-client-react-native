#!/bin/bash

set -euo pipefail

# script for pulling new versions of this repo out of atproto for publishing

DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$DIR/../atproto/packages/oauth/oauth-client-react-native"
pnpm build && pnpm pack
rsync -arv . "$DIR"
cd "$DIR"
rm -rf dist node_modules tsconfig.build.tsbuildinfo
tar xzvf atproto-oauth-client-react-native-*.tgz
rm -rf atproto-oauth-client-react-native-*.tgz
mv ./package/package.json ./package.json
rm -rf ./package
cat > tsconfig.build.json <<EOF
{
  "extends": "../atproto/tsconfig/isomorphic.json",
  "compilerOptions": {
    "rootDir": "./src",
    "outDir": "./dist"
  },
  "include": ["./src"]
}
EOF
pnpm install
pnpm add --save-dev @types/node
pnpm build
pkg="$(cat package.json | jq '.name = "@aquareum/atproto-oauth-client-react-native"')"
echo "$pkg" > package.json
