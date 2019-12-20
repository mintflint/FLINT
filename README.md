# FLINT


## Project structure

1. `contracts` - Smart Contracts source code.
1. `test` - Smart contracts unit tests.

## How to setup dev environment?

1. Install docker.
1. Run `docker-compose build`.
1. Start containers `docker-compose up -d`.
1. Install project dependencies: `docker-compose exec workspace yarn`.
1. To run tests: `docker-compose exec workspace truffle test`.

## Useful links for smart contracts development

1. Truffle suite - https://github.com/trufflesuite/truffle
1. Ganache-cli (EthereumJS Testrpc) - https://github.com/trufflesuite/ganache-cli
1. Zeppelin Solidity - https://github.com/OpenZeppelin/zeppelin-solidity
