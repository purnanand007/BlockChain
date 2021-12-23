There are two files that are attached to each other :
File 1 : nft.sol // to creation of a NFT
File 2 : nftAuction.sol  // TO create a auction for already built NFT in File 1. 

First File 1 should be compiled then File 2 

All files have been implemented using Remix ide

Instruction to Implement File 1:

1.Run nft.sol on remix.
2.Deploy contract, it will take one parameter as royalty value.
3.Mint allready created NFT metadata by using "safeMint" function.It will take 2 parameters one is address of owner and 2nd is link of metadata.
4.you can transfer your mited nft to anyone by using "safeTransferFrom" function.
5.Store the address of this contract.

Instruction to Implement File 2:

1. Run nftAuction.sol on remix.
2. Deploy contract, it will take parameter as the address of nft.sol contract that we have saved in above deployment of nft.sol.
3.Create Auction by using "create_Auction" function for NFT : Only owner of nft can create auction.
  create_Auction function takes 5 parameters as , TokenId of NFT, nameOfAuction,initialBid,DeadlineTime in sec,address of NFT.
4.Now other than owner anyone can apply bid using "bidOverAuction" function.
	This function takes bid value in value field (bid value > intial bid or highest bid till then) , and auction id ;
5. Owner can cancel bid using "cancel_Bid" function.
6. "finialize_Auction" function will transfer nft onership to highest bider.
	