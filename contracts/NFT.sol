// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract NFT is ERC721 ,Ownable ,ERC721URIStorage {

     using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("Coolest NFT", "NFT") {
        Admin = msg.sender;
    }

//
    function _baseURI() internal pure override returns (string memory) {
        return "https://app.pinata.cloud/pinmanager/QmXmsJUrhaxXt8TjTgqiouSwt7nrichzT8ATbfEFb8EqNX";
    }

    //name symbol

    //TODAYS WORK
    address public Admin;
    uint256 private _tokenId = 0;
    string private VerificationKey;//Set by ONly Admin
	string public authentication;// input from User
    bool public verified;//default value false


	//function to take input and check it with a key set by Admin

	// function SetAuthentication(string memory _authentication)public {
	// 	// authentication = _authentication;
    //     if(keccak256(abi.encodePacked(_authentication)) == keccak256(abi.encodePacked(VerificationKey))){
    //          verified = true;

    //    }
	// }

    function setKey(string memory _VerificationKey) public {
        require(msg.sender == Admin,
		 "you aren't the Owner");
        VerificationKey = _VerificationKey;
    }
 
  //ye Function access provide kary ga Verification key ko Check karny ka

    function checkKey() public view returns (string memory) {
        require(msg.sender == Admin, 
		"you aren't the Owner,Only Admin can acess and modify");
		return VerificationKey;
    }

// _______agr dono keys same hngi to ye function true output kary ga


    
	function safeMint(address to,string memory uri,string memory _authentication) public onlyOwner {
        authentication = _authentication;
        if((keccak256(abi.encodePacked(authentication)) == keccak256(abi.encodePacked(VerificationKey)))){
        verified = true;
        }
        require(verified == true,"keys doesn't match");
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
    
		
		
        

        
    }


