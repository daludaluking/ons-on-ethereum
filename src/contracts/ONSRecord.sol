pragma solidity ^0.4.18;
import "./ONSGS1Code.sol";

contract ONSRecord is ONSGS1Code{

  // Servicetype xml
  struct ServiceType
  {
    // ONS ServiceType properties
    bytes32 serviceTypeIdentifer;
    bool abstrct;
    bytes32 extends;
    string WSDL;
    string homepage;
    mapping(bytes32 => string) documentations;
    bytes32[] obsoletes;
    bytes32[] obsoletedBy;
  }

  struct FlexibleServiceType
  {
    mapping(string=>string) items;
    string[] keys;
  }

  struct Record
  {
    // ONS record properties
    //uint32 order;
    //uint32 pref;
    uint8 flags;
    string service; //url.... is it needed??
    string regexp;
    //string replacement;
    //extended properties
    uint8 state; //0 : inactive, 1 : active
    //TO-DO : service type과 차후에 추가한다.
    //ServiceType serviceType;
    //FlexibleServiceType flexibleServiceType;
  }

  struct RecordResult
  {
    uint8 flags;
    string service; //url.... is it needed??
    string regexp;
  }

  struct ONSCoreData {
    address firstProvider;
    bytes32 gs1Code;
    //address[] allowedProvider;
  }

  //EVM don't support the Nested Array
  mapping(bytes32=>Record[]) recordListMap;
  mapping(bytes32=>ONSCoreData) onsCoreDataList;
  mapping(bytes32=>address[]) allowedProviders;

  function ONSRecord() {
    // constructor
  }

  function isExistONSCoreDataByGS1Code(bytes32 gs1Code) public view returns(bool) {
    //gs1CodeList에 owner가 정상적인지 확인.
    if (onsCoreDataList[gs1Code].gs1Code == gs1Code)
      return true;
    return false;
  }

  function registerAllowedProvider(bytes32 gs1Code, address providerAddress)
  public
  onlyExistOwner(msg.sender)
  onlyOwner(gs1Code)
  returns(bool)
  {
    require(isExistOwner(msg.sender) == true);
    allowedProviders[gs1Code].push(providerAddress);
    return true;
  }

  function deregisterAllowedProvider(bytes32 gs1Code, address deletedProviderAddress)
  public
  onlyExistOwner(msg.sender)
  onlyOwner(gs1Code)
  returns(bool)
  {
    require(isExistOwner(msg.sender) == true);
    for (uint256 idx = 0; idx <  allowedProviders[gs1Code].length; ++idx) {
      if (allowedProviders[gs1Code][idx] == deletedProviderAddress)
        delete allowedProviders[gs1Code][idx];
    }
    return true;
  }

  function getAllowedProviders(bytes32 gs1Code)
  public
  view
  returns(address[])
  {
    require(gs1CodeList[gs1Code].index > 0);
    return allowedProviders[gs1Code];
  }

  function isAllowedProvider(bytes32 gs1Code, address providerAddr)
  public
  view
  returns(bool)
  {
    require(gs1CodeList[gs1Code].index > 0);
    for (uint256 idx = 0; idx <  allowedProviders[gs1Code].length; ++idx) {
      if (allowedProviders[gs1Code][idx] == providerAddr)
        return true;
    }
    return false;
  }

  function addRecord(bytes32 gs1Code, uint8 flags, string service, string regexp) public returns(bool){
    require(isAllowedProvider(gs1Code, msg.sender));

    if (isExistONSCoreDataByGS1Code(gs1Code) == false)
      onsCoreDataList[gs1Code] = ONSCoreData(msg.sender, gs1Code);
      //, new Record[](0));

    recordListMap[gs1Code].push(Record(flags, service, regexp, 0));
    //, FlexibleServiceType({keys:new string[](0)})));
    //onsCoreDataList[gs1Code].maxRecodeId++;
    return true;
  }

  function removeRecord(bytes32 gs1Code, uint8 recordId) public returns(bool){
    require(recordId >= 0);
    require(recordListMap[gs1Code].length > recordId);
    require(isAllowedProvider(gs1Code, msg.sender));
    /*
    delete onsCoreDataList[gs1Code].recordList[recordId];
    onsCoreDataList[gs1Code].maxRecodeId--;
    */
    delete recordListMap[gs1Code][recordId];
    //onsCoreDataList[gs1Code].maxRecodeId--;
    return true;
  }

  function getRecordCount(bytes32 gs1Code) public view returns(uint256) {
    require(getGS1CodeState(gs1Code) == GS1CodeState.ACTIVE);
    return recordListMap[gs1Code].length;//onsCoreDataList[gs1Code].maxRecodeId;
  }

  function getRecord(bytes32 gs1Code, uint256 recordId) public view returns(RecordResult) {
    require(recordId >= 0);
    //require(onsCoreDataList[gs1Code].maxRecodeId > recordId);
    require(recordListMap[gs1Code].length > recordId);
    require(getGS1CodeState(gs1Code) == GS1CodeState.ACTIVE);
    return RecordResult(recordListMap[gs1Code][recordId].flags,
                        recordListMap[gs1Code][recordId].service,
                        recordListMap[gs1Code][recordId].regexp);
  }

  function getRecord2(bytes32 gs1Code, uint256 recordId) public view returns(uint8, string, string) {
    require(recordId >= 0);
    //require(onsCoreDataList[gs1Code].maxRecodeId > recordId);
    require(recordListMap[gs1Code].length > recordId);
    require(getGS1CodeState(gs1Code) == GS1CodeState.ACTIVE);
    return (recordListMap[gs1Code][recordId].flags,
      recordListMap[gs1Code][recordId].service,
      recordListMap[gs1Code][recordId].regexp);
  }
  //TO-DO
  /*
  function addFlexibleServiceType(bytes32 gs1Code, uint256 recordId, string[] _keys, string[] _values) public returns(bool){
    require(recordId >= 0);
    require(_keys.length == _values.length);
    require(onsCoreDataList[gs1Code].maxRecodeId > recordId);

    if (getAllowedProvider(gs1Code) != msg.sender)
      return false;

    for (uint i = 0; i < _keys.length; ++i) {
      onsCoreDataList[gs1Code].recordList[recordId].flexibleServiceType.keys.push(_keys[i]);
      onsCoreDataList[gs1Code].recordList[recordId].flexibleServiceType.items[_keys[i]] = _values[i];
    }
    return true;
  }

  function removeFlexibleServiceType(bytes32 gs1Code, uint256 recordId) public returns(bool){
    require(recordId >= 0);
    require(onsCoreDataList[gs1Code].maxRecodeId > recordId);

    if (getAllowedProvider(gs1Code) != msg.sender)
      return false;

    uint maxKeyIdx = onsCoreDataList[gs1Code].recordList[recordId].flexibleServiceType.keys.length;
    string memory key;
    for (uint i = 0; i < maxKeyIdx; ++i) {
      key = onsCoreDataList[gs1Code].recordList[recordId].flexibleServiceType.keys[i];
      delete onsCoreDataList[gs1Code].recordList[recordId].flexibleServiceType.items[key];
      delete onsCoreDataList[gs1Code].recordList[recordId].flexibleServiceType.keys[i];
    }
    onsCoreDataList[gs1Code].recordList[recordId].flexibleServiceType.keys.length = 0;
    return true;
  }
  */
}
