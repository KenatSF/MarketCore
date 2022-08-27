// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ERC20 } from '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import { AccessControl } from  '@openzeppelin/contracts/access/AccessControl.sol';

contract Kronos is ERC20, Ownable, AccessControl {

    uint256 private _maxSupply = 100000000*1e18;

    bytes32 public constant ROL_MINTER = keccak256("ROL_MINTER");

    constructor() ERC20("Kronos", "KRN") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ROL_MINTER, msg.sender);
    }

    modifier onlyMinter() {
        require(hasRole(ROL_MINTER, msg.sender), "Only a minter can execute this function!");
        _;
    }

    function maxSupply() public view virtual returns (uint256) {
        return _maxSupply;
    }

    function addMinter(address account) public virtual onlyOwner {
        _grantRole(ROL_MINTER,account);
    }

    function removeMinter(address account) public virtual onlyOwner {
        _revokeRole(ROL_MINTER, account);
    }

    function mint(address account, uint256 amount) public virtual onlyMinter {
        require((totalSupply() + amount) <= maxSupply(), "Max Supply reached!");
        _mint(account, amount);
    }

    function burn(uint256 amount) public virtual {
        _burn(msg.sender, amount);
    }
    
}