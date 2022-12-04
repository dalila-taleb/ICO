const { ethers } = require("hardhat");
require("dotenv").config({ path : ".env"});
const { CRYPTO_DEVS_NFT_CONTRACT_ADDRESS } = require("../constants");

async function main() {
  // Address of the Crypto Devs NFT contract that you deployed in the previous module
  const cryptoDevsNFTContract = CRYPTO_DEVS_NFT_CONTRACT_ADDRESS;
  console.log("********************************");
  console.log("************Processing**********");
  console.log("********************************");
  console.log("Basis on Crypto Devs NFT contract address : ", cryptoDevsNFTContract )

  /**
   * A ContractFactory
   */
  const cryptoDevsTokenContract = await ethers.getContractFactory("CryptoDevToken");
  console.log("1- Instantiation of Cryto Devs Tokens contract... ");

  // Deploy the contract
  const deployedCryptoDevsTokenContract = await cryptoDevsTokenContract.deploy(cryptoDevsNFTContract);
  console.log("2- Deployement of Cryto Devs Tokens contract... ");

  await deployedCryptoDevsTokenContract.deployed();

  console.log(
    "Crypto Devs Token Contract was deployed succesfuly to the address : ", 
    deployedCryptoDevsTokenContract.address
  );
}

// Call the main function and catch errors, if any.
main()
  .then(() => process.exit(0))
  .catch((error) => {
  console.error(error);
  process.exit(1);
});
