// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ICryptoDevs.sol";

contract CryptoDevToken is ERC20, Ownable {
    // Price of one Crypto Dev token
    uint256 public constant tokenPrice = 0.001 ether;

    // Each NFT would give user 10 tokens
    // I need to be presented as 10 * (10 ** 18) as ERC20 tokens are represented by the smallest denomination possible
    // By default, ERC20 tokens <==> 10^18
    uint256 public constant tokenPerNFT = 10 * 10**18;

    // the max total supply is 10000 for Crypto Dev Tokens
    uint256 public constant maxTotalSupply = 10000 * 10**18;

    // Create CryptoDevsNFT contract instance of ICryptoDevs
    ICryptoDevs CryptoDevsNFT;

    // Mapping to keep track of which tokenIds have been claimed
    mapping(uint256 => bool) public tokenIdsClaimed;

    constructor(address _cryptoDevsContract) ERC20("Crypto Dev Token","CD") {
        CryptoDevsNFT = ICryptoDevs(_cryptoDevsContract);
    }

    /**
     * @dev Mints "amount' number of CryptoDevTokens
     * Requirements :
     * - 'msg.value' should be equal or greater than the tokenPrice * amount
     */

    function mint(uint256 amount) public payable {
        // The value of ether that should be equal or greater than TotalPrice * amount;
        uint256 _requiredAmount = tokenPrice * amount;
        require(msg.value >= _requiredAmount, "Ether sent is incorrect !");
        // total tokens + amount <= 10000, otherwise revert the transaction
        uint256 amountWithDecimals = amount * 10**18;

        require(
            (totalSupply() + amountWithDecimals) <= maxTotalSupply, "Exceeds the max total supply avaible."
        );
        // call the internal function from OpenZeppeline's ERC20 contract
        _mint(msg.sender, amountWithDecimals);
    }

    /**
     * @dev Mints tokens based on the number of NFT held by the sender
     * Requirements :
     * balance of Crypto Dev NFT's owned by the sender should be greater than 0
     * Tokns should have not been claimed for all the NFTs owned by the sender
     */
    
    function claim() public {
        address sender = msg.sender;

        // Get the number of CryptoDev NFT's held by the given sender address
        uint256 balance = CryptoDevsNFT.balanceOf(sender);

        // If the balance == 0 revert the transaction
        require(balance > 0, "You dont own Crypto Dev NFT's");

        // Amount keeps trak of number of Unclaimed tokendIds
        uint256 amount = 0;

        // Loop over the balance and get the tokenID ownedby 'sender' as a giver 'index'at a given index of its token index
        for (uint256 i=0; i < balance; i++) {
            uint256 tokenId = CryptoDevsNFT.tokenOfOwnerByIndex(sender, i);

            // if the tokenId has not been claimed, increase the amount
            if (!tokenIdsClaimed[tokenId]) {
                amount += 1;
                tokenIdsClaimed[tokenId] = true;
            } 
        }

        // if all the token Ids have been claimed, revert the transaction;
        require(amount > 0, "You have already clamed all the tokens !");

        // call the internal function from Openzeppelin's ERC20 contract
        _mint(msg.sender, amount * tokenPerNFT);
    }

    /**
     * @dev withdraws all ETH sent to this contract
     * Requirements :
     * wallet connected must be owner's address
     */

    function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        require(amount > 0, "Nothing to withdra; contract balance empty !");

        address _owner = owner();
        (bool sent, ) = _owner.call{value : amount}("");
        require(sent, "Failed to send Ether");
    }

    // Function to receive Ether, msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

}