// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StableCoin is ERC20, ERC20Burnable, Ownable {
    mapping(address => bool) public blacklist;

    event AddedToBlacklist(address indexed account);
    event RemovedFromBlacklist(address indexed account);

    constructor(string memory _name, string memory _symbol, uint _supply )
        ERC20(_name, _symbol)
        Ownable(msg.sender)
    {
        _mint(msg.sender, _supply * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function addToBlacklist(address _account) external onlyOwner {
        blacklist[_account] = true;
        emit AddedToBlacklist(_account);
    }

    function removeFromBlacklist(address _account) external onlyOwner {
        blacklist[_account] = false;
        emit RemovedFromBlacklist(_account);
    }

    function decimals() public pure override returns (uint8) {
        return 6;
    }

    function transfer(address to, uint256 amount)
        public
        override
        notBlacklisted(msg.sender)
        notBlacklisted(to)
        returns (bool)
    {
        return super.transfer(to, amount);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override notBlacklisted(from) notBlacklisted(to) returns (bool) {
        return super.transferFrom(from, to, amount);
    }

    modifier notBlacklisted(address _account) {
        require(!blacklist[_account], "Account is blacklisted");
        _;
    }
}
