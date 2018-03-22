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
    string realAddress;
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
    mapping(string => string) extendedONSData;
  }

  GS1Code[] public gs1Codes;
  ONSRecord[] public onsRecords;
  ServiceType[] public serviceTypes;
  AccountInfo[] public accountInfo;

  //ownerInfos is whitelist..

  //gs1 code index mapping to owner
  mapping (uint256 => address) public GS1CodeIndexToOwner;
  mapping (address => uint256) public ownershipGS1CodeCount;
  mapping (uint256 => address) public GS1CodeIndexToApproved;

  //for account
  //accountInfo[addressToAccountInfoIndex[address]]._address == address
  mapping (address => uint256) public addressToAccountInfoIndex;
  //addressToGS1CodeIndexes[address].push(gs1code index)
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

  function isExistOwnerInfo(address _address)
  public
  view
  returns(bool)
  {
    if (accountInfo.length == 0) return false;
    return (accountInfo[addressToAccountInfoIndex[_address]]._address == _address);
  }

  modifier isAllowedUser() {
    require(isExistOwnerInfo(msg.sender));
    _;
  }
}