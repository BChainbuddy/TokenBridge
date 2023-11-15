// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

// import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

interface IERC20 {
    function bridgeBurn(address account, uint256 amount) external;

    function bridgeMint(address account, uint256 amount) external;
}

contract TokenBridge {
    IERC20 public immutable token;
    using ECDSA for bytes32;

    enum transferType {
        SEND,
        RECEIVE
    }

    event Transfer(
        address indexed _address,
        uint256 _amount,
        uint256 _nonce,
        bytes signature,
        transferType _type
    );

    constructor(address _token) {
        token = IERC20(_token);
    }

    // To see if it was completed and to check which nonce is current one in address mapping
    mapping(address => uint256) public currentNonce;
    mapping(address => mapping(uint256 => bool)) public nonceInProgress;

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

    // This needs to get signed to get allowance to call burn and mint function
    function messageHash(
        address _address,
        uint256 amount
    ) public view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    "\x19\x01", // Ethereum prefix for message format
                    keccak256(
                        abi.encode(_address, amount, getCurrentNonce(_address))
                    ) // Adds the current nonce of the address automaticaly
                )
            );
    }

    // To check if the signer has signed the message
    function verifySignature(
        address signer,
        bytes32 hashedMessage,
        bytes calldata signature
    ) internal pure returns (bool) {
        return signer == hashedMessage.recover(signature);
    }

    // Return the current nonce
    function getCurrentNonce(address _address) public view returns (uint256) {
        return currentNonce[_address];
    }
}
