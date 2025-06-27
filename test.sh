#!/bin/bash

# Test for non-deterministic pnpm hoisting bug
# Usage: ./test.sh [rounds] (default: 400)

get_hoisted_react_version() {
    if [ -L "node_modules/.pnpm/node_modules/react" ]; then
        target=$(readlink "node_modules/.pnpm/node_modules/react")
        echo "$target" | grep -o 'react@[^/]*' | sed 's/react@//'
    else
        echo "NOT_HOISTED"
    fi
}

rounds=${1:-400}

if ! [[ "$rounds" =~ ^[0-9]+$ ]] || [ "$rounds" -lt 1 ]; then
    echo "Usage: $0 [rounds]"
    exit 1
fi

echo "Testing pnpm hoisting determinism with $rounds rounds..."

# Create initial lockfile
rm -rf node_modules pnpm-lock.yaml
pnpm install > /dev/null 2>&1
baseline_lockfile=$(cat pnpm-lock.yaml)

for ((i=1; i<=rounds; i++)); do
    if [ $((i % 50)) -eq 1 ]; then
        echo "🔄 Run $i-$((i+49 <= rounds ? i+49 : rounds))..."
    fi
    
    rm -rf node_modules
    echo "$baseline_lockfile" > pnpm-lock.yaml
    pnpm install --frozen-lockfile > /dev/null 2>&1
    
    version=$(get_hoisted_react_version)
    
    if [ "$i" -eq 1 ]; then
        first_version="$version"
    elif [ "$version" != "$first_version" ]; then
        echo "🚨 Run $i: Different version! $version (was $first_version)"
        echo ""
        echo "❌ BUG CONFIRMED: Non-deterministic hoisting with --frozen-lockfile"
        echo "   Same lockfile produced different results in $i runs"
        exit 1
    fi
done

echo ""
echo "✅ No non-determinism detected in $rounds runs (all: $first_version)"