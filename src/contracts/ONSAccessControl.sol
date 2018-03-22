pragma solidity ^0.4.18;

/// @title The ONSAccessControl that manages access privileges to transaction.
/// @author dalu
contract ONSAccessControl {

  /*
    manager : has a role that registers a user on the whitelist that is a list of user's addresses who can trade.
    validator : has a role that allow t=
  */
  address public managerAddress;
  address public validatorAddress;

  function ONSAccessControl() public {
    // constructor
    managerAddress = msg.sender;
    validatorAddress = msg.sender;
  }

  modifier onlyManager() {
    require(msg.sender == managerAddress);
    _;
  }

  modifier onlyValidator() {
    require(msg.sender == validatorAddress);
    _;
  }

  modifier onlyRoot() {
    require(
      msg.sender == managerAddress ||
      msg.sender == validatorAddress
    );
    _;
  }

  function setManager(address _newManager) public onlyManager {
    require(_newManager != address(0));

    managerAddress = _newManager;
  }

  function setValidator(address _newValidator) public onlyRoot {
    require(_newValidator != address(0));

    validatorAddress = _newValidator;
  }

  function getManager() public view returns(address) {
    return managerAddress;
  }

  function getValidator() public view returns(address) {
    return validatorAddress;
  }
}
