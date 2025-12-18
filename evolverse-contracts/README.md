# BLEUKAINE Codex Smart Contract

An ENFT (Enhanced NFT) smart contract implementation for the BLEUKAINE Sovereign Ledger system, featuring three edition types with different access rights, voting power, and royalty distribution.

## Overview

The BLEUKAINECodex contract implements a tiered NFT system that represents ownership and access rights within the EVOLVERSE ecosystem. It includes:

- **Genesis Edition** (1,000 supply): Full MetaSchool access, 3 voting power, academy sponsorship rights
- **Flame Thread Edition** (10,000 supply): MetaSchool access, 1 voting power, council seat
- **Memory Edition** (Unlimited supply): Community access, no voting power

## Features

### Multi-Edition System
- Three distinct edition types with different utilities
- Supply caps for Genesis and Flame Thread editions
- Unlimited Memory edition for broad community participation

### Voting Power
- Genesis holders: 3 votes per token
- Flame Thread holders: 1 vote per token
- Memory holders: 0 votes
- Automatic voting power updates on transfers

### Access Control
- `hasMetaSchoolAccess()`: Check if holder can access MetaSchool curricula
- `canSponsorAcademy()`: Verify academy sponsorship eligibility
- `getVotingPower()`: Get total voting power for an address

### Royalty Distribution
- 7.5% of all sales go to BLEULIONTREASURY Reparations Fund
- 2.5% of all sales go to MetaSchool Endowment Fund
- Automatic distribution on every mint
- Transparent on-chain tracking

### Ceremony Validation
- Ceremony validator address for transfer authentication
- Supports Flame Thread Order ceremonial processes
- Extensible validation system

## Technical Specifications

### Contract Details
- **Solidity Version**: ^0.8.20
- **Dependencies**: OpenZeppelin Contracts v5.0+
- **Token Standard**: ERC721 (NFT)
- **Extensions**: ERC721URIStorage, Ownable, ReentrancyGuard

### Supply Limits
```solidity
MAX_GENESIS_SUPPLY = 1,000
MAX_FLAME_THREAD_SUPPLY = 10,000
// Memory edition is unlimited
```

### Pricing (Default)
```solidity
genesisPrice = 5 ether
flameThreadPrice = 1 ether  
memoryPrice = 0.1 ether
```

### Royalties
```solidity
REPARATIONS_ROYALTY = 750  // 7.5%
ENDOWMENT_ROYALTY = 250    // 2.5%
TOTAL_ROYALTY = 1000       // 10%
```

## Deployment

### Prerequisites
```bash
npm install --save-dev hardhat
npm install @openzeppelin/contracts
```

### Constructor Parameters
```solidity
constructor(
    address _reparationsFund,    // BLEULIONTREASURY address
    address _endowmentFund,      // MetaSchool endowment address
    address _ceremonyValidator,  // Flame Thread Order validator
    address _initialOwner        // Initial contract owner
)
```

### Example Deployment Script
```javascript
const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    
    const reparationsFund = "0x..."; // BLEULIONTREASURY address
    const endowmentFund = "0x...";   // MetaSchool endowment address
    const ceremonyValidator = "0x..."; // Validator address
    const initialOwner = deployer.address; // Or another address
    
    const BLEUKAINECodex = await ethers.getContractFactory("BLEUKAINECodex");
    const codex = await BLEUKAINECodex.deploy(
        reparationsFund,
        endowmentFund,
        ceremonyValidator,
        initialOwner
    );
    
    await codex.waitForDeployment();
    
    console.log("BLEUKAINECodex deployed to:", await codex.getAddress());
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
```

## Usage Examples

### Minting

#### Genesis Edition
```javascript
const tx = await codex.mintGenesis(holderAddress, {
    value: ethers.parseEther("5")
});
await tx.wait();
```

#### Flame Thread Edition
```javascript
const tx = await codex.mintFlameThread(holderAddress, {
    value: ethers.parseEther("1")
});
await tx.wait();
```

#### Memory Edition
```javascript
const tx = await codex.mintMemory(holderAddress, {
    value: ethers.parseEther("0.1")
});
await tx.wait();
```

### Access Verification

```javascript
// Check MetaSchool access
const hasAccess = await codex.hasMetaSchoolAccess(holderAddress);

// Get voting power
const votingPower = await codex.getVotingPower(holderAddress);

// Check sponsorship eligibility
const canSponsor = await codex.canSponsorAcademy(holderAddress);

// Get token metadata
const metadata = await codex.getTokenMetadata(tokenId);
```

