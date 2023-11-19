# Decentralized Cryptocurrency Bridge

This repository contains smart contracts enabling decentralized cross-chain bridging of tokens, enhancing user autonomy through signature-based operations.

## Contracts Overview

### Token Contract - `Token.sol`

The `Token.sol` contract manages the token functionalities, serving as the foundational unit for the bridge operations.

- **Deployment**
  - Deploy this contract initially on the desired networks.
  - **Usage**
    - Grants permission for the associated bridge contract to perform token minting and burning functions.
    - **Note**: In case of a new bridge contract deployment, update the reference within this contract accordingly.

### Bridge Contract - `Bridge.sol`

The `Bridge.sol` contract facilitates cross-chain token transfers with a decentralized approach using ECDSA signatures.

- **Features**
  - **Signature-Based Bridging**
    - Users initiate token bridging by signing a hashed message containing sender account, token amount, and a managed nonce.
  - **Token Transfer Process**
    - `sendTokens`: Initiates the burning of specified tokens by the sender.
    - `receiveTokens`: Allows the receiver to obtain tokens on the destination network after successful validation.
  - **Nonce Management**
    - Nonces are managed automatically for decentralized and non-repeating usage.
  - **Events**
    - `Transfer` event emits transfer details for automated send and receive operations.

### Usage Instructions

1. **Deployment Process**
    - Deploy the `Token` contract first to enable bridge permissions.
    - Subsequently, deploy the `TokenBridge` contract on the desired networks.

2. **Token Bridging Steps**
    - Users need to sign a hashed message containing sender, token amount, and a managed nonce for initiating token transfers.
    - Users can get the hash from function `messageHash`
    - Utilize `sendTokens` to burn tokens for transfer. The user needs to input account(user contract), amount(how much they want bridged, signature of hash including last two inputs)
    - The function `verifySignature` acts as a protector, because processes the signature and returns true only if the signature was really signed by the address that wants to get tokens bridge.
    - Upon successful validation, execute `receiveTokens` on the destination network to mint tokens. The user needs to input same values as they did in `sendTokens` function.

3. **Considerations**
    - Enhance user experience by implementing a listener to automate token crediting based on emitted events.
    
### Deploy Contract
    ```yarn hardhat deploy --network <network_name>```

### Test the Contract
    ```yarn hardhat test```

## Contribution

We welcome contributions from the community. If you'd like to contribute, please follow these guidelines:

1. Fork the repository.
2. Create a branch: `git checkout -b feature/your-feature-name`.
3. Commit your changes: `git commit -am 'Add some feature'`.
4. Push to the branch: `git push origin feature/your-feature-name`.
5. Submit a pull request.

Please make sure to update tests as appropriate and adhere to the code of conduct.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.



