// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BTC3 is ERC20("BTC3", "btc.33357.xyz") {
    uint256 public mintAmount = 10000 ether;
    uint256 public lastCheckBlock;
    uint256 public mintNumber;
    uint256 public difficulty = 30;

    mapping(address => mapping(uint256 => bool)) public minedNonces;

    event Minted(uint256 indexed mintNumber, address indexed sender, uint256 mintAmount, uint256 fee);

    modifier _check() {
        if (mintNumber != 0) {
            if (mintNumber % 10 == 0) {
                uint256 blocks = block.number - lastCheckBlock;
                if (blocks > 500) {
                    difficulty -= 1;
                } else {
                    difficulty += 1;
                }
                lastCheckBlock = block.number;
            }
            if (mintNumber % 1050 == 0) {
                mintNumber /= 2;
            }
        } else {
            lastCheckBlock = block.number;
        }
        _;
    }

    function mint(uint256 nonce) public _check {
        require(!minedNonces[msg.sender][nonce], "Nonce already used for mining");
        uint256 _hash = uint256(keccak256(abi.encodePacked(address(this), msg.sender, nonce)));
        require(_hash < ~uint256(0) >> difficulty, "Hash does not meet difficulty requirement");

        _mint(msg.sender, mintAmount);
        uint256 fee = balanceOf(address(this));
        if (fee > 0) {
            _transfer(address(this), msg.sender, fee);
        }
        emit Minted(mintNumber, msg.sender, mintAmount, fee);

        minedNonces[msg.sender][nonce] = true;
        mintNumber++;
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        require(mintNumber >= 1050, "Transfer not allowed until mintNumber is reached");
        uint256 fee = amount / 1000;
        _transfer(msg.sender, address(this), fee);
        _transfer(msg.sender, to, amount - fee);
        return true;
    }
}
