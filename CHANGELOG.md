# [5.0.0](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/compare/4.0.1...5.0.0) (2024-02-27)


### Bug Fixes

* schema download optional ([#116](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/issues/116)) ([37655c1](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/37655c1fbc200df88247aeab0ab4209c6d496b32))


* feat!: move to swift based framework for didcomm, jose and peer did (#120) ([558164f](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/558164f119881da4bd2edbfede40fb1760c84611)), closes [#120](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/issues/120)


### BREAKING CHANGES

* There is an update to the public API that is used directly with DIDComm

# [4.0.0](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/compare/3.6.0...4.0.0) (2024-01-25)


### Bug Fixes

* bug with header and footer of ed25519 and x25519 pem keys ([8ec220f](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/8ec220f3ed7e6c3f8c00671fea3cafff486b42ab))
* didcomm connection runner message filtering ([e57d62b](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/e57d62bbdb008fde720cdb7755cf1c6a06ca631a))
* this was causing confusion since it was public, not used and did not work as expected ([b82a9d6](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/b82a9d61f27064b427a40b3cfa8f336e58937416))


### Features

* **apollo:** integrate with apollo kmm ([32bdfbd](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/32bdfbd6cc8790391254c7ec1dca8dfe01fc62ee))
* **pluto:** pluto will save link secret as a storable key. ([dbd724b](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/dbd724bca43b09394fbf282716bcd3e73459377b))
* **pollux:** add anoncreds prooving implementation ([80377b1](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/80377b1b9f6d5255e5e6f0dd896253930cf0c4ee))
* **pollux:** zkp verification ([395976a](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/395976ae984f9a7d49ef944f0ed1641ae15e4f1d))


### BREAKING CHANGES

* **apollo:** Updated Apollo public interface to be more in line with Cryptographic abstraction
* This will not affect our API or was it working, but since it was public its considered a breaking change
* **pluto:** This makes changes on pluto interface.

# [3.6.0](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/compare/3.5.0...3.6.0) (2023-10-20)


### Features

* **castor:** remove antlr library and use regex instead ([d7b429e](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/d7b429eb46657be56bb3cbf92423baa9f9189a1a))

# [3.5.0](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/compare/3.4.0...3.5.0) (2023-10-12)


### Features

* **anoncreds:** add support for anoncreds issuance flow ([579c603](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/579c6030eefa2cf4f9690e512bb86e86927ba20a))

# [3.4.0](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/compare/3.3.0...3.4.0) (2023-09-27)


### Features

* provide abstraction for keychain component ([bf2e59f](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/bf2e59f9403e3459260200419aefd87ea5355f28))

# [3.3.0](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/compare/3.2.1...3.3.0) (2023-09-04)


### Features

* **pluto:** add keychain capabilities ([f013907](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/f0139077ee6ca0a131a0db3d26906ca390fc13a4))

## [3.2.1](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/compare/3.2.0...3.2.1) (2023-09-01)


### Bug Fixes

* did url string parsing correctly ([93a3eb4](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/93a3eb4a5ddfedc46b2816e38a18f56fa5b551a7))

# [3.2.0](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/compare/3.1.0...3.2.0) (2023-08-28)


### Features

* **pollux:** add anoncreds issuance ([0d474a9](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/0d474a9e5910fa8540f0e9915e96433add543364))

# [3.1.0](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/compare/3.0.0...3.1.0) (2023-08-07)


### Bug Fixes

* typo in restoring keys ([6dc434c](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/6dc434ca316997e309c1f8250fb1c09161cc726e))


### Features

* **mediator:** add ability to decode base64 message attachment for the mediator handler ([a389894](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/a389894b198af2ea0870cace35e868431ec1f4dc))
* **pollux:** add credential abstraction ([2f76cc6](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/2f76cc611a8f5abc9137c328dd427e9fbc00c32f))
