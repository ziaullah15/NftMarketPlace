// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract Market {
    enum ListingStatus {
        Active,
        Sold,
        Cancelled
    }

    struct Listing {
        ListingStatus status;
        address seller;
        address token;
        address royalityOwnerAdd;
        uint tokenId;
        uint price;
        bool sold;
    }

    event Listed(
        uint listingId,
        address seller,
        address token,
        uint tokenId,
        uint price,
        bool sold
    );

    event Sale(
        uint listingId,
        address buyer,
        address token,
        uint tokenId,
        uint price,
        bool sold
    );

    event Cancel(uint listingId, address seller);

    uint private _listingId = 0;
    mapping(uint => Listing) private _listings;
    mapping(address => Listing[]) public getData;
    Listing[] public listingsArray;

    function listToken(
        address token,
        uint tokenId,
        uint price
    ) external {
        IERC721(token).transferFrom(msg.sender, address(this), tokenId);

        Listing memory listing = Listing(
            ListingStatus.Active,
            msg.sender,
            token,
            // IERC721(token).ownerOf(tokenId),
            msg.sender,
            tokenId,
            price * 1**1,
            false
        );

        _listingId++;

        _listings[_listingId] = listing;

        //this line will push property into listings Array
        listingsArray.push(listing);
        getData[msg.sender].push(listing);

        emit Listed(_listingId, msg.sender, token, tokenId, price, false);
    }

    //now we will make a function which will return a complete array which has mapping
    function GetAllListings() public view returns (Listing[] memory) {
        return listingsArray;
    }

    //this function will delete an item on provided index number in array

    function deleteFromArray(uint256 _index) public {
        delete listingsArray[_index];
    }

    function getListing(uint listingId) public view returns (Listing memory) {
        return _listings[listingId];
    }

    function buyToken(uint listingId) external payable {
        Listing storage listing = _listings[listingId];

        require(_listings[listingId].sold == false, "listing id is sold");
        require(msg.sender != listing.seller, "Seller cannot be buyer");
        require(
            listing.status == ListingStatus.Active,
            "Listing is not active"
        );

        require(msg.value >= listing.price, "Insufficient payment");

        listing.status = ListingStatus.Sold;
        _listings[listingId].sold = true;

        IERC721(listing.token).transferFrom(
            address(this),
            msg.sender,
            listing.tokenId
        );
        payable(listing.seller).transfer(listing.price);

        emit Sale(
            listingId,
            msg.sender,
            listing.token,
            listing.tokenId,
            listing.price,
            listing.sold
        );
    }

    function cancel(uint listingId) public {
        Listing storage listing = _listings[listingId];

        require(msg.sender == listing.seller, "Only seller can cancel listing");
        require(
            listing.status == ListingStatus.Active,
            "Listing is not active"
        );

        listing.status = ListingStatus.Cancelled;

        IERC721(listing.token).transferFrom(
            address(this),
            msg.sender,
            listing.tokenId
        );

        emit Cancel(listingId, listing.seller);
    }
}
