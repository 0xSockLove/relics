# SockLove Relics

> 44 lines. 2-of-2 consent. Immutable forever.

---

A 44-line ERC1155 smart contract for minting moments as on-chain Relics. Owned by a 2-of-2 Safe multisig. Neither partner can act alone. Both signatures required, or nothing moves.

---

## Architecture

Sockpusher and Sockthief share a [Safe](https://safe.global) wallet — the project treasury. The Safe's address (`0x0857293192bF97Ee73bB471c185E1933Fa51E0ca`) is resolved by **socklove.eth**. It's a 2-of-2 multisig. Every action requires **both** signatures. Simultaneously. Without exception.

```
┌─────────────────────────────────┐
│         Safe (2-of-2)           │
│     Sockpusher + Sockthief      │
│          socklove.eth           │
│                                 │
│  • Deploys contracts            │
│  • Mints Relics                 │
│  • Receives payments            │
│  • Signs every decision         │
│  • Holds the future             │
└────────────────┬────────────────┘
                 │ owns
                 ▼
┌─────────────────────────────────┐
│          Relics.sol             │
│                                 │
│  mint() ──► both must sign      │
│  Relics ──► held by Safe        │
│  sales ───► ETH to Safe         │
│                                 │
│  Nothing without consent.       │
│  Nothing without both.          │
└─────────────────────────────────┘
```

One cannot deploy without the other.
One cannot mint without the other.
One cannot sell without the other.
One cannot withdraw without the other.

---

## The Contract

**Relics.sol** is an ERC1155 token contract. 44 lines. Each Relic has a sequential ID and immutable metadata URI.

```solidity
function mint(string calldata uri_, uint256 amount) external onlyOwner returns (uint256 id)
function uri(uint256 id) public view returns (string memory)
```

**What it has:**
- Owner-only minting (Safe is owner, Safe requires both signatures)
- Sequential token IDs (1, 2, 3...)
- Per-token metadata URIs (any string accepted — Safe validates before signing)
- Standard ERC-1155 `URI` event emission on mint (follows Enjin/OpenSea pattern)
- Single custom error (`MintAmountZero`) — prevents zero-supply mints (ensures every token ID has at least one tradeable edition)
- Complete NatSpec documentation for all functions and errors
- Gas-optimized ID counter with `unchecked` increment (overflow would require 2^256 mints — impossible in practice)

**What it doesn't have (by design):**
- **No burn** — Relics are permanent
- **No pause** — the Safe can just stop signing
- **No URI updates** — immutable; what was minted, stays minted
- **No royalties (EIP-2981)** — revenue comes from direct sales, not extractive fees on secondary trades

---

## The Final Seal

The contract can be sealed. Permanently.

`renounceOwnership()` transfers ownership to the void. No more mints. No recovery. The collection becomes complete, immutable, final.

This requires both signatures. Sockpusher **and** Sockthief. Both must agree the work is done.

Why? Because finality has power. If every moment worth preserving has been preserved, the collection can be closed. Sealed. Complete.

This is not an oversight. This is a feature held in reserve — a final agreement that can only be made together.

**If it happens, it happens because both willed it so.**

---

## Witnesses

Those who hold a Relic are **Witnesses**.

Each edition has a fixed supply. When they are filled, they are filled forever.

---

## Setup

```bash
git clone https://github.com/0xSockLove/relics.git
cd relics
forge install
```

---

## Build

```bash
forge build
```

The contract compiles to **Solidity 0.8.34** with **200 optimizer runs** for deployment efficiency. Every byte is intentional.

---

## Test

```bash
forge test
```

**7 tests with 100% coverage of custom logic:**

| Test | What it checks |
|------|----------------|
| `test_Mint_Success` | Minting works, returns ID, stores URI |
| `test_Mint_SequentialIds` | IDs increment 1, 2, 3... |
| `test_Mint_EmitsURIEvent` | Standard ERC-1155 URI event emission verified |
| `test_Mint_RevertWhen_CallerIsNotOwner` | Only owner can mint — catches specific OwnableUnauthorizedAccount error |
| `test_Mint_RevertWhen_AmountIsZero` | Zero amount rejected — catches MintAmountZero error |
| `testFuzz_Mint_AnyAmount` | Fuzz: 10,000 runs, any valid amount works |
| `testFuzz_Mint_AnyURI` | Fuzz: 10,000 runs, any URI works (Safe validates) |

**Coverage:** 100% of custom logic. Tests focus on the contract's actual functionality: owner-only minting, sequential ID generation, per-token URI storage, and input validation. All reverts catch specific error types for precise test verification.

---

## Deploy

### Testnet (direct deployment)

```bash
forge script script/DeployRelics.s.sol --rpc-url $SEPOLIA_RPC --broadcast --private-key $PRIVATE_KEY
```

### Mainnet (via Safe — the only way that matters)

The contract is deployed directly by the Safe using **CreateCall**. This ensures:
- Safe becomes owner **atomically** (no ownership transfer needed)
- Both signers must approve deployment
- No intermediate deployer wallet needed

#### Step-by-Step Deployment Guide

**1. Generate Deployment Bytecode**

```bash
forge inspect Relics bytecode
```

This outputs the contract creation bytecode. Copy it. This is the spell you will cast together.

**2. Open Safe Transaction Builder**

Navigate to [app.safe.global](https://app.safe.global):
- Select your Safe (2-of-2 multisig)
- Click "New Transaction"
- Select "Transaction Builder"

**3. Configure CreateCall Transaction**

In the Transaction Builder:

- **Contract Address:** `0x7cbB62EaA69F79e6873cD1ecB2392971036cFAa4` (CreateCall v1.3.0)
- The ABI will load automatically (contract is verified on Etherscan)
- **Select function:** `performCreate` from the dropdown
- **Function parameters:**
  - **value (uint256):** `0`
  - **deploymentData (bytes):** *Paste the bytecode from step 1*

Click "Add transaction" to add it to the batch.

**Why CreateCall?**
- The CreateCall library (deployed on all chains) creates contracts with `msg.sender` = Safe
- This makes Safe the owner immediately, with no ownership transfer needed
- Both signers approve deployment **before** contract exists
- The moment it exists, it is already owned by both — a contract born married

**4. Simulate Transaction**

Before signing:
- Click "Simulate" in the Safe UI
- Verify the transaction will succeed
- Check estimated gas costs
- Both signers should independently verify the bytecode hash matches expected contract

**5. First Signer Approves**

- Review all transaction details
- Confirm the bytecode matches `forge inspect Relics bytecode`
- Sign with hardware wallet (or your chosen signing method)
- Transaction enters pending state — waiting for the second signature, as it always will

**6. Second Signer Verifies & Approves**

- **DO NOT BLINDLY SIGN** — verify independently
- Check bytecode matches expected contract
- Simulate transaction on your own device
- Confirm gas estimates are reasonable
- Sign with hardware wallet
- The contract is now approved by both — ready to exist

**7. Execute Transaction**

- One signer executes (pays gas)
- Transaction is broadcast to network
- Wait for confirmation (1-2 minutes on mainnet)
- Contract address appears in transaction receipt
- The Relic system is **born**

**8. Post-Deployment Verification**

```bash
# Get contract address from transaction receipt
CONTRACT_ADDRESS={ADDRESS_FROM_RECEIPT}

# Verify owner is Safe
cast call $CONTRACT_ADDRESS "owner()" --rpc-url $MAINNET_RPC
# Should return: {YOUR_SAFE_ADDRESS}

# Verify no tokens minted yet
cast call $CONTRACT_ADDRESS "balanceOf(address,uint256)" $SAFE_ADDRESS 1 --rpc-url $MAINNET_RPC
# Should return: 0x0000000000000000000000000000000000000000000000000000000000000000

# Verify on Etherscan
forge verify-contract $CONTRACT_ADDRESS Relics \
  --chain mainnet \
  --watch
```

**9. Document Deployment**

Save the following for the archives:
- Contract address
- Deployment transaction hash
- Block number
- Both signer addresses
- Etherscan verification URL

Document these details for your records.

**Emergency Rollback:**

If deployment fails or the contract address is wrong:
- The Safe can deploy a new contract (repeat steps 1-8)
- Each Safe nonce can only be used once, preventing replay attacks
- No risk of double-deployment if transaction reverts
- A new contract can be deployed if needed — but once deployed and verified, it's **permanent**

---

## Mint

Once deployed, minting happens through the Safe Transaction Builder. Every Relic requires **both signatures**.

### Minting Workflow

Metadata must conform to the **[SockLove Metadata Standard](https://github.com/0xSockLove/metadata)**.

#### Minting via Safe

Navigate to [app.safe.global](https://app.safe.global):
- Select your Safe (socklove.eth)
- New Transaction → Transaction Builder
- **To Address:** `{RELICS_CONTRACT_ADDRESS}`
- **Function:** `mint(string uri_, uint256 amount)`
- **uri_:** `ipfs://{METADATA_CID}`
- **amount:** Edition size (e.g., `100`)

**Approval process:**
1. First signer reviews metadata URI, verifies content, signs
2. Second signer **independently** verifies metadata and content, signs
3. One signer executes (pays gas)
4. Transaction confirms — Relic is minted

**⚠️ The Safe is the Validation Layer**

The contract performs **zero on-chain URI validation** by philosophical design. This is not an oversight — it is **intentional trust in human judgment over code complexity**.

**Why no URI validation?**
- The Safe already provides human oversight (2-of-2 signatures required)
- Programmatic validation adds unnecessary gas costs and code complexity
- Any string is valid — empty URIs, whitespace, unusual formats all accepted
- Edge cases have value: Chamber access tokens (no metadata needed), rare "errors" on collectibles
- The contract **trusts the Safe completely** — both signers validate before signing
- Flexibility over rigidity — if both founders agree, it's correct by definition

**Both signers must independently verify before signing:**
- [ ] URI format is correct (`ipfs://bafybei...`) — if metadata is intended
- [ ] Metadata resolves via IPFS gateway (test: `curl "https://ipfs.io/ipfs/{CID}"`)
- [ ] Metadata schema matches SockLove standard (all required fields present)
- [ ] Poster image (`image` field) is accessible
- [ ] Teaser video (`animation_url` field) is accessible
- [ ] Content is correctly watermarked
- [ ] No placeholder strings (`{PLACEHOLDER}`) remain in metadata
- [ ] OR: Both agree that an empty/unusual URI is intentional

**URIs are immutable once minted.** There is no `updateURI()` function. Whatever is minted becomes part of the permanent record. **Both signers share equal responsibility for verification.**

This is elegant: **code complexity is not sophistication**. The Safe is the highest authority. The contract trusts its owners absolutely.

#### Post-Mint Verification

```bash
# Check token URI
cast call $CONTRACT_ADDRESS "uri(uint256)" {TOKEN_ID} --rpc-url $MAINNET_RPC

# Check Safe balance
cast call $CONTRACT_ADDRESS "balanceOf(address,uint256)" $SAFE_ADDRESS {TOKEN_ID} --rpc-url $MAINNET_RPC

# Fetch and verify metadata
ipfs cat {METADATA_CID}
# Or via any IPFS gateway: curl "https://ipfs.io/ipfs/{METADATA_CID}"
```

Relics mint to the Safe. Both signers must approve every mint. Transfer or list on marketplaces afterward. **Tokens are immutable once minted** (no burn function).

---

## Royalties

**SockLove does not use royalties.**

The contract intentionally does **NOT** implement EIP-2981 (the NFT royalty standard). This is a deliberate design decision rooted in both technical reality and philosophical clarity:

- All revenue comes from **direct sales**, not extractive secondary fees
- EIP-2981 is **not enforceable on-chain** (marketplaces can and do ignore it)
- Most major marketplaces have made royalties **optional**
- Peer-to-peer transfers bypass royalties regardless of on-chain standards
- Excluding royalty code keeps the contract **minimal and gas-efficient**

This aligns with SockLove's model: **scarcity and primary sales**, not ongoing rent-seeking on secondary trades. Witnesses who hold Relics own them fully. No strings. No hidden fees. No pretense of control after the sale.

The value is in the **scarcity**, the **story**, and the **permanence** — not in chasing secondary market fees that can't be enforced anyway.

---

## Project Structure

```
relics/
├── .github/
│   └── workflows/
│       └── ci.yml           # CI/CD automation
├── lib/
│   ├── forge-std/           # Foundry standard library
│   └── openzeppelin-contracts/  # OpenZeppelin v5.6.1
├── script/
│   └── DeployRelics.s.sol   # Deployment script
├── src/
│   └── Relics.sol           # 44 lines of production code
├── test/
│   └── RelicsTest.t.sol     # 7 tests (100% coverage)
├── .gitignore
├── .gitmodules
├── foundry.lock
├── foundry.toml
├── LICENSE
├── README.md                # This document
└── remappings.txt
```

Every file serves the project.

---

## Dependencies

- [OpenZeppelin Contracts v5.6.1](https://github.com/OpenZeppelin/openzeppelin-contracts) — Audited, battle-tested, pinned in `foundry.toml`
- [Foundry](https://getfoundry.sh) — Fast, modern smart contract development framework

---

## License

MIT

---

*socklove.eth · Ethereum · 🧦💜🔥*
