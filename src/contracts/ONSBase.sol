pragma solidity ^0.4.18;
import "./ONSAccessControl.sol";
import "./ERC721.sol";

contract ONSBase is ONSAccessControl, ERC721{

  //gs1 code owner's information.
  //if owner's info for a account is not exit,
  //the account doesn't store anything.
  struct AccountInfo
  {
    address _address;
    bytes32 name;
    string url;
    string email;
    //list로 하면 loop을 돌아야 하는데...
    //일단 mapping으로.
    //uint256[] gs1CodeList;
    mapping(uint256 => bool) gs1CodeIndexes;
    //need more information?
  }

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

  struct ONSRecord
  {
    // ONS record properties
    //uint32 order;
    //uint32 pref;
    uint8 flags;
    bytes32 service;
    string regexp;
    //string replacement;
    //extended properties
    uint8 state; //0 : inactive, 1 : active
    uint serviceTypeIndex;
  }

  struct GS1Code {
    address owner;
    bytes32 gs1Code;
    mapping (uint256 => bool) onsRecordIndexes;
    bool active;
    mapping(string => string) extendedONSData;
  }

  //GS1Code 구조체의 배열
  GS1Code[] public gs1Codes;

  //ONSRecord 구조체의 배열
  //GS1Code 1 : N ONSRecord
  ONSRecord[] public onsRecords;

  //ONSRecord와 연결되는 ServiceType 구조체의 배열
  //ONSRecord 1 : 1 ServiceType
  ServiceType[] public serviceTypes;

  //GS1Code를 저장할 수 있는 권한을 가진 account의 info
  //account는 address를 가진다.
  AccountInfo[] public accountInfoList;

  //gs1 code와 GS1Code 구조체와의 매핑
  //GS1 Code에 mapping되는 GS1Code 구조체의 index를 저장함.
  //GS1 Code index는 GS1 Code를 참조하는 모든 mapping의 기준
  mapping (byte32 => uint256) public GS1CodeToIndex;

  //GS1 code index와 GS1 code 소유자 주소와 매핑
  //GS1 Code index에 mapping된 GS1 Code 소유자의 address
  mapping (uint256 => address) public GS1CodeIndexToOwner;

  //for account
  //accountInfo[addressToAccountInfoIndex[address]]._address == address
  //account address의 정보가 저장된 AccountInfo 배열의 index
  //GS1Code를 등록하기 위한 account는 여기 mapping정보가 있어야 한다.
  mapping (address => uint256) public addressToAccountInfoIndex;

  //addressToGS1CodeIndexes[address].push(gs1code index)
  //GS1Code의 소유자(account) index
  mapping (byte32 => uint256) public GS1CodeToOwnerIndex;

  //address가 가지는 GS1Code count;
  //account(address)가 가지고 있는(등록한 것이 아닌 현재 소유중인) GS1 code count
  mapping (address => uint256) public ownershipGS1CodeCount;

  //GS1Code index와 approved address와 mapping
  //GS1Code의 소유권 이전 transaction이 허용된 account 주소
  //GS1Code는 ERC721 Token interface를 지원하기 때문에
  //GS1Code는 account 간에 이전이 가능하다.
  mapping (uint256 => address) public GS1CodeIndexToApproved;

  function _owns(address _address, uint256 _gs1CodeId)
  internal
  view
  returns(bool)
  {
    if (GS1CodeIndexToOwner.length == 0) return false;
    return GS1CodeIndexToOwner[_tokenId] == _address;
  }

  function _isExistGS1Code(byte32 _gs1Code)
  internal
  view
  returns(bool)
  {
    if (GS1CodeToIndex.length == 0) return false;
    return (gs1Codes[GS1CodeToIndex[_gs1Code]].gs1Code == _gs1Code);
  }

  function _isExistOwnerInfo(address _address)
  internal
  view
  returns(bool)
  {
    if (accountInfoList.length == 0) return false;
    return (accountInfoList[addressToAccountInfoIndex[_address]]._address == _address);
  }

  modifier onlyAllowedAccount() {
    require(_isExistOwnerInfo(msg.sender));
    _;
  }

  //account가 가지고 있는 있는 GS1Code index
  //account는 여러개의 gs1 code를 등록할 수 있다.
  //mapping (address => uint256[]) public addressToGS1CodeIndexes;

  //GS1Code의 상태를 active(1) or inactive(0)으로 변경하는 함수.
  function _changeGS1CodeState(uint256 _gs1CodeID, bool state)
  internal
  onlyRoot
  {
    require(gs1Codes[_gs1CodeID].owner != address(0));
    gs1Codes[_gs1CodeID].state = state;
  }

  //ONS Record의 상태를 active(1) or inactive(0)으로 변경하는 함수.
  function _changeONSRecordState(uint256 _gs1CodeId, uint256 _onsRecordId, bool state)
  internal
  onlyRoot
  {
    require(gs1Codes[_gs1CodeId].owner != address(0));
    require(gs1Codes[_gs1CodeId].onsRecordIndexes[_onsRecordId] == true);
    onsRecords[_onsRecordId].state = state;
  }

  //ServicType을 ONSRecord와 연결
  function _addServiceTypeToONSRecord(uint256 _onsRecordId, uint256 _serviceTypeId)
  internal
  {
    require(onsRecords[_onsRecordId].state == 0
          ||onsRecords[_onsRecordId].state == 1);

    onsRecords[_onsRecordId].serviceTypeIndex = _serviceTypeId;
  }

  //ServicType을 ONSRecord에서 삭제
  function _removeServiceTypeFromONSRecord(uint256 _onsRecordId, uint256 _serviceTypeId)
  internal
  {
    require(onsRecords[_onsRecordId].serviceTypeIndex == _serviceTypeId);
    onsRecords[_onsRecordId].serviceTypeIndex = -1;
  }

  //ONSRecord의 index를 GS1Code에 저장
  function _addONSRecordToGS1Code(uint256 _gs1CodeId, uint256 _onsRecordId)
  internal
  {
    require(gs1Codes[_gs1CodeId].owner != address(0));
    gs1Codes[_gs1CodeId].onsRecordIndexes[_onsRecordId] = true;
  }

  //ONSRecord의 index를 GS1Code에서 삭제
  function _removeONSRecordFromGS1Code(uint256 _gs1CodeId, uint256 _onsRecordId)
  internal
  {
    require(gs1Codes[_gs1CodeId].owner != address(0));
    delete gs1Codes[_gs1CodeId].onsRecordIndexes[_onsRecordId];
  }

  function _addGS1CodeToAccount(address _address, uint256 _gs1CodeID)
  internal
  returns (bool)
  {
    if (_address != address(0)) {
      //GS1Code의 소유자를 저장
      GS1CodeIndexToOwner[_gs1CodeID] = _address;
      gs1Codes[_gs1CodeID].owner = _address;

      //address 소유자(account)의 gs1 code 소유 갯수를 하나 증가 시킨다.
      ownershipGS1CodeCount[_address]++;

      //account에 소유한 gs1code index를 저장.
      accountInfoList[addressToAccountInfoIndex[_address]].gs1CodeIndexes[_gs1CodeID] = true;
      return true;
    }
    return false;
  }

  //is this function needed??
  function _removeGS1CodeFromAccount(address _address, uint256 _gs1CodeId)
  internal
  returns (bool)
  {
    if (_address != address(0)) {
      //GS1Code Index의 소유자를 삭제한다.
      delete GS1CodeIndexToOwner[_gs1CodeId];
      gs1Codes[_gs1CodeID].owner = address(0);

      //address 소유자(account)의 gs1 code 소유 갯수를 하나 증가 시킨다.
      ownershipGS1CodeCount[_gs1CodeId]--;

      //account에 소유한 gs1code index를 삭제함.
      delete accountInfoList[addressToAccountInfoIndex[_gs1CodeId]].gs1CodeIndexes[_gs1CodeID];
      delete GS1CodeIndexToApproved[_gs1CodeId];
      return true;
    }
    return false;
  }

  function _changeGS1CodeOwnership(address _from, address _to, uint256 _gs1CodeId)
  internal
  {
    if (_to != address(0)) {
      //GS1Code Index의 소유자를 바꾼다.
      GS1CodeIndexToOwner[_gs1CodeId] = _to;
      gs1Codes[_gs1CodeId].owner = _to;

      //address 소유자(account)의 gs1 code 소유 갯수를 하나 증가 시킨다.
      ownershipGS1CodeCount[_to]++;

      //새로운 소유자에게 gs1code index를 저장.
      accountInfoList[addressToAccountInfoIndex[_to]].gs1CodeIndexes[_gs1CodeId] = true;

      if (_from != address(0)) {
        //이전 소유자의 gs1code index를 삭제함.
        ownershipGS1CodeCount[_from]--;
        delete accountInfoList[addressToAccountInfoIndex[_from]].gs1CodeIndexes[_gs1CodeId];
        delete GS1CodeIndexToApproved[_gs1CodeId];
      }
    }
  }

  function _addGS1Code(byte32 _gs1Code)
  internal
  onlyAllowedAccount
  returns(bool)
  {
    //GS1Code가 존재하면 안됨.
    require(!_isExistGS1Code(_gs1Code));
    //1. GS1Code 구조체를 생성하고 gs1Codes list에 추가한다. -> index를 받아온다.
    uint256 tokenId = gs1Codes.push(GS1Code({owner:msg.sender, gs1Code:_gs1Code, active:0}))- 1;
    _addGS1CodeToAccount(msg.sender, tokenId);
    return true;
  }
/*
    // ONS record properties
    //uint32 order;
    //uint32 pref;
    uint8 flags;
    bytes32 service;
    string regexp;
    //string replacement;
    //extended properties
    uint8 state; //0 : inactive, 1 : active
    int256 serviceTypeIndex;
*/
  function _addONSRecord(uint256 _gs1CodId, uint8 _flags, bytes32 _service, string _regexp)
  internal
  onlyAllowedAccount
  returns(bool)
  {
    //GS1Code가 존재해야 하고, GS1Code의 소유자가 msg.sender가 되어야 함.
    require(_owns(msg.sender, _gs1CodId))

    uint256 recordId = onsRecords.push(ONSRecord({flags:_flags,
                                                service:_service,
                                                regexp:_regexp,
                                                active:0,
                                                serviceTypeIndex:-1}))- 1;
    _addONSRecordToGS1Code(_gs1Code, recordId);
    return true;
  }

  /*
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
  */
  function _addServiceType(uint256 _onsRecordId, byte32 _serviceTypeIdentifer, bool _abstrct,
                          bytes32 _extends, string _WSDL, string _homepage)
  internal
  onlyAllowedAccount
  returns(bool)
  {
    //TO DO
    return true;
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////////////
  /*
    The functions below is the implementation of the ERC721 token.
  */
  string public name = "ObjectNameService";
  string public symbol = "ONS";

  // bool public implementsERC721 = true;
  function implementsERC721()
  public
  pure
  returns (bool)
  {
    return true;
  }

  function _approvedFor(address _claimant, uint256 _tokenId)
  internal
  view
  returns (bool)
  {
    return GS1CodeIndexToApproved[_tokenId] == _claimant
          || GS1CodeIndexToOwner[_tokenId] == _claimant;
  }

  function _approve(uint256 _tokenId, address _approved) internal {
    GS1CodeIndexToApproved[_tokenId] = _approved;
  }

  function balanceOf(address _owner) public view returns (uint256 count) {
    return ownershipGS1CodeCount[_owner];
  }

  function _transfer(address _from, address _to, uint256 _tokenId) internal {
    _changeGS1CodeOwnership(_from, _to, _tokenId);
    Transfer(_from, _to, _tokenId);
  }

  function transfer(
    address _to,
    uint256 _tokenId
  )
  public
  {
    require(_to != address(0));
    require(_owns(msg.sender, _tokenId));
    _transfer(msg.sender, _to, _tokenId);
  }

  function transferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
  public
  {
    require(_approvedFor(msg.sender, _tokenId));
    require(_owns(_from, _tokenId));
    _transfer(_from, _to, _tokenId);
  }

  function approve(
    address _to,
    uint256 _tokenId
  )
  public
  {
    require(_owns(msg.sender, _tokenId));
    _approve(_tokenId, _to);
    Approval(msg.sender, _to, _tokenId);
  }

  function ownerOf(uint256 _tokenId)
  public
  view
  returns (address owner)
  {
    owner = GS1CodeIndexToOwner[_tokenId];
    require(owner != address(0));
  }

  function totalSupply()
  public
  view
  returns (uint)
  {
    return gs1Codes.length - 1;
  }
}