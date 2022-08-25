const hre = require("hardhat");

async function main() {
    const KRN = await hre.ethers.getContractFactory("Kronos");
    const krn = await KRN.deploy();

    await krn.deployed();

    console.log("Kronos deployed to:", krn.address);


}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });