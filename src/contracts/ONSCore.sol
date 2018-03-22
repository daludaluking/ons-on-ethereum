pragma solidity ^0.4.18;
import "./ONSBase.sol";

contract ONSCore is ONSBase{

  function registerAccount(
      address _accountAddress,
      bytes32 _name,
      string _url,
      string _email
  )
      public
      onlyManager
      returns(bool)
  {
    require(!isExistOwnerInfo(_accountAddress));
    addressToAccountInfoIndex[_accountAddress] = accountInfoList.push(AccountInfo(_accountAddress, _name, _url, _email)) - 1;
    return true;
  }

  function registerGS1Code(bytes32 _gs1Code) public onlyAllowedAccount returns(bool) {
    require(!isExistGS1Code(_gs1Code));
    
  }
}
