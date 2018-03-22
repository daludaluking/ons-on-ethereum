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
    //need more information?
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

  struct GS1Code {
    address owner;
    bytes32 gs1Code;
    uint256[] onsRecordIndex;
    bool active;
    mapping(string => string) extendedONSData;
  }

  GS1Code[] public gs1Codes;
  ONSRecord[] public onsRecords;
  ServiceType[] public serviceTypes;
  AccountInfo[] public accountInfoList;

  //GS1 code index와 GS1 code 소유자 주소와 매핑
  mapping (uint256 => address) public GS1CodeIndexToOwner;

  //address가 가지는 GS1Code count;
  mapping (address => uint256) public ownershipGS1CodeCount;

  //GS1Code index와 approved address와 mapping
  mapping (uint256 => address) public GS1CodeIndexToApproved;

  //gs1 code와 GS1Code 구조체와의 매핑
  mapping (byte32 => uint256) public GS1CodeToIndex;

  //for account
  //accountInfo[addressToAccountInfoIndex[address]]._address == address
  mapping (address => uint256) public addressToAccountInfoIndex;

  //addressToGS1CodeIndexes[address].push(gs1code index)
  mapping (byte32 => uint256) public GS1CodeToOwnerIndex;
  mapping (address => uint256[]) public addressToGS1CodeIndexes;


  //GS1CodeIndexToONSRecordIndexes[gs1code index].push(ons record index);
  mapping (uint256 => uint256[]) public GS1CodeIndexToONSRecordIndexes;

  string public name = "ObjectNameService";
  string public symbol = "ONS";

  // bool public implementsERC721 = true;
  function implementsERC721() public pure returns (bool)
  {
    return true;
  }

  function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
    return GS1CodeIndexToOwner[_tokenId] == _claimant;
  }

  function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {
    return GS1CodeIndexToApproved[_tokenId] == _claimant;
  }

  function _approve(uint256 _tokenId, address _approved) internal {
    GS1CodeIndexToApproved[_tokenId] = _approved;
  }

  function balanceOf(address _owner) public view returns (uint256 count) {
    return ownershipGS1CodeCount[_owner];
  }

  function _transfer(address _from, address _to, uint256 _tokenId) internal {

    ownershipGS1CodeCount[_to]++;
    GS1CodeIndexToOwner[_tokenId] = _to;

    if (_from != address(0)) {
      ownershipGS1CodeCount[_from]--;
      delete GS1CodeIndexToApproved[_tokenId];
    }

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

  function totalSupply() public view returns (uint) {
    return gs1Codes.length - 1;
  }

  function isExistGS1Code(byte32 _gs1Code)
  public
  returns(bool)
  {
    if (GS1CodeToIndex.length == 0) return false;
    return (gs1Codes[GS1CodeToIndex[_gs1Code]].gs1Code == _gs1Code);
  }

  function addGS1Code(byte32 _gs1Code)
  internal
  returns(bool)
  {
    require(!isExistGS1Code(_gs1Code));
    //1. GS1Code 구조체를 생성하고 gs1Codes list에 추가한다. -> index를 받아온다.
    uint256 tokenIndex = gs1Codes.push(GS1Code({owner:msg.sender, gs1Code:_gs1Code, active:1}))- 1;
    addressToGS1CodeIndexes[msg.sender].push(tokenIndex);
    ++ownershipGS1CodeCount[msg.sender];
    GS1CodeIndexToOwner[tokenIndex] = msg.sender;
    return true;
  }

  function isExistOwnerInfo(address _address)
  public
  returns(bool)
  {
    if (accountInfoList.length == 0) return false;
    return (accountInfoList[addressToAccountInfoIndex[_address]]._address == _address);
  }

  modifier onlyAllowedAccount() {
    require(isExistOwnerInfo(msg.sender));
    _;
  }
}