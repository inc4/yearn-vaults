#!/bin/sh

set -e

wget -O docker-compose-test.yml https://raw.githubusercontent.com/neonlabsorg/proxy-model.py/develop/proxy/docker-compose-test.yml

# Run Neon
REVISION=v0.11.x NEON_EVM_COMMIT=v0.11.x FAUCET_COMMIT=latest \
  docker-compose -f docker-compose-test.yml up -d --quiet-pull

# Run tests
MNEMONIC_PHRASE="slide clip fancy range predict resource stuff once all insect sniff acid"
docker run --rm --network host -e MNEMONIC_PHRASE="$MNEMONIC_PHRASE" \
  ghcr.io/inc4/yearn-vaults:master \
  bash -c " \
    brownie run scripts/neon_faucet.py --network neon && \
    brownie run scripts/neon_faucet.py --network neon && \
    brownie run scripts/neon_faucet.py --network neon && \
    brownie run scripts/neon_faucet.py --network neon && \
    brownie run scripts/neon_faucet.py --network neon && \
    brownie test \
      tests/functional/vault/test_strategies.py \
      tests/functional/vault/test_permit.py \
      tests/functional/vault/test_shares.py \
      tests/functional/vault/test_config.py \
      tests/functional/vault/test_misc.py \
      tests/functional/registry/test_config.py \
      tests/functional/registry/test_release.py \
      tests/functional/wrappers \
      tests/functional/strategy/test_strategy_health.py \
      tests/functional/strategy/test_clone.py \
      tests/functional/strategy/test_config.py \
      -v --network neon"

# Stop Neon
docker-compose -f docker-compose-test.yml down
