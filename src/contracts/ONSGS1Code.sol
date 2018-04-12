pragma solidity ^0.4.18;
import "./ONSManager.sol";

/*
  array에서 item을 삭제하는 경우 index가 변경되기 때문에
  array에서 삭제할 수가 없다.
  이 문제를 어떻게 해결할 것인지 고민할 필요가 있다.
    -> array 형태의 data를 모두 mapping array로 변경해 보자.
*/
contract ONSGS1Code is ONSManager{

  enum GS1CodeState {NONE, INACTIVE, ACTIVE}

  struct GS1Code {
    address owner;
    bytes32 gs1Code;
    GS1CodeState state; //0: not belong to anyone, 1 : inactive state, 2: active state
    uint256 index; //always from 1, for gs1CodeIterList
  }

  //ONS Smart Contract에 저장된 모든 gs1 codes
  //GS1Code 구조체의 배열
  mapping(bytes32=>GS1Code) gs1CodeList;
  //in advance, for iteration.
  bytes32[] gs1CodeIterList;

  //Owner가 가진 gs1 code의 정보
  struct GS1CodesOfOwner {
    address owner;
    //owner가 소유한 gs1 codes
    bytes32[] gs1CodeList;
  }

  //ONSAccessControl에 owners mapping array에 존재하는
  //owner들의 GS1CodesOfOwner data list
  mapping(address=>GS1CodesOfOwner) gs1CodeListOfOwner;

  struct Provider {
    uint allowedProviderListPointer; // needed to delete a "allowedProvider"
    address[] providers;
    mapping(address => uint) providersPointer; // 4294967295 pointer is reserved as existence check
  }

  //owner allow user to add ons records for gs1 code.
  //mapping(bytes32 => address[]) public allowedProviderMapForGS1Code;
  //address[] allowedProviders;

  function ONSGS1Code() {
  }

  modifier onlyOwner(bytes32 gs1Code) {
    require(gs1CodeList[gs1Code].owner == msg.sender);
    _;
  }

  function isExistGS1Code(bytes32 gs1Code) public view returns(bool) {
    //gs1CodeList에 owner가 정상적인지 확인.
    if (gs1CodeList[gs1Code].index > 0)
      return true;
    return false;
  }

  function isOwner(bytes32 gs1Code) public view returns(bool) {
    if (gs1CodeList[gs1Code].owner != msg.sender)
      return false;
    return true;
  }

  //owner에게 GS1CodesOfOwner 가 생성되어 있는지 검사함.
  function isExistGS1CodesOfOwner(address ownerAddress) internal view returns(bool) {
    //ownerGS1CodeListIndex에서 gs1CodeListOfOwner의 찾고,
    //gs1CodeListOfOwner의 owner가 동일한지 확인.
    if (gs1CodeListOfOwner[ownerAddress].owner != ownerAddress)
      return true;
    return false;
  }

  //gs1 code의 상태 변경.
  function changeGS1CodeState(bytes32 gs1Code, GS1CodeState state)
  public
  onlyRoot
  returns(bool)
  {
    require(gs1CodeList[gs1Code].index > 0);
    if (msg.sender == gs1CodeList[gs1Code].owner
    || isManager(msg.sender) == true) {
      gs1CodeList[gs1Code].state = state;
      return true;
    }
    return false;
  }

  //gs1 code의 상태를 얻어옴.
  function getGS1CodeState(bytes32 gs1Code)
  public
  view
  returns(GS1CodeState)
  {
    require(gs1CodeList[gs1Code].index > 0);
    return gs1CodeList[gs1Code].state;
  }

  //gs1 code의 상태를 얻어옴.
  function getGS1CodeOwner(bytes32 gs1Code)
  public
  onlyRoot
  view
  returns(address)
  {
    require(gs1CodeList[gs1Code].index > 0);
    return gs1CodeList[gs1Code].owner;
  }

  //gs1 code의 owner 변경
  function changeOwnerOfGS1Code(bytes32 gs1Code, address newAddress)
  public
  onlyRoot
  returns(bool)
  {
    require(gs1CodeList[gs1Code].index > 0);
    if (msg.sender == gs1CodeList[gs1Code].owner
      || isManager(msg.sender) == true) {
      gs1CodeList[gs1Code].owner = newAddress;
      return true;
    }
    return false;
  }

  //owner에게 gs1 code를 할당한다.
  //권한은 mananger에게 줘야 할 것인가??
  function addGS1Code(bytes32 gs1Code, address ownerAddr)
  public
  onlyManager()
  returns(bool)
  {
    //owner가 존재하지 않으면 등록 불가.
    //owner만이 gs1code만을 등록할 수 있음.
    if (isExistOwner(ownerAddr) == false)
      return false;

    //gs1 code가 이미 등록되어 있으면 등록불가
    if (isExistGS1Code(gs1Code) == true)
      return false;

    //GS1Code 를 생성하고 gs1CodeList에 추가함.
    //추가할 때 index를 얻어서 저장해 놓음, 나중에 참조할 때는 -1을 빼야한다.
    uint256 iterIdx = gs1CodeIterList.push(gs1Code);
    gs1CodeList[gs1Code] = GS1Code(ownerAddr, gs1Code, GS1CodeState.INACTIVE, iterIdx);

    //GS1CodesOfOwner 변수를 선언/
    //-> owner의 GS1CodesOfOwner가 없으면 생성할 필요가 있기 때문
    //GS1CodesOfOwner gs1CodesOfOwner;

    //owner의 GS1CodesOfOwner가 이미 만들어져 있는지 확인
    if (isExistGS1CodesOfOwner(ownerAddr) == false) {
      //없다면 새롭게 생성하여 등록함.
      gs1CodeListOfOwner[ownerAddr] = GS1CodesOfOwner({owner:ownerAddr, gs1CodeList:new bytes32[](0)});
    }

    //owner의 GS1CodesOfOwner에 gs1 code를 저장함.
    //소유권이 생긴 것임..
    gs1CodeListOfOwner[ownerAddr].gs1CodeList.push(gs1Code);
    //allowedProviderMapForGS1Code[gs1Code].push(msg.sender);
    return true;
  }

  //owner에게 할당된 gs1 code를 삭제.
  //권한은 mananger에게만? 줘야 할 것인가?
  function removeGS1Code(bytes32 gs1Code, address ownerAddr)
  public
  onlyManager()
  returns(bool)
  {
    require(isExistOwner(ownerAddr) == true);

    //gs1 code가 이미 등록되어 있지 않으면 삭제불가
    if (isExistGS1Code(gs1Code) == false)
      return false;

    if (gs1CodeList[gs1Code].owner != ownerAddr
      || gs1CodeList[gs1Code].gs1Code != gs1Code)
      return false;

    /*
      array의 item을 삭제할 경우에 실제 array가 줄어드는지 확인이 필요하다.(length 포함)
    */
    for (uint i = 0; i < gs1CodeListOfOwner[ownerAddr].gs1CodeList.length; i++) {
      if (gs1CodeListOfOwner[ownerAddr].gs1CodeList[i] == gs1Code) {
        delete gs1CodeListOfOwner[ownerAddr].gs1CodeList[i];
        break;
      }
    }

    if (gs1CodeIterList.length > 0 && gs1CodeIterList[gs1CodeList[gs1Code].index-1] == gs1Code)
      delete gs1CodeIterList[gs1CodeList[gs1Code].index-1];

    delete gs1CodeList[gs1Code];
    return true;
  }
}
