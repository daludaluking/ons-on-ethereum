var ONSRecord = artifacts.require("./ONSRecord.sol");
//const Web3 = require("web3");
//const web3 = new Web3();

/*

    accounts[0] : Manager
    accounts[1] : Owner of "11111111111111"
    accounts[2] : Owner of "22222222222222"
    accounts[3] : Owner of "33333333333333"
    accounts[4] : Porvider
    accounts[5] : Porvider
    accounts[6] : Porvider
*/

contract('ONSRecord', function(accounts) {
  var onsR;
  var gtin1 = web3.fromAscii("11111111111111");
  var gtin2 = web3.fromAscii("22222222222222");
  var gtin3 = web3.fromAscii("33333333333333");

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
        return onsR.addOwner(accounts[2]);
    }).then(function(result) {
        console.log("call addOwner with " + accounts[2] + "--> " + result);
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
        console.log("call addOwner with " + accounts[1] + "--> " + result);
        return onsR.addOwner(accounts[5], {from: accounts[3]});
    }).catch(function(err) {
        console.log("call addOwner without permission : " + err);
        return false;
    }).then(function(result) {
        console.log("call addOwner with " + accounts[5] + "--> " + result);
        return onsR.addGS1Code(gtin1, accounts[1], {from:accounts[0]});
    }).then(function(result) {
        console.log("call addGS1Code with gtin : 11111111111111, owner : " + accounts[1] + "--> " + result);
        return onsR.isExistGS1Code.call(gtin1);
    }).then(function(result){
        console.log("call isExistGS1Code with gtin : 11111111111111 --> " + result);
        return onsR.addGS1Code(gtin2, accounts[3], {from:accounts[0]});
    }).then(function(result) {
        console.log("call addGS1Code with gtin : 22222222222222, owner : " + accounts[3] + "--> " + result);
        return onsR.isExistGS1Code.call(gtin2);
    }).then(function(result){
        console.log("call isExistGS1Code with gtin : 22222222222222 --> " + result);
        return onsR.getGS1CodeState.call(gtin1);
    }).then(function(result){
        console.log("call getGS1CodeState with gtin : 11111111111111 --> " + result);
        return onsR.getGS1CodeState.call(gtin2);
    }).then(function(result){
        console.log("call getGS1CodeState with gtin : 22222222222222 --> " + result);
        return onsR.changeGS1CodeState(gtin1, 2);
    }).then(function(result){
        console.log("call changeGS1CodeState with gtin : 11111111111111 to active --> " + result);
        return onsR.changeGS1CodeState(gtin2, 2);
    }).then(function(result){
        console.log("call changeGS1CodeState with gtin : 22222222222222 to active --> " + result);
        return onsR.getGS1CodeState.call(gtin1);
    }).then(function(result){
        console.log("call getGS1CodeState with gtin : 11111111111111 --> " + result);
        return onsR.getGS1CodeState.call(gtin2);
    }).then(function(result){
        console.log("call getGS1CodeState with gtin : 22222222222222 --> " + result);
        return onsR.getGS1CodeOwner.call(gtin1);
    }).then(function(result){
        console.log("call getGS1CodeOwner with gtin : 11111111111111 --> " + result);
        return onsR.changeOwnerOfGS1Code(gtin2, accounts[1], {from:accounts[3]});
    }).then(function(result){
        console.log("call changeOwnerOfGS1Code with gtin : 22222222222222 to " + accounts[1] + " --> " + result);
        return onsR.getGS1CodeOwner.call(gtin2);
    }).then(function(result){
        console.log("call getGS1CodeOwner of gtin : 22222222222222 --> " + result);
        return onsR.changeOwnerOfGS1Code(gtin2, accounts[3]);
    }).then(function(result){
        console.log("call changeOwnerOfGS1Code with gtin : 22222222222222 to " + accounts[3] + " --> " + result);
        return onsR.getGS1CodeOwner.call(gtin2);
    }).then(function(result){
        console.log("call getGS1CodeOwner of gtin : 22222222222222 --> " + result);
        return onsR.addGS1Code(gtin3, accounts[2]);
    }).then(function(result){
        console.log("call getGS1CodeOwner of gtin : 33333333333333 --> " + result);
        return onsR.addGS1Code(gtin3, accounts[2]);
    }).then(function(result){
        console.log("call addGS1Code of gtin : 33333333333333 --> " + result);
        return onsR.isExistGS1Code(gtin3);
    }).then(function(result){
        console.log("call isExistGS1Code of gtin : 33333333333333 --> " + result);
        return onsR.removeGS1Code(gtin3, accounts[2]);
    }).then(function(result){
        console.log("call removeGS1Code of gtin : 33333333333333 --> " + result);
        return onsR.getGs1CodeList.call();
    }).then(function(result){
        //console.log(gtin2);
        //console.log(web3.toAscii(gtin1));
        console.log("call getGs1CodeList --> ");
        for (var index = 0; index < result.length; index++) {
            var num_str = web3.toAscii(result[index]);
            console.log("index[" + index + "] : " + result[index]+" -> " + num_str);
        }
    }).then(function(result){
        return onsR.registerAllowedProvider(gtin1, accounts[4], {from:accounts[1]});
    }).then(function(result){
        console.log("call registerAllowedProvider of gtin1 with " + accounts[4] + " --> " + result);
        return onsR.getAllowedProviders.call(gtin1);
    }).then(function(result){
        console.log("call getAllowedProviders of gtin1  --> " + result);
        return onsR.isAllowedProvider.call(gtin1, accounts[4]);
    }).then(function(result){
        console.log("call isAllowedProvider of gtin1 and " +accounts[4]+ " --> " + result);
        return onsR.isAllowedProvider.call(gtin1, accounts[3]);
    }).then(function(result){
        console.log("call isAllowedProvider of gtin1 and " +accounts[3]+ " --> " + result);
        return onsR.registerAllowedProvider(gtin1, accounts[3], {from:accounts[1]});
    }).then(function(result){
        console.log("call registerAllowedProvider of gtin1 with " + accounts[4] + " --> " + result);
        return onsR.getAllowedProviders.call(gtin1);
    }).then(function(result){
        console.log("call getAllowedProviders of gtin1  --> " + result);
        return onsR.isAllowedProvider.call(gtin1, accounts[3]);
    }).then(function(result){
        console.log("call isAllowedProvider of gtin1 and " +accounts[3]+ " --> " + result);
        return onsR.deregisterAllowedProvider(gtin1, accounts[3], {from:accounts[1]});
    }).then(function(result){
        console.log("call deregisterAllowedProvider of gtin1 with " + accounts[3] + " --> " + result);
        return onsR.getAllowedProviders.call(gtin1);
    }).then(function(result){
        console.log("call getAllowedProviders of gtin1  --> " + result);
        //accounts[4] is a allowed provider of gtin1.
        return onsR.addRecord(gtin1, web3.fromAscii("u"), "http://example.com/service.html-just-for-test", "http://example.com/cgi-bin/epcis-just-for-test", {from:accounts[4]});
    }).then(function(result){
        console.log("call addRecord of gtin1  --> " + result);
        return onsR.addRecord(gtin1, web3.fromAscii("u"), "http://example.com/service2.html-just-for-test", "http://example.com/cgi-bin/epcis2-just-for-test", {from:accounts[4]});
    }).then(function(result){
        console.log("call addRecord of gtin1  --> " + result);
        return onsR.getRecordCount.call(gtin1);
    }).then(function(result){
        console.log("call getRecordCount of gtin1  --> " + result);
        return onsR.getRecord2.call(gtin1, 0);
    }).then(function(result){
        console.log("call getRecord of gtin1[0]  --> " + web3.toAscii(web3.toHex(result[0])) + ", " + result[1] + ", "  + result[2]);
    }).then(function(result){
        console.log("call getRecordCount of gtin1  --> " + result);
        return onsR.getRecord2.call(gtin1, 1);
    }).then(function(result){
        console.log("call getRecord of gtin1[1]  --> " + web3.toAscii(web3.toHex(result[0])) + ", " + result[1] + ", "  + result[2]);
        return onsR.removeRecord(gtin1, 0, {from:accounts[4]});
    }).then(function(result){
        console.log("call removeRecord of gtin1  --> " + result);
        return onsR.getRecord2.call(gtin1, 0);
    }).then(function(result){
        if (result[0] == 0)
            console.log("call getRecord of gtin1[0] --> id 0 is deleted.");
        else
            console.log("call getRecord of gtin1[0]  --> " + web3.toAscii(web3.toHex(result[0])) + ", " + result[1] + ", "  + result[2]);
    }).then(function(result){
    });
    done();
  });
});
