# pnpm Non-Deterministic Hoisting Bug

Reproduction case for pnpm hoisting non-determinism with `--frozen-lockfile`.

## Problem

With the same `pnpm-lock.yaml`, `pnpm install --frozen-lockfile` sometimes hoists React 18, sometimes React 19 to `node_modules/.pnpm/node_modules/react`.

## Reproduction

```bash
./test.sh
```

The script runs up to 400 installations using the committed `pnpm-lock.yaml`. It should always hoist the same React version, but often doesn't.

**Note**: The lockfile is committed to ensure everyone tests with identical dependency trees.

## Expected vs Actual

**Expected**: Same lockfile = same hoisting results  
**Actual**: Same lockfile = random hoisting results

## Setup

- Workspace with packages depending on React 18 and React 19
- Both packages also depend on Expo 52 (complex dependency tree)
- Private hoisting enabled (`hoist-pattern: ['*']`)

## Environment

- pnpm: 10.11.1+ (confirmed affected)
- Node.js: 18+
- Any OS