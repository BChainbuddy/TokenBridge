// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title Token
 * @dev The Token contract represents an ERC20 token with added functionalities for bridging operations.
 */
contract Token is ERC20 {
    constructor() ERC20("Token", "TOK") {
        owner = msg.sender;
    }

    address public tokenBridge;
    address private immutable owner;

    /**
     * @dev Modifier to ensure that only the specified token bridge contract can access the functions.
     */
    modifier isTokenBridge() {
        require(
            msg.sender == tokenBridge,
            "Can only be called from the bridge"
        );
        _;
    }

    /**
     * @dev Modifier to restrict function access to the owner of the contract.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "address not the owner");
        _;
    }

    /**
     * @dev Adds the bridge address for restriction. Allows contract upgrades by changing the bridge address.
     * @param _address Address of the bridge contract to be added.
     */
    function addTokenBridgeAddress(address _address) external onlyOwner {
        tokenBridge = _address;
    }

    /**
     * @dev Internal function to mint tokens.
     * @param to Address to which tokens are minted.
     * @param amount Amount of tokens to be minted.
     */
    function _mint(address to, uint256 amount) internal override {
        super._mint(to, amount);
    }

    /**
     * @dev Internal function to burn tokens.
     * @param account Address from which tokens are burned.
     * @param amount Amount of tokens to be burned.
     */
    function _burn(address account, uint256 amount) internal override {
        super._burn(account, amount);
    }

    /**
     * @dev Allows the bridge contract to mint tokens.
     * @param account Address to which tokens are minted.
     * @param amount Amount of tokens to be minted.
     */
    function bridgeMint(
        address account,
        uint256 amount
    ) external isTokenBridge {
        _mint(account, amount);
    }

    /**
     * @dev Allows the bridge contract to burn tokens.
     * @param account Address from which tokens are burned.
     * @param amount Amount of tokens to be burned.
     */
    function bridgeBurn(
        address account,
        uint256 amount
    ) external isTokenBridge {
        _burn(account, amount);
    }

    /**
     * @dev Retrieves the address of the associated token bridge contract.
     * @return Address of the token bridge contract.
     */
    function tokenBridgeAddress() public view returns (address) {
        return tokenBridge;
    }

    /**
     * @dev Function allowing the owner to mint tokens to a specified address.
     * @param _address Address to which tokens are minted.
     * @param _amount Amount of tokens to be minted.
     */
    function mintTokens(address _address, uint256 _amount) public onlyOwner {
        _mint(_address, _amount);
    }
}
