// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MyNFTContract is ERC721, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    uint256 private _mintingPrice = 30 * 10**16;

    mapping(address => uint256) private _addressToNFTs; // 地址对应的 NFT 数组

    constructor(string memory name, string memory symbol) ERC721(name, symbol) { }

    function mintNFT(string memory _uri) public payable {
        require(msg.value >= _mintingPrice, "Insufficient funds to mint NFT");
        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, _uri);
        _addressToNFTs[msg.sender] = tokenId;

        if (msg.value > _mintingPrice) {
            payable(msg.sender).transfer(msg.value - _mintingPrice);
        }
    }

    function getOwnedNFTs(address user) public view returns (uint256) {
        return _addressToNFTs[user];
    }

    // 解决冲突的函数，并使用 override 关键字
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function withdrawBalance(uint256 amount) external onlyOwner {
        payable(msg.sender).transfer(amount);
    }
}
