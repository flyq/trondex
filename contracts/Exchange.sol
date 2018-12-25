pragma solidity ^0.4.23;


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function symbol() external view returns (string);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title ERC721 Non-Fungible Token Standard basic interface
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract IERC721 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) public view returns (uint256 balance);
    function ownerOf(uint256 tokenId) public view returns (address owner);

    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);

    function transferFrom(address from, address to, uint256 tokenId) public;
    function safeTransferFrom(address from, address to, uint256 tokenId) public;

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes data) public;
}


interface IExchange {
    function exchange(uint256 askamount, uint256 bidamount, string ask, string bid) external;

    function transferERC721Token(address contractAddr, uint256 tokenId) external;
    function transferERC20Token(address contractAddr, uint256 amount) external;
    function transferTRX(uint256 amount) external;
}


contract Exchange {
    address public owner;

    event ExchangeToken(uint256 askamount, uint256 bidamount, string ask, string bid, address account);

    constructor() public {
        owner = msg.sender;
    }

    function transferERC721Token(address contractAddr, uint256 tokenId) public {
        require(msg.sender == owner);

        IERC721 _tokenobj = IERC721(contractAddr);
        _tokenobj.safeTransferFrom(address(this), msg.sender, tokenId);
    }

    function transferERC20Token(address contractAddr, uint256 amount) public {
        require(msg.sender == owner);

        IERC20 _tokenobj = IERC20(contractAddr);
        _tokenobj.transfer(msg.sender, amount);
    }

    function transferTRX(uint256 amount) public {
        require(msg.sender == owner);
        msg.sender.transfer(amount);
    }

    function exchange(uint256 askamount, uint256 bidamount, string ask, string bid) public {
        emit ExchangeToken(askamount, bidamount, ask, bid, msg.sender);
    }
}