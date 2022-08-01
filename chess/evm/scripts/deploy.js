const { network, baseURI } = require("hardhat");
const { proxies } = require("@tableland/evm/proxies.js");


const deploy = async function () {
  const registryAddress = network.name === "localhost" ? "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512" : proxies[network.name];
  // for active networks we need to deploy with the first account, which is specified in config
  // for local dev we need to deploy with an account that is different than the one the validator is using
  const [account0, account1] = await hre.ethers.getSigners();
  const account = network.name === "localhost" ? account1 : account0;

  const ChessToken = await hre.ethers.getContractFactory("ChessToken");
  const chessToken = await ChessToken.connect(account).deploy(baseURI, registryAddress);
  await chessToken.deployed();
  await chessToken.initCreateMetadata();
  await chessToken.initCreateMoves();

  console.log("Chess Token  deployed to:", chessToken.address, "By account:", account.address);

  const ChessPolicy = await hre.ethers.getContractFactory("ChessPolicy");
  const chessPolicy = await ChessPolicy.connect(account).deploy(chessToken.address);
  await chessPolicy.deployed();

  console.log("Chess Policy deployed to:", chessPolicy.address, "By account:", account.address);

  await chessToken.initSetController(chessPolicy.address);
};

deploy().then(() => {
  console.log("success");
}).catch(err => {
  console.log(err);
});