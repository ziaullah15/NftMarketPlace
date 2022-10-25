const Tx = require("ethereumjs-tx").Transaction;
const Common = require("ethereumjs-common");
const Web3 = require("web3");
require("dotenv").config();
const PUBLIC_KEY = process.env.PUBLIC_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const MINT_CONTRACT = process.env.MINT_CONTRACT;
const MARKETPLACE_CONTRACT = process.env.MARKETPLACE_CONTRACT;

const customChainParams = { name: "tBNB", chainId: 97, networkId: 97 };
const common = Common.default.forCustomChain(
  "ropsten",
  customChainParams,
  "petersburg"
);

// const abi = require("./abi.json")
const abi = require("./Market.json");

const web3 = new Web3("https://data-seed-prebsc-1-s1.binance.org:8545");
const privateKey = Buffer.from(PRIVATE_KEY, "hex");

let contract = new web3.eth.Contract(abi, MARKETPLACE_CONTRACT, {
  from: PUBLIC_KEY,
});

async function listToken() {
  try {
    web3.eth.getTransactionCount(PUBLIC_KEY, (err, txCount) => {
      const txObject = {
        from: PUBLIC_KEY,
        to: MARKETPLACE_CONTRACT,
        nonce: web3.utils.toHex(txCount),
        gasLimit: web3.utils.toHex(10000000),
        gasPrice: web3.utils.toHex(web3.utils.toWei("10", "gwei")),
        data: contract.methods.listToken(2, 1, 1, 1).encodeABI(),
      };

      const tx = new Tx(txObject, { common });
      tx.sign(privateKey);

      const serealizeTransaction = tx.serialize();
      const raw = "0x" + serealizeTransaction.toString("hex");

      try {
        web3.eth.sendSignedTransaction(raw, (err, txHash) => {
          if (err) {
            console.log(err);
          } else {
            console.log("txHash:", txHash);
          }
        });
      } catch (error) {
        console.log("Error", error);
      }
    });
  } catch (error) {
    console.log("Error", error);
  }
}
listToken();