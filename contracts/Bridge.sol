// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

// Interface for the ERC20 token used in the bridge
interface IERC20 {
    function bridgeBurn(address account, uint256 amount) external;

    function bridgeMint(address account, uint256 amount) external;
}

/**
 * @title TokenBridge
 * @dev The TokenBridge contract facilitates cross-chain token transfers via signature verification,
 * ensuring a decentralized and secure exchange mechanism between different networks.
 */
contract TokenBridge {
    IERC20 public immutable token;
    using ECDSA for bytes32;

    // Enumeration defining transfer types: SEND or RECEIVE
    enum transferType {
        SEND,
        RECEIVE
    }

    // Event emitted upon token transfer
    event Transfer(
        address indexed _address,
        uint256 _amount,
        uint256 _nonce,
        bytes signature,
        transferType _type
    );

    // Mapping to track the current nonce for each address
    mapping(address => uint256) public currentNonce;
    // Mapping to track whether a nonce is in progress for an address
    mapping(address => mapping(uint256 => bool)) public nonceInProgress;

    /**
     * @dev Constructor function to initialize the TokenBridge contract with the ERC20 token address.
     * @param _token Address of the ERC20 token contract used in the bridge.
     */
    constructor(address _token) {
        token = IERC20(_token);
    }

    /**
     * @dev Initiates the token transfer process by burning tokens from the sender's account.
     * @param _address Sender's address.
     * @param _amount Amount of tokens to be transferred.
     * @param signature Signature for verification of the transfer.
     */
    function sendTokens(
        address _address,
        uint256 _amount,
        bytes calldata signature
    ) external {
        require(
            nonceInProgress[_address][getCurrentNonce(_address)] == false,
            "Transaction hasn't been completed yet"
        ); //If the last nonce was in progress, the user can't send additional cryptocurrency.
        bytes32 hashedMessage = messageHash(_address, _amount);
        require(
            verifySignature(_address, hashedMessage, signature),
            "This transaction was not verified"
        ); // To check if the sender has signed the hash
        token.bridgeBurn(msg.sender, _amount); // NEED TO ADD CUSTOM INTERFACE
        nonceInProgress[_address][getCurrentNonce(_address)] = true; // The nonce is in progress

        // Transfer event for automatic send and receive
        emit Transfer(
            _address,
            _amount,
            getCurrentNonce(_address),
            signature,
            transferType.SEND
        );
    }

    /**
     * @dev Completes the token transfer process by minting tokens to the receiver's account.
     * @param _address Receiver's address.
     * @param _amount Amount of tokens to be received.
     * @param signature Signature for verification of the transfer.
     */
    function receiveTokens(
        address _address,
        uint256 _amount,
        bytes calldata signature
    ) external {
        require(
            nonceInProgress[_address][getCurrentNonce(_address)] == true,
            "The address hasn't sent any tokens"
        );
        bytes32 hashedMessage = messageHash(_address, _amount);
        require(
            verifySignature(_address, hashedMessage, signature),
            "This transaction was not verified"
        ); // To check if the sender has signed the hash
        token.bridgeMint(msg.sender, _amount); // NEED TO ADD CUSTOM INTERFACE

        // Transfer event for automatic send and receive
        emit Transfer(
            _address,
            _amount,
            getCurrentNonce(_address),
            signature,
            transferType.RECEIVE
        );

        // Increment the nonce
        currentNonce[_address]++;
    }

    /**
     * @dev Generates a hashed message for signature verification.
     * @param _address Sender's or Receiver's address.
     * @param amount Amount of tokens involved in the transaction.
     * @return Hashed message for signature verification.
     */
    function messageHash(
        address _address,
        uint256 amount
    ) public view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(_address, amount, getCurrentNonce(_address))
                // Adds the current nonce of the address automaticaly
            );
    }

    /**
     * @dev Verifies if the signer has signed the message.
     * @param signer Address of the signer.
     * @param hashedMessage Hashed message to be verified.
     * @param signature Signature provided for verification.
     * @return Boolean indicating whether the signature is verified or not.
     */
    function verifySignature(
        address signer,
        bytes32 hashedMessage,
        bytes calldata signature
    ) public pure returns (bool) {
        return
            signer == hashedMessage.toEthSignedMessageHash().recover(signature);
    }

    /**
     * @dev Retrieves the current nonce for an address.
     * @param _address Address for which nonce is to be retrieved.
     * @return Current nonce value for the address.
     */
    function getCurrentNonce(address _address) public view returns (uint256) {
        return currentNonce[_address];
    }
}
