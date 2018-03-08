geth --cache 128 --networkid 4649 --nodiscover --maxpeers 0 --datadir /home/dalu/eth/privd/ --rpc --rpcaddr 0.0.0.0 --rpcport 8545 --rpccorsdomain * --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3 --unlock 0,1,2,3 --password /home/dalu/eth/privd/passwd

docker run --privileged --name geth -it -v d::/data ethereum/client-go attach http://198.13.60.39:8545
or
geth attach http://198.13.60.39:8545

// web3.eth.get
//transaction address는 web3.eth.getTransactionReceipt('tx id')로 알 수 있음.
/*
truffle.js file에 geth network 정보를 적어준다.
아래 예제에서 host는 test 목적으로 실행시켜 놓은 geth address이다.
module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  networks: {
    development: {
      host: "198.13.60.39",
      port: 8545,
      network_id: "*" // Match any network id
    }
  }
};
*/
truffle console을 실행한 후

web3.eth.getBlock(166);
{ difficulty: BigNumber { s: 1, e: 5, c: [ 141023 ] },
  extraData: '0xd783010801846765746887676f312e392e34856c696e7578',
  gasLimit: 114123401,
  gasUsed: 2772022,
  hash: '0x4a31d63a59db70be605efa96033563826508bb696b71b03bed01b3590c602ade',
  logsBloom: '0x0000000000000000000000000000000000000000000000000000000....
  miner: '0xf335831471a35efb6512c181c6c4c42627a50cd7',
  mixHash: '0xe112398697f8331b2bf56f694acbbf43ad4c2f6f1c4f326843de372b308a0513',
  nonce: '0x1c86083ee7d520c1',
  number: 166,
  parentHash: '0xb5a31a7c94d2df68e8a04c27a40250dc02558639bdc818b194df15992eb0f838',
  receiptsRoot: '0x8da41fbff23889cbaa41ac94562d8625f327747b531269c2968424765ee8d676',
  sha3Uncles: '0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347',
  size: 10997,
  stateRoot: '0xadf744cf5a168a5c6024d48f40888aa663c11fe944326937dd3c357ec461fac9',
  timestamp: 1520487927,
  totalDifficulty: BigNumber { s: 1, e: 7, c: [ 22590883 ] },
  transactions:
   [ '0x709b7831599d501fdedaabc70d9499b9e4fdb7b934724f72da0329353eca20ea' ],
  transactionsRoot: '0xf1dde0efcea7d272fa42bc8fbef4c086fa7f696f183744e7bdf31d5b5fe9d9b9',
  uncles: [] }

web3.eth.getTransaction('0x709b7831599d501fdedaabc70d9499b9e4fdb7b934724f72da0329353eca20ea')
{ blockHash: '0x4a31d63a59db70be605efa96033563826508bb696b71b03bed01b3590c602ade',
  blockNumber: 166,
  from: '0xf335831471a35efb6512c181c6c4c42627a50cd7',
  gas: 6721975,
  gasPrice: BigNumber { s: 1, e: 11, c: [ 100000000000 ] },

  ...... 생략 .....
  
    nonce: 2,
  to: null,
  transactionIndex: 0,
  value: BigNumber { s: 1, e: 0, c: [ 0 ] },
  v: '0x1b',
  r: '0xb38a724f81fcf9b9877cb8a77b554e485772f96059e9c7800ea26e1188f7f234',
  s: '0x30261fde30154a0a3d541bd92e33789d17f1e274bccd040029e3e7c7a318db6b' }

web3.eth.getTransactionReceipt('0x709b7831599d501fdedaabc70d9499b9e4fdb7b934724f72da0329353eca20ea')
{ blockHash: '0x4a31d63a59db70be605efa96033563826508bb696b71b03bed01b3590c602ade',
  blockNumber: 166,
  contractAddress: '0x340b161c77e7f87a0cabd99246b90854cddcad5a',
  cumulativeGasUsed: 2772022,
  from: '0xf335831471a35efb6512c181c6c4c42627a50cd7',
  gasUsed: 2772022,
  logs: [],
  logsBloom: '0x000000000000000000000....
  root: '0x6b02883454ae08c11c073f93de57f7eac118018d5c3923daf98042d39a6d2270',
  to: null,
  transactionHash: '0x709b7831599d501fdedaabc70d9499b9e4fdb7b934724f72da0329353eca20ea',
  transactionIndex: 0 }

contract를 
var contract1 = ONS.at('0x340b161c77e7f87a0cabd99246b90854cddcad5a');
truffle(development)> contract1.owner()
'0xf335831471a35efb6512c181c6c4c42627a50cd7' <-- this is a deployer address...
