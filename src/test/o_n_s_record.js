var ONSRecord = artifacts.require("./ONSRecord.sol");

contract('ONSRecord', function(accounts) {
  var onsR;
  it("testing ONSManager - deploy smart contract and add owner", function(done) {
    ONSRecord.deployed().then(function(instance) {
        onsR = instance;
        return onsR.getManager.call();
    }).then(function(result) {
        console.log("call getManager address --> " + result);
        return onsR.addOwner(accounts[1]);
    }).then(function(result) {
        console.log("call addOwner with " + accounts[1] + "--> " + result);
        return onsR.isExistOwner.call(accounts[1]);
    }).then(function(result) {
        console.log("call isExistOwner for " + accounts[1] + "--> " + result);
        return onsR.isExistOwner.call(accounts[2]);
    }).then(function(result) {
        console.log("call isExistOwner for " + accounts[2] + "--> " + result);
        return onsR.addOwner(accounts[2]);
    }).then(function(result) {
        console.log("call addOwner with " + accounts[2] + "--> " + result);
        return onsR.isExistOwner.call(accounts[2]);
    }).then(function(result) {
        console.log("call isExistOwner for " + accounts[2] + "--> " + result);
        return onsR.removeOwner(accounts[2]);
    }).then(function(result){
        console.log("call removeOwner for " + accounts[2] + "--> " + result);
        return onsR.isExistOwner.call(accounts[2]);
    }).then(function(result){
        console.log("call isExistOwner for " + accounts[2] + "--> " + result);
        return onsR.setManager(accounts[3]);
    }).then(function(result){
        console.log("call setManager for " + accounts[3] + "--> " + result);
        return onsR.getManager.call();
    }).then(function(result) {
        console.log("call getManager address --> " + result);
        return onsR.setManager(accounts[0], {from: accounts[3]});
    }).then(function(result) {
        console.log("call retrieve manager to accounts[0] --> " + result);
        return onsR.getManager.call();
    }).then(function(result) {
        console.log("call getManager address --> " + result);
        return onsR.addOwner(accounts[3]);
    }).then(function(result) {
        console.log("call addOwner with " + accounts[3] + "--> " + result);
        return onsR.getOwnerList.call();
    }).then(function(result) {
        console.log("call owner list --> " + result);
        return onsR.removeOwner(accounts[1]);
    }).then(function(result) {
        console.log("call removeOwner for " + accounts[1] + "--> " + result);
        return onsR.getOwnerList.call();
    }).then(function(result) {
        console.log("call owner list --> " + result);
        return onsR.addOwner(accounts[1]);
    }).then(function(result) {
        console.log("call  addOwner with " + accounts[1] + "--> " + result);
        return onsR.addOwner(accounts[5], {from: accounts[3]});
    }).catch(function(err) {
        console.log("call addOwner without permission : " + err);
        return false;
    }).then(function(result) {
        console.log("call addOwner with " + accounts[5] + "--> " + result);
        return onsR.addGS1Code("00000000000000", accounts[1], {from:accounts[0]});
    }).then(function(result) {
        console.log("call addGS1Code with gtin : 00000000000000, owner : " + accounts[1] + "--> " + result);
        return onsR.isExistGS1Code.call("00000000000000");
    }).then(function(result){
        console.log("call isExistGS1Code with gtin : 00000000000000 --> " + result);
        return onsR.addGS1Code("11111111111111", accounts[3], {from:accounts[0]});
    }).then(function(result) {
        console.log("call addGS1Code with gtin : 11111111111111, owner : " + accounts[3] + "--> " + result);
        return onsR.isExistGS1Code.call("11111111111111");
    }).then(function(result){
        console.log("call isExistGS1Code with gtin : 11111111111111 --> " + result);
        return onsR.getGS1CodeState.call("00000000000000");
    }).then(function(result){
        console.log("call getGS1CodeState with gtin : 00000000000000 --> " + result);
        return onsR.getGS1CodeState.call("11111111111111");
    }).then(function(result){
        console.log("call getGS1CodeState with gtin : 11111111111111 --> " + result);
        return onsR.changeGS1CodeState("00000000000000", 2);
    }).then(function(result){
        console.log("call changeGS1CodeState with gtin : 00000000000000 to active --> " + result);
        return onsR.changeGS1CodeState("11111111111111", 2);
    }).then(function(result){
        console.log("call changeGS1CodeState with gtin : 11111111111111 to active --> " + result);
        return onsR.getGS1CodeState.call("00000000000000");
    }).then(function(result){
        console.log("call getGS1CodeState with gtin : 00000000000000 --> " + result);
        return onsR.getGS1CodeState.call("11111111111111");
    }).then(function(result){
        console.log("call getGS1CodeState with gtin : 11111111111111 --> " + result);
        return onsR.getGS1CodeOwner.call("00000000000000");
    }).then(function(result){
        console.log("call getGS1CodeOwner with gtin : 00000000000000 --> " + result);
    }).then(function(result){
    }).then(function(result){
    }).then(function(result){
    }).then(function(result){
    });
    done();
  });
});
