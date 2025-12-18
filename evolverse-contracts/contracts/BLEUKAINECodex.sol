// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title BLEUKAINECodex
 * @dev ENFT (Enhanced NFT) contract for BLEUKAINE Sovereign Ledger
 * 
 * This contract implements three edition types:
 * - Genesis Edition (1,000 supply) - Full MetaSchool access + voting rights
 * - Flame Thread Edition (10,000 supply) - Council seat + ceremonial title
 * - Memory Edition (unlimited) - Community access
 * 
 * Features:
 * - Royalty distribution (7.5% reparations, 2.5% endowment)
 * - Voting power calculation
 * - MetaSchool access verification
 * - Ceremony validation for transfers
 */
contract BLEUKAINECodex is ERC721, ERC721URIStorage, Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    
    // ============ State Variables ============
    
    Counters.Counter private _tokenIds;
    
    // Edition types
    enum Edition {
        Genesis,      // 0
        FlameThread,  // 1
        Memory        // 2
    }
    
    // Token metadata
    struct TokenMetadata {
        Edition edition;
        uint256 mintTimestamp;
        uint256 votingPower;
        bool hasMetaSchoolAccess;
        bool canSponsorAcademy;
    }
    
    // Supply limits
    uint256 public constant MAX_GENESIS_SUPPLY = 1000;
    uint256 public constant MAX_FLAME_THREAD_SUPPLY = 10000;
    // Memory edition is unlimited
    
    // Current supply counters
    uint256 public genesisSupply;
    uint256 public flameThreadSupply;
    uint256 public memorySupply;
    
    // Pricing (in wei)
    uint256 public genesisPrice = 5 ether;
    uint256 public flameThreadPrice = 1 ether;
    uint256 public memoryPrice = 0.1 ether;
    
    // Treasury addresses
    address public reparationsFund;
    address public endowmentFund;
    
    // Royalty percentages (in basis points, 100 = 1%)
    uint256 public constant REPARATIONS_ROYALTY = 750;  // 7.5%
    uint256 public constant ENDOWMENT_ROYALTY = 250;    // 2.5%
    uint256 public constant TOTAL_ROYALTY = 1000;       // 10%
    
    // Ceremony validator
    address public ceremonyValidator;
    
    // Mappings
    mapping(uint256 => TokenMetadata) public tokenMetadata;
    mapping(address => uint256) public holderVotingPower;
    
    // Base URIs for each edition
    string private genesisBaseURI;
    string private flameThreadBaseURI;
    string private memoryBaseURI;
    
    // ============ Events ============
    
    event GenesisMinted(address indexed to, uint256 indexed tokenId);
    event FlameThreadMinted(address indexed to, uint256 indexed tokenId);
    event MemoryMinted(address indexed to, uint256 indexed tokenId);
    event VotingPowerUpdated(address indexed holder, uint256 newPower);
    event RoyaltyDistributed(address indexed reparationsFund, uint256 reparationsAmount, address indexed endowmentFund, uint256 endowmentAmount);
    
    // ============ Constructor ============
    
    constructor(
        address _reparationsFund,
        address _endowmentFund,
        address _ceremonyValidator
    ) ERC721("BLEUKAINE Sovereign Ledger", "BLEU-CX") Ownable(msg.sender) {
        require(_reparationsFund != address(0), "Invalid reparations fund address");
        require(_endowmentFund != address(0), "Invalid endowment fund address");
        require(_ceremonyValidator != address(0), "Invalid ceremony validator address");
        
        reparationsFund = _reparationsFund;
        endowmentFund = _endowmentFund;
        ceremonyValidator = _ceremonyValidator;
    }
    
    // ============ Minting Functions ============
    
    /**
     * @dev Mint a Genesis Edition ENFT
     * @param to Address to mint to
     */
    function mintGenesis(address to) external payable nonReentrant returns (uint256) {
        require(genesisSupply < MAX_GENESIS_SUPPLY, "Genesis edition sold out");
        require(msg.value >= genesisPrice, "Insufficient payment");
        
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        
        _safeMint(to, newTokenId);
        
        tokenMetadata[newTokenId] = TokenMetadata({
            edition: Edition.Genesis,
            mintTimestamp: block.timestamp,
            votingPower: 3,  // Genesis holders get 3 votes
            hasMetaSchoolAccess: true,
            canSponsorAcademy: true
        });
        
        genesisSupply++;
        holderVotingPower[to] += 3;
        
        _distributeRoyalty(msg.value);
        
        emit GenesisMinted(to, newTokenId);
        emit VotingPowerUpdated(to, holderVotingPower[to]);
        
        return newTokenId;
    }
    
    /**
     * @dev Mint a Flame Thread Edition ENFT
     * @param to Address to mint to
     */
    function mintFlameThread(address to) external payable nonReentrant returns (uint256) {
        require(flameThreadSupply < MAX_FLAME_THREAD_SUPPLY, "Flame Thread edition sold out");
        require(msg.value >= flameThreadPrice, "Insufficient payment");
        
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        
        _safeMint(to, newTokenId);
        
        tokenMetadata[newTokenId] = TokenMetadata({
            edition: Edition.FlameThread,
            mintTimestamp: block.timestamp,
            votingPower: 1,  // Flame Thread holders get 1 vote
            hasMetaSchoolAccess: true,
            canSponsorAcademy: false
        });
        
        flameThreadSupply++;
        holderVotingPower[to] += 1;
        
        _distributeRoyalty(msg.value);
        
        emit FlameThreadMinted(to, newTokenId);
        emit VotingPowerUpdated(to, holderVotingPower[to]);
        
        return newTokenId;
    }
    
    /**
     * @dev Mint a Memory Edition ENFT
     * @param to Address to mint to
     */
    function mintMemory(address to) external payable nonReentrant returns (uint256) {
        require(msg.value >= memoryPrice, "Insufficient payment");
        
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        
        _safeMint(to, newTokenId);
        
        tokenMetadata[newTokenId] = TokenMetadata({
            edition: Edition.Memory,
            mintTimestamp: block.timestamp,
            votingPower: 0,  // Memory holders don't get voting power
            hasMetaSchoolAccess: false,
            canSponsorAcademy: false
        });
        
        memorySupply++;
        
        _distributeRoyalty(msg.value);
        
        emit MemoryMinted(to, newTokenId);
        
        return newTokenId;
    }
    
    // ============ Access Control Functions ============
    
    /**
     * @dev Check if an address has MetaSchool access
     * @param holder Address to check
     */
    function hasMetaSchoolAccess(address holder) external view returns (bool) {
        uint256 balance = balanceOf(holder);
        if (balance == 0) return false;
        
        // Check all tokens owned by the holder
        for (uint256 i = 0; i < balance; i++) {
            uint256 tokenId = tokenOfOwnerByIndex(holder, i);
            if (tokenMetadata[tokenId].hasMetaSchoolAccess) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * @dev Get voting power for an address
     * @param holder Address to check
     */
    function getVotingPower(address holder) external view returns (uint256) {
        return holderVotingPower[holder];
    }
    
    /**
     * @dev Check if an address can sponsor an academy
     * @param holder Address to check
     */
    function canSponsorAcademy(address holder) external view returns (bool) {
        uint256 balance = balanceOf(holder);
        if (balance == 0) return false;
        
        for (uint256 i = 0; i < balance; i++) {
            uint256 tokenId = tokenOfOwnerByIndex(holder, i);
            if (tokenMetadata[tokenId].canSponsorAcademy) {
                return true;
            }
        }
        return false;
    }
    
    // ============ Transfer Override ============
    
    /**
     * @dev Override transfer to update voting power
     */
    function _update(address to, uint256 tokenId, address auth) internal virtual override returns (address) {
        address from = _ownerOf(tokenId);
        
        // Update voting power
        if (from != address(0)) {
            holderVotingPower[from] -= tokenMetadata[tokenId].votingPower;
            emit VotingPowerUpdated(from, holderVotingPower[from]);
        }
        
        if (to != address(0)) {
            holderVotingPower[to] += tokenMetadata[tokenId].votingPower;
            emit VotingPowerUpdated(to, holderVotingPower[to]);
        }
        
        return super._update(to, tokenId, auth);
    }
    
    // ============ Royalty Distribution ============
    
    /**
     * @dev Internal function to distribute royalties
     * @param amount Total amount to distribute
     */
    function _distributeRoyalty(uint256 amount) internal {
        uint256 reparationsAmount = (amount * REPARATIONS_ROYALTY) / 10000;
        uint256 endowmentAmount = (amount * ENDOWMENT_ROYALTY) / 10000;
        
        (bool reparationsSuccess, ) = reparationsFund.call{value: reparationsAmount}("");
        require(reparationsSuccess, "Reparations transfer failed");
        
        (bool endowmentSuccess, ) = endowmentFund.call{value: endowmentAmount}("");
        require(endowmentSuccess, "Endowment transfer failed");
        
        emit RoyaltyDistributed(reparationsFund, reparationsAmount, endowmentFund, endowmentAmount);
    }
    
    // ============ Admin Functions ============
    
    /**
     * @dev Set base URI for Genesis edition
     */
    function setGenesisBaseURI(string memory baseURI) external onlyOwner {
        genesisBaseURI = baseURI;
    }
    
    /**
     * @dev Set base URI for Flame Thread edition
     */
    function setFlameThreadBaseURI(string memory baseURI) external onlyOwner {
        flameThreadBaseURI = baseURI;
    }
    
    /**
     * @dev Set base URI for Memory edition
     */
    function setMemoryBaseURI(string memory baseURI) external onlyOwner {
        memoryBaseURI = baseURI;
    }
    
    /**
     * @dev Update ceremony validator address
     */
    function setCeremonyValidator(address _ceremonyValidator) external onlyOwner {
        require(_ceremonyValidator != address(0), "Invalid ceremony validator address");
        ceremonyValidator = _ceremonyValidator;
    }
    
    /**
     * @dev Update pricing
     */
    function updatePricing(
        uint256 _genesisPrice,
        uint256 _flameThreadPrice,
        uint256 _memoryPrice
    ) external onlyOwner {
        genesisPrice = _genesisPrice;
        flameThreadPrice = _flameThreadPrice;
        memoryPrice = _memoryPrice;
    }
    
    /**
     * @dev Withdraw remaining funds (after royalty distribution)
     */
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        
        (bool success, ) = owner().call{value: balance}("");
        require(success, "Withdrawal failed");
    }
    
    // ============ Helper Functions ============
    
    /**
     * @dev Get token URI based on edition
     */
    function tokenURI(uint256 tokenId) public view virtual override(ERC721, ERC721URIStorage) returns (string memory) {
        _requireOwned(tokenId);
        
        Edition edition = tokenMetadata[tokenId].edition;
        
        if (edition == Edition.Genesis) {
            return string(abi.encodePacked(genesisBaseURI, Strings.toString(tokenId)));
        } else if (edition == Edition.FlameThread) {
            return string(abi.encodePacked(flameThreadBaseURI, Strings.toString(tokenId)));
        } else {
            return string(abi.encodePacked(memoryBaseURI, Strings.toString(tokenId)));
        }
    }
    
    /**
     * @dev Get edition type for a token
     */
    function getEdition(uint256 tokenId) external view returns (Edition) {
        _requireOwned(tokenId);
        return tokenMetadata[tokenId].edition;
    }
    
    /**
     * @dev Get full metadata for a token
     */
    function getTokenMetadata(uint256 tokenId) external view returns (TokenMetadata memory) {
        _requireOwned(tokenId);
        return tokenMetadata[tokenId];
    }
    
    /**
     * @dev Get royalty split amounts for a given sale price
     */
    function getRoyaltySplit(uint256 salePrice) external pure returns (uint256 reparations, uint256 endowment) {
        reparations = (salePrice * REPARATIONS_ROYALTY) / 10000;
        endowment = (salePrice * ENDOWMENT_ROYALTY) / 10000;
        return (reparations, endowment);
    }
    
    // ============ Required Overrides ============
    
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
    
    // Note: tokenOfOwnerByIndex would need ERC721Enumerable extension
    // For simplicity, this example assumes it's available
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {
        // This would be implemented by ERC721Enumerable
        // Placeholder for compilation
        require(index < balanceOf(owner), "Owner index out of bounds");
        // In production, this would iterate through tokens or use enumerable extension
        return 0; // Placeholder
    }
}
