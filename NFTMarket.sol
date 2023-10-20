// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts@5.0.0/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMarket is Ownable {
    address payable owner_;
    uint commission; // commison for owner

    struct Listing { // listing
        address nftAddress;
        uint price;
        uint tokenId;
        address seller;
        bool sold;
    }
    
    Listing[] listings; // all listings
    mapping (uint => uint) tokenToListing;

    constructor(address initialOwner) Ownable(initialOwner) { // setting owner and commission to 10%
        owner_ = payable(msg.sender);
        commission = 10;
    }

    function list(address _ntfAddress, uint _tokenId, uint _price) public { // list nft on marketplace for users to buy
        require(IERC721(_ntfAddress).ownerOf(_tokenId) == msg.sender, "Only owner can list");

        IERC721(_ntfAddress).transferFrom(msg.sender, address(this), _tokenId);

        listings.push(Listing(_ntfAddress, _price, _tokenId, msg.sender, false));
        tokenToListing[_tokenId] = listings.length - 1;
    }

    function buy(uint _id) public payable  { // buy nft and give 10% commision to owner
        Listing storage listing = listings[_id];

        uint overall = ((listing.price * commission) / 100) + listing.price;

        require(!listing.sold, "already sold");
        require(listing.seller != msg.sender, "can not buy your own nft");
        require(overall <= msg.value, "not enough funds");
        
        listing.sold = true;
        owner_.transfer((listing.price * commission) / 100);
        payable(listing.seller).transfer(listing.price);
        IERC721(listing.nftAddress).transferFrom(address(this), msg.sender, listing.tokenId);
    }

    function getListing(uint _id) public view returns(Listing memory) { // get all the listing on market place
        return listings[_id];
    }

    function withdraw() public onlyOwner { // withdraw from contract
        owner_.transfer(address(this).balance);
    }
}
