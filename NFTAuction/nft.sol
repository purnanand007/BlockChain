// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract MyNFT is ERC721,ERC721URIStorage,Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter; //counter starts with value 0

    address payable artist; // NFT owner 
    address public txFeeToken; 
    uint256 public txFeeAmount; // Royaltiy

    mapping(address => bool) public excludedList;

    constructor(uint256 _txFeeAmount) ERC721("MyNFT", "MNFT" ) {
        txFeeAmount = _txFeeAmount;
        artist= payable(msg.sender); // nft creatoe
        excludedList[artist] = true;
    
    }

    
  function setExcluded(address excluded, bool status) external {
    require(msg.sender == artist, 'artist only');
    excludedList[excluded] = status;
  }

  receive() external payable {}

function _payRoyalty() public  payable {
  require(msg.value > 0 , "enter value > txFeeToken");
    payable(artist).transfer(msg.value);
}

  function isOwnerNft (address from, uint tokenId) public view  {
    require( _isApprovedOrOwner(from, tokenId),  'ERC721: transfer caller is not owner nor approved' );
  }

function transferFrom(address from, address to,  uint256 tokenId) public override {
     require( _isApprovedOrOwner(from, tokenId),  'ERC721: transfer caller is not owner nor approved' );
     if(excludedList[from] == false) {
      _payRoyalty();
     }
      _approve(to, tokenId);
     _transfer(from, to, tokenId);
  }
  
//to avoid lock tokens
function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId
   ) public override {
     require(
      _isApprovedOrOwner(from, tokenId), 
      'ERC721: transfer caller is not owner nor approved'
    );
     
     if(excludedList[from] == false) {
      _payRoyalty();
     }
     _safeTransfer(from, to, tokenId, '');
     _approve(to, tokenId);
   }

  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    bytes memory _data
  ) public override {
    require(
      _isApprovedOrOwner(from, tokenId), 
      'ERC721: transfer caller is not owner nor approved'
    );
    if(excludedList[from] == false) {
      _payRoyalty();
    }
    _safeTransfer(from, to, tokenId, _data);
     _approve(to, tokenId);
  }


    function _baseURI() internal pure override returns (string memory) {
        return "https://gateway.pinata.cloud/ipfs/QmZSHdBfcL2ebX4o91YUkeN1Cqti8zcwLBNbrpj5goMtmM";
    }

    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }
  
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
      //owner of the nft will be able to withdraw his amount money got from nft.

    function withdraw() public onlyOwner payable {
        require(address(this).balance > 0);
        payable(owner()).transfer(address(this).balance);
    }
}