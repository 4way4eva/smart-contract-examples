# ENFT Metadata Collection

## BLEU Codex Family Lineage v1.333

This directory contains NFT metadata for the BLEU Codex characters and editions.

### Structure

```
ENFT_Metadata/
├── Genesis_Edition/
│   └── BLEUKAINE_Genesis.json       # Genesis Edition (1,000 supply)
├── Character_Specific/
│   ├── Xavias.json                   # Archetype 1 - Fire
│   ├── Xavia.json                    # Archetype 2 - Water
│   ├── Zorian.json                   # Archetype 3 - Earth
│   ├── Ayana_Blue.json               # Archetype 4 - Air
│   ├── Shango_Strike.json            # Archetype 5 - Lightning
│   ├── Kongo_Sonix.json              # Archetype 6 - Sound
│   ├── Jetah_Flame.json              # Archetype 7 - Fire/Purification
│   └── Phiyah.json                   # Archetype 8 - Light/Vision
└── README.md                         # This file
```

### The Eight Archetypes

1. **Xavias** - Abraham's Ram (Fire) - Planetary-Class - Mythic
2. **Xavia** - Miriam's Water Memory (Water) - Oceanic-Class - Legendary
3. **Zorian** - Time as Temple (Earth) - Continental-Class - Mythic
4. **Ayana Blue** - The Voice That Restores (Air) - Atmospheric-Class - Legendary
5. **Shango-Strike** - The Thunder Walker (Lightning) - Atmospheric-Class - Mythic
6. **Kongo Sonix** - The Resonance Revolutionary (Sound) - City-Class - Legendary
7. **Jetah Flame** - The Purifier (Fire/Purification) - Molecular-Class - Mythic
8. **Phiyah** - The Seer of Routes (Light/Vision) - Dimensional-Class - Mythic

### Metadata Standard

All metadata follows the ERC-721 standard with extended attributes including:

- **Archetype ID**: Unique identifier (1-8)
- **Element**: Primary elemental affinity
- **Biblical Archetype**: Source scripture reference
- **Gene Function**: Core ability protocol
- **Wave Function**: Transformation sequence
- **Home Zone**: Primary node assignment
- **Sacred City**: Spiritual anchor point
- **Weapon Type**: Signature armament
- **Hair Frequency**: Solfeggio frequency (Hz)
- **Lightning/Air Attributes**: Secondary abilities
- **Power Level**: Classification tier
- **Rarity**: Mythic, Legendary, or Epic

### Edition Types

#### Genesis Edition (1,000 supply)
- **Benefits**: MetaSchool Level I access, Reef Vault sponsorship right, Flame Thread Order title
- **File**: `Genesis_Edition/BLEUKAINE_Genesis.json`

#### Flame Thread Edition (10,000 supply)
- **Benefits**: Ceremonial title, Node Council seat (1 year)
- **Status**: Metadata templates in development

#### Memory Edition (Unlimited)
- **Benefits**: Community curricula access, Digital memory wallet
- **Status**: Metadata templates in development

### Royalty Structure

All ENFT sales include:
- **7.5%** to BLEULIONTREASURY Reparations Fund
- **2.5%** to MetaSchool Endowment

### Deployment Platforms

- **ZORA** - Primary NFT marketplace
- **ARWEAVE** - Permanent decentralized storage

### IPFS Placeholder CIDs

Current metadata files use placeholder CIDs in the format:
- `ipfs://Qm[CHARACTER]_Character_Image_CID`
- `ipfs://Qm[CHARACTER]_Character_Animation_CID`

These should be replaced with actual IPFS content identifiers before deployment.

### Usage

To mint an ENFT:

1. Upload character artwork and animations to IPFS
2. Replace placeholder CIDs in the metadata JSON
3. Upload updated metadata to IPFS or Arweave
4. Use the metadata URI in your smart contract minting function
5. Set royalty parameters according to the BLEULIONTREASURY structure

### Validation

All JSON files in this directory have been validated for correct syntax.

To validate locally:
```bash
python3 -m json.tool ENFT_Metadata/Character_Specific/[CHARACTER].json
```

### Integration

These metadata files integrate with:
- `BLEU_Codex_Family_Lineage_v1.333.json` - Master character database
- `AOQPPPPI_UNIVERSAL_CODEX_vFinal.json` - Universal codex system
- `README_Manifesto.json` - Project manifesto

### Status

**Complete**: All 8 character metadata files + Genesis Edition  
**Next Phase**: Flame Thread and Memory Edition templates

---

*Compiled by: Dr. SØŚÅ (Brandon Shakeel Mitchell)*  
*Version: 1.333*  
*Date: 2025-12-03*
