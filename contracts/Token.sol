// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    constructor() ERC20("Token", "TOK") {
        owner = msg.sender;
    }

    address public tokenBridge;
    address private immutable owner;

    modifier isTokenBridge() {
        require(
            msg.sender == tokenBridge,
            "Can only be called from the bridge"
        );
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "address not the owner");
        _;
    }

    // ADDS the bridge address for restriction, if we need to we can change the contract, if we develop any upgrades, the old one will aswell lose the access
    function addTokenBridgeAddress(address _address) external onlyOwner {
        tokenBridge = _address;
    }

    function _mint(address to, uint256 amount) internal override {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount) internal override {
        super._burn(account, amount);
    }

    //MINT in the bridge
    function bridgeMint(
        address account,
        uint256 amount
    ) external isTokenBridge {
        _mint(account, amount);
    }

    //BURN in the bridge
    function bridgeBurn(
        address account,
        uint256 amount
    ) external isTokenBridge {
        _burn(account, amount);
    }

    function tokenBridgeAddress() public view returns (address) {
        return tokenBridge;
    }
}
