pragma solidity ^0.4.18;
import "./ONSGS1Code.sol";

contract ONSRecord {

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
    bytes32 service; //url.... is it needed??
    string regexp;
    //string replacement;
    //extended properties
    uint8 state; //0 : inactive, 1 : active
    ServiceType serviceType;
    FlexibleServiceType flexibleServiceType;
  }

  struct RecordResult
  {
    uint8 flags;
    bytes32 service; //url.... is it needed??
    string regexp;
  }

  struct ONSCoreData {
    address provider; //allowed user to register record for the gs1 code.
    bytes32 gs1Code;
    uint256 maxRecodeId;
    Record[] recordList;
  }

  mapping(bytes32=>ONSCoreData) onsCoreDataList;

  function ONSRecord() {
    // constructor
  }

  function isExistONSCoreDataByGS1Code(bytes32 gs1Code) public view returns(bool) {
    //gs1CodeList에 owner가 정상적인지 확인.
    if (onsCoreDataList[gs1Code].gs1Code == gs1Code)
      return true;
    return false;
  }

  function getProvider(bytes32 gs1Code) public view returns(bool, address) {
    //gs1CodeList에 owner가 정상적인지 확인.
    if (onsCoreDataList[gs1Code].gs1Code != gs1Code)
      return (false, address(0));

    return onsCoreDataList[gs1Code].provider;
  }

  function addRecord(byte32 gs1Code, uint8 flags, bytes32 service, string regexp) public returns(bool){
    if (getAllowedProvider(gs1Code) != msg.sender)
      return false;

    ONSCoreData onsCoreData;
    if (isExistONSCoreDataByGS1Code(gs1Code) == false) {
      onsCoreData = ONSCoreData(msg.sender, gs1Code, 0);
      onsCoreDataList[gs1Code] = onsCoreData;
    }else
      onsCoreData = onsCoreDataList[gs1Code];

    Record record = Record(flags, service, regexp, 0);
    onsCoreData.recordList[onsCoreData.recodeId] = record;
    onsCoreData.recordList[onsCoreData.recodeId].maxRecodeId++;
    return true;
  }

  function removeRecord(byte32 gs1Code, uint8 recordId) public returns(bool){
    require(recordId >= 0);
    require(onsCoreDataList[gs1Code].maxRecodeId > recordId);

    if (getAllowedProvider(gs1Code) != msg.sender)
      return false;

    delete onsCoreDataList[gs1Code].recordList[recordID];
    onsCoreDataList[gs1Code].maxRecodeId--;
    return true;
  }

  function getRecordCount(bytes32 gs1Code) public returns(uint256) {
    require(recordId >= 0);
    require(onsCoreDataList[gs1Code].maxRecodeId > recordId);
    require(getGS1CodeState(gs1Code) == ACTIVE);
    return onsCoreDataList[gs1Code].maxRecodeId;
  }

  function getRecord(bytes32 gs1Code, uint256 recordId) public returns(RecordResult) {
    require(recordId >= 0);
    require(onsCoreDataList[gs1Code].maxRecodeId > recordId);
    require(getGS1CodeState(gs1Code) == ACTIVE);
    return RecordResult(onsCoreDataList[gs1Code].recordList[recordId].flags,
                        onsCoreDataList[gs1Code].recordList[recordId].service,
                        onsCoreDataList[gs1Code].recordList[recordId].regexp);
  }

  function addFlexibleServiceType(byte32 gs1Code, uint256 recordId, string[] _keys, string[] _values) public returns(bool){
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

  function removeFlexibleServiceType(byte32 gs1Code, uint256 recordId) public returns(bool){
    require(recordId >= 0);
    require(onsCoreDataList[gs1Code].maxRecodeId > recordId);

    if (getAllowedProvider(gs1Code) != msg.sender)
      return false;

    uint maxKeyIdx = onsCoreDataList[gs1Code].recordList[recordId].flexibleServiceType.keys.length;
    string key;
    for (uint i = 0; i < maxKeyIdx; ++i) {
      key = onsCoreDataList[gs1Code].recordList[recordId].flexibleServiceType.keys[i];
      delete onsCoreDataList[gs1Code].recordList[recordId].flexibleServiceType.items[key];
      delete onsCoreDataList[gs1Code].recordList[recordId].flexibleServiceType.keys[i];
    }
    onsCoreDataList[gs1Code].recordList[recordId].flexibleServiceType.keys.length = 0;
    return true;
  }
}
