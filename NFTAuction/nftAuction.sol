pragma solidity ^0.8.2;
import "./nft.sol";
// SPDX-License-Identifier: MIT 
contract nftAuction {
    MyNFT dc; 
    constructor(address payable _add) {
     dc = MyNFT(_add); // connect nft.sol file
    }

uint public t = block.timestamp;
    // Bid will store infomation of bid applyed
    struct Bid {
        address from;
        uint256 amount;
    }
    //Auction will store all the details about a auction
     struct Auction {
        string name;
        uint256 blockDeadline;
        address nft;
        address owner;
        bool active;
        bool finalized;
        uint256 startPrice;
        uint256 tokenId;
        
    }

    mapping(uint256 => Bid[]) public auctionBids;
    mapping(address => uint[]) public auctionOwner;

    //auctions will contains all the auctions applied
    Auction[] public auctions;

    modifier isOwner (uint auctionId) {
        require(auctions[auctionId].owner == msg.sender);
        _;
    }

    function Get_Bids_Count(uint auctionId) public view  returns(uint) {
        return auctionBids[auctionId].length;
    }

    function getAuctionFromId (uint auctionId) public view
     returns(
        string memory name,
        uint256 blockDeadline,
        uint256 startPrice,
        uint256 tokenId,
        address nft,
        address owner,
        bool active,
        bool finalized) {

        Auction memory auc = auctions[auctionId];
        return (
            auc.name, 
            auc.blockDeadline, 
            auc.startPrice, 
            auc.tokenId, 
           // auc.deedRepositoryAddress, 
            auc.nft,
            auc.owner, 
            auc.active, 
            auc.finalized);
    }

    function create_Auction( uint256 _tokenId, string memory _auctionTitle, uint256 _startPrice, uint _blockDeadline, address _nft) public returns(bool) {
        
        dc.isOwnerNft(msg.sender,_tokenId);

        uint auctionId = auctions.length;
        Auction memory newAuction;
        newAuction.name = _auctionTitle;
        newAuction.blockDeadline = _blockDeadline;
        newAuction.startPrice = _startPrice;
        newAuction.tokenId = _tokenId;
        newAuction.nft=_nft;
        newAuction.owner = msg.sender;
        newAuction.active = true;
        newAuction.finalized = false;
        auctions.push(newAuction);        
        auctionOwner[msg.sender].push(auctionId);
        return true;
    }

    function approveWithTransfer(address from, address to, uint256 tokenId) internal returns(bool) {
      dc.transferFrom(from, to, tokenId);// error
      return true;
    }

    receive() external payable {}

    // function payBid() payable public {
    //     payable(address(this)).transfer(msg.value);
    // }

    function getContractAcbalance() public view returns (uint256) {
        return address(this).balance;
    }



    function bidOverAuction(uint auctionId) public payable {
        uint256 ethAmountbid = msg.value;
        // owner can't bid on their auctions
        Auction memory myAuction = auctions[auctionId];
        require(myAuction.owner != msg.sender,"owner cannot bid");
        // if auction is expired
        require( block.timestamp > myAuction.blockDeadline,"auction expired");
       // if( block.timestamp > myAuction.blockDeadline ) revert(); //error1

        uint bidsLength = auctionBids[auctionId].length;
        uint256 tempAmount = myAuction.startPrice;
        Bid memory lastBid;
        // there are previous bids
        
        if( bidsLength > 0 ) {
            lastBid = auctionBids[auctionId][bidsLength - 1];
            tempAmount = lastBid.amount;
        }
        // if bid amount is less than previous bid then revert it. 
        require(ethAmountbid > tempAmount , "enter value greater than revious bid");
    
        //refund to the last bidder
        if( bidsLength > 0 ) {
           if(!payable(lastBid.from).send(lastBid.amount))
            {
                revert();
            } 
        }
        // insert new bid 
        Bid memory newBid;
        newBid.from = msg.sender;
        newBid.amount = ethAmountbid;
        auctionBids[auctionId].push(newBid);
        payable(address(this)).transfer(msg.value);
    }

    function cancel_Auction(uint auctionId) public payable isOwner (auctionId) {
        uint bidsLength = auctionBids[auctionId].length;
        // refund previous bid if ther any
        if( bidsLength > 0 ) {
            Bid memory  lastBid = auctionBids[auctionId][bidsLength - 1];
            if(!payable(lastBid.from).send(lastBid.amount))
            {
                revert();
            }
        }
            auctions[auctionId].active = false;
    }

 function finalize_Auction(uint auctionId) public {
        
        Auction memory myAuction = auctions[auctionId];
        uint bidsLength = auctionBids[auctionId].length;
        // if auction not ended revert it;
        require(block.timestamp <= myAuction.blockDeadline,"auction is running");
        require(auctions[auctionId].finalized,"auction already finalized");
        // if there are no bids cancel
        if(bidsLength == 0) {
            cancel_Auction(auctionId);
        }
        else{

            // money transfer to aution owner
            Bid memory lastBid = auctionBids[auctionId][bidsLength - 1];
            if(!payable (myAuction.owner).send(lastBid.amount)) {
                revert();
            }
            // approve and transfer from this contract to the bid winner 
            if(approveWithTransfer(myAuction.owner, lastBid.from, myAuction.tokenId)){
                auctions[auctionId].active = false;
                auctions[auctionId].finalized = true;
            }
        }
 }

}