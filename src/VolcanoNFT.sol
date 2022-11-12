// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/access/Ownable.sol";
import "openzeppelin-contracts/utils/Counters.sol";
import "openzeppelin-contracts/security/ReentrancyGuard.sol";
import "forge-std/console.sol";

contract VolcanoNFT is ERC721, Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    address public coinAddress;
    Counters.Counter private tokenIdCounter;

    constructor(address _coinAddress) ERC721("AwesomeVolcanoNft", "AVN") {
        coinAddress = _coinAddress;
    }

    function setCoinAddress(address _coinAddress) public onlyOwner {
        coinAddress = _coinAddress;
    }

    function mint(address _to) public onlyOwner {
        _mint(_to);
    }

    function _mint(address _to) private {
        tokenIdCounter.increment();
        _safeMint(_to, tokenIdCounter.current());
    }

    function payToMint(address _to) public payable nonReentrant {
        // accept ether
        if (msg.value >= 0.01 ether) {
            if (msg.value > 0.01 ether) {
                // try to return additional eth
                payable(msg.sender).call{value: msg.value - 0.01 ether}("");
            }
        }
        // accept other token
        else {
            try
                IERC20(coinAddress).transferFrom(msg.sender, address(this), 100)
            {} catch {
                revert("VolcanoNFT: couldnt charge eth or token");
            }
        }

        _mint(_to);
    }
}