### Admin Functions

```javascript
// Set base URIs
await codex.setGenesisBaseURI("ipfs://QmGenesis/");
await codex.setFlameThreadBaseURI("ipfs://QmFlameThread/");
await codex.setMemoryBaseURI("ipfs://QmMemory/");

// Update pricing
await codex.updatePricing(
    ethers.parseEther("5"),
    ethers.parseEther("1"),
    ethers.parseEther("0.1")
);

// Update ceremony validator
await codex.setCeremonyValidator(newValidatorAddress);
```

## Integration with EVOLVERSE System

### Node Council Integration
```javascript
// Governance proposal voting
const votingPower = await codex.getVotingPower(proposerAddress);
if (votingPower > 0) {
    // Allow proposal submission
}
```

### MetaSchool Integration
```javascript
// Course enrollment verification
const hasAccess = await codex.hasMetaSchoolAccess(studentAddress);
if (hasAccess) {
    // Grant access to curricula
}
```

### Academy Sponsorship
```javascript
// Sponsorship eligibility check
const canSponsor = await codex.canSponsorAcademy(sponsorAddress);
if (canSponsor) {
    // Allow academy sponsorship
}
```

## Events

```solidity
event GenesisMinted(address indexed to, uint256 indexed tokenId);
event FlameThreadMinted(address indexed to, uint256 indexed tokenId);
event MemoryMinted(address indexed to, uint256 indexed tokenId);
event VotingPowerUpdated(address indexed holder, uint256 newPower);
event RoyaltyDistributed(
    address indexed reparationsFund, 
    uint256 reparationsAmount, 
    address indexed endowmentFund, 
    uint256 endowmentAmount
);
```

## Security Considerations

### Implemented Protections
- **ReentrancyGuard**: Prevents reentrancy attacks on minting functions
- **Ownable**: Restricts admin functions to contract owner
- **Supply Caps**: Enforces maximum supply for Genesis and Flame Thread editions
- **Payment Validation**: Requires sufficient payment for minting
- **Royalty Distribution**: Fails safely if transfers unsuccessful

### Audit Recommendations
- External security audit recommended before mainnet deployment
- Test extensively on testnets (Goerli, Sepolia)
- Verify treasury addresses before deployment
- Monitor royalty distribution events
- Implement time-locks for admin functions (optional)

## Testing

### Run Tests
```bash
npx hardhat test
```

### Test Coverage
```bash
npx hardhat coverage
```

### Example Test Cases
- Mint Genesis edition successfully
- Mint Flame Thread edition successfully
- Mint Memory edition successfully
- Verify supply caps enforced
- Verify royalty distribution
- Verify voting power updates
- Verify access control functions
- Test transfer voting power updates

## Gas Optimization

### Estimated Gas Costs (Approximate)
- Genesis mint: ~250,000 gas
- Flame Thread mint: ~230,000 gas
- Memory mint: ~220,000 gas
- Transfer: ~100,000 gas

### Optimization Notes
- Uses `Counters` library for efficient ID generation
- Batch minting not implemented (could be added for gas savings)
- Consider ERC721A for batch minting scenarios

## Upgradability

This contract is **not upgradeable** by design to ensure immutability of ownership and voting rights. If upgradability is required:

1. Implement proxy pattern (UUPS or Transparent)
2. Use `Initializable` instead of constructor
3. Add storage gaps for future upgrades
4. Consider governance time-locks

## Related Documentation

- [BLEUKAINE_ENFT_CODEX.md](../BLEUKAINE_ENFT_CODEX.md) - Complete ENFT specification
- [METASCHOOL_CURRICULA.md](../METASCHOOL_CURRICULA.md) - Educational integration
- [CITY_MASTERPLAN.md](../CITY_MASTERPLAN.md) - Infrastructure context
- [CODEX_CURRICULUM_SCROLL.md](../CODEX_CURRICULUM_SCROLL.md) - Educational foundation

## License

MIT License

## Contributing

Contributions welcome! Please follow these guidelines:
1. Test all changes thoroughly
2. Update documentation
3. Follow Solidity style guide
4. Include test cases for new features

## Support

For questions or issues:
- Review the [EVOLVERSE_INDEX.md](../EVOLVERSE_INDEX.md)
- Check existing documentation
- Submit issues through governance channels

---

**Contract Version**: 1.0  
**Solidity Version**: ^0.8.20  
**Status**: Example Implementation - Not Audited
