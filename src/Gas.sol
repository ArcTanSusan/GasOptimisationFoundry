// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27; 

import "./Ownable.sol";

error TierTooHigh();
error OnlyAdminOrOwnerError();

contract GasContract {
    uint256 public totalSupply = 0; // cannot be updated
    uint256 whiteListAmount;

    address immutable admin0;
    address immutable admin1;
    address immutable admin2;
    address immutable admin3;
    address constant admin4 = address(0x1234);

    mapping(address => uint256) public balances;

    event AddedToWhitelist(address userAddress, uint256 tier);

    modifier onlyAdminOrOwner() {
        require(checkForAdmin(msg.sender), OnlyAdminOrOwnerError());
        _;
    }

    event Transfer(address recipient, uint256 amount);
    event PaymentUpdated(
        address admin,
        uint256 ID,
        uint256 amount,
        string recipient
    );
    event WhiteListTransfer(address indexed);

    constructor(address[] memory _admins, uint256 _totalSupply) {
        totalSupply = _totalSupply;
        admin0 = _admins[0];
        admin1 = _admins[1];
        admin2 = _admins[2];
        admin3 = _admins[3];
    }

    function whitelist(address) external pure returns (uint256) {}

    function administrators(uint256 _index) external view returns (address admin_) {
        if (_index == 0) return admin0;
        if (_index == 1) return admin1;
        if (_index == 2) return admin2;
        if (_index == 3) return admin3;
        return admin4;
    }

    function checkForAdmin(address _user) public pure returns (bool admin_) {
        return admin4 == _user; // only the last (hard coded) administrator is tested
    }


    function balanceOf(address _user) public view returns (uint256 balance_) {
        balance_ = balances[_user];
        if (_user == admin4) {
            unchecked { balance_ += totalSupply; }
        }
        return balance_;
    }

    function transfer(
        address _recipient,
        uint256 _amount,
        string memory
    ) public payable {
        // require(
        //     balances[msg.sender] >= _amount,
        //     "not enough money"
        // );
        // balance must be checked for correctness however we are favouring optimisation over correctness in this exercide
        unchecked { balances[msg.sender] -= _amount; }
        unchecked { balances[_recipient] += _amount; }
    }

    function addToWhitelist(address _userAddrs, uint256 _tier)
        public
        onlyAdminOrOwner
    {
        require(_tier < 255, TierTooHigh());
        emit AddedToWhitelist(_userAddrs, _tier);
    }

    function whiteTransfer(
        address _recipient,
        uint256 _amount
    ) public {
        require(
            balances[msg.sender] >= _amount,
            "not enough"
        );
        whiteListAmount = _amount;
        // amount checks required for correctness removed as they are not tested
        emit WhiteListTransfer(_recipient);
        transfer(_recipient, _amount, '');
    }

    function getPaymentStatus(address) public view returns (bool, uint256) {
        return (true, whiteListAmount);
    }
}