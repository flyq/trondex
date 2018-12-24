pragma solidity ^0.4.23;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


/**
 * Utility library of inline functions on addresses
 */
library Address {
    /**
     * Returns whether the target address is a contract
     * @dev This function will return false if invoked during the constructor of a contract,
     * as the code is not actually created until after the constructor finishes.
     * @param account address of the account to check
     * @return whether the target address is a contract
     */
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // XXX Currently there is no better way to check if there is a contract in an address
        // than to check the size of the code at that address.
        // See https://ethereum.stackexchange.com/a/14016/36603
        // for more details about how this works.
        // TODO Check this again before the Serenity release, because all addresses will be
        // contracts then.
        // solium-disable-next-line security/no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}


/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}


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
    function addfav(address contractAddr) external;
    function removefav(address contractAddr) external;
    function buyByTRX(address askContractAddr, uint256 askAmount) external payable;
    function buyByERC20Token(address askContractAddr, uint256 askAmount, address bidContractAddr, uint256 bidAmount) external;
    function sellForTRX(uint256 askTRXAmount, address bidContractAddr, uint256 bidAmount) external;
    function cancelSell(address bidContractAddr, uint256 id) external;
    function cancelBuy(address askContractAddr, uint256 id) external;
    function setWhitelist(address contractAddr) external;
    function rmWhitelist(address contractAddr) external;
    function isInWhitelist(address contractAddr) external;

    function transferERC721Token(address contractAddr, uint256 tokenId) external;
    function transferERC20Token(address contractAddr, uint256 amount) external;
    function transferTRX(uint256 amount) external;
}


contract PauserRole {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender));
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(msg.sender);
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is PauserRole {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    /**
     * @return true if the contract is paused, false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}


contract Exchange is Pausable, IExchange {
    using SafeMath for uint256;
    using Address for address;


    // 如果是trx，则contractAddr为address(1);
    struct Token {
        address contractAddr;
        uint256 amount;
    }
    mapping(address => mapping(uint256 => Token)) public tranx;
    mapping(address => bool) public whitelist;


    event Addfav(string indexed symbol, address indexed contractAddr, address indexed account);
    event Removefav(string indexed symbol, address indexed contractAddr, address indexed account);
    event BuyByTRX(address indexed askContractAddr, uint256 askAmount, uint256 indexed bidTRXAmount, address indexed account);
    event BuyByERC20Token(address indexed askContractAddr, uint256 askAmount, address indexed bidContractAddr, uint256 bidAmount, address indexed account);
    event SellForTRX(uint256 askTRXAmount, address bidContractAddr, uint256 bidAmount, address indexed account);
    event CancelSell(address bidContractAddr, uint256 id, address account);
    event CancelBuy(address askContractAddr, uint256 id, address account);
    event SetWhitelist(address contractAddr);
    event RmWhitelist(address contractAddr);
    event TransferERC721Token(address contractAddr, uint256 tokenId);
    event TransferERC20Token(address contractAddr, address to);
    event TransferTRX(uint256 amount, address to);
    
    constructor() public {}
    
    function transferERC721Token(address contractAddr, uint256 tokenId) public onlyPauser {
        require(contractAddr.isContract());
        IERC721 _tokenobj = IERC721(contractAddr);
        _tokenobj.safeTransferFrom(address(this), msg.sender, tokenId);

        emit TransferERC721Token(contractAddr, tokenId);
    }

    function transferERC20Token(address contractAddr, uint256 amount) public onlyPauser {
        require(contractAddr.isContract());
        IERC20 _tokenobj = IERC20(contractAddr);
        _tokenobj.transfer(msg.sender, amount);

        emit TransferERC20Token(contractAddr, msg.sender);
    }

    function transferTRX(uint256 amount) public onlyPauser {
        msg.sender.transfer(amount);

        emit TransferTRX(amount, msg.sender);
    }

    function addfav(address contractAddr) public {
        IERC20 _tokenobj = IERC20(contractAddr);
        string memory _symbol = _tokenobj.symbol();

        emit Addfav(_symbol, contractAddr, msg.sender);
    }

    function removefav(address contractAddr) public {
        IERC20 _tokenobj = IERC20(contractAddr);
        string memory _symbol = _tokenobj.symbol();

        emit Removefav(_symbol, contractAddr, msg.sender);        
    }

    function buyByTRX(address askContractAddr, uint256 askAmount) public payable whenNotPaused {
        require(msg.value > 0);
        require(askAmount > 0);
        require(isInWhitelist(askContractAddr));

        Token memory _token = Token({contractAddr:address(1), amount:msg.value});
        tranx[msg.sender][block.number] = _token;

        emit BuyByTRX(askContractAddr, askAmount, msg.value, msg.sender);
    }

    function buyByERC20Token(
        address askContractAddr, 
        uint256 askAmount, 
        address bidContractAddr,
        uint256 bidAmount
        )
        public
        whenNotPaused
    {
        require(isInWhitelist(askContractAddr) && isInWhitelist(bidContractAddr));
        require(askAmount > 0 && bidAmount > 0);

        IERC20 _tokenobj = IERC20(bidContractAddr);
        _tokenobj.transferFrom(msg.sender, address(this), bidAmount);

        Token memory _token = Token({contractAddr:bidContractAddr, amount:bidAmount});
        tranx[msg.sender][block.number] = _token;

        emit BuyByERC20Token(askContractAddr, askAmount, bidContractAddr, bidAmount, msg.sender);
    }

    function sellForTRX(uint256 askTRXAmount, address bidContractAddr, uint256 bidAmount) 
        public
        whenNotPaused
    {
        require(isInWhitelist(bidContractAddr));
        require(askTRXAmount > 0 && bidAmount > 0);
        
        IERC20 _tokenobj = IERC20(bidContractAddr);
        _tokenobj.transferFrom(msg.sender, address(this), bidAmount);

        emit SellForTRX(askTRXAmount, bidContractAddr, bidAmount, msg.sender);
    }

    function cancelSell(address bidContractAddr, uint256 id) public whenNotPaused {
        require(isInWhitelist(bidContractAddr));

        emit CancelSell(bidContractAddr, id, msg.sender);
    }

    function cancelBuy(address askContractAddr, uint256 id) public whenNotPaused {
        require(isInWhitelist(askContractAddr));

        emit CancelBuy(askContractAddr, id, msg.sender);
    }

    function setWhitelist(address contractAddr) public onlyPauser {
        require(contractAddr.isContract());
        require(!whitelist[contractAddr]);

        whitelist[contractAddr] = true;

        emit SetWhitelist(contractAddr);
    }

    function rmWhitelist(address contractAddr) public onlyPauser {
        require(whitelist[contractAddr]);

        whitelist[contractAddr] = false;

        emit RmWhitelist(contractAddr);
    }

    function isInWhitelist(address contractAddr) public view returns(bool) {
        return whitelist[contractAddr];
    }
}