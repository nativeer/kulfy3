//Contract based on [https://docs.openzeppelin.com/contracts/3.x/erc721](https://docs.openzeppelin.com/contracts/3.x/erc721)
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract KulfyV3 is ERC721URIStorage, Ownable {
    mapping(uint256 => Kulfy) public kulfies;
    using Counters for Counters.Counter;
    Counters.Counter public tokenIds;

    constructor() ERC721("KULFY", "KUL") {}

    struct Kulfy {
        uint256 id;
        string kid;
        string tokenURI;
        string assetURI;
        uint256 tipAmount;
        address payable author;
    }

    event KulfyCreated(
        uint256 id,
        string hash,
        string kid,
        uint256 tipAmount,
        address payable author
    );

    event KulfyTipped(
        uint256 id,
        string hash,
        string kid,
        uint256 tipAmount,
        address payable author
    );

    function mintNFT(
        address payable recipient,
        string memory _tokenURI,
        string memory _assetURI,
        string memory _kid
    ) public returns (uint256) {
        tokenIds.increment();

        uint256 newItemId = tokenIds.current();
        _mint(recipient, newItemId);
        _setTokenURI(newItemId, _tokenURI);
        kulfies[newItemId] = Kulfy(
            newItemId,
            _kid,
            _tokenURI,
            _assetURI,
            0,
            recipient
        );
        
        emit KulfyCreated(
            newItemId,
            _tokenURI,
            _kid,
            0,
            recipient
        );

        return newItemId;
    }

    function tipKulfyOwner(uint256 _id) public payable {
        require(_id > 0 && _id <= tokenIds.current());
        Kulfy memory _kulfy = kulfies[_id];

        address payable _author = _kulfy.author;

        _author.transfer(msg.value);

        _kulfy.tipAmount = _kulfy.tipAmount + msg.value;

        kulfies[_id] = _kulfy;

        emit KulfyTipped(
            _id,
            _kulfy.tokenURI,
            _kulfy.kid,
            _kulfy.tipAmount,
            _author
        );
    }
}