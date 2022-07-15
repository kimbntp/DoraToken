// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DoraToken is ERC20 {
    constructor() ERC20("DoraToken", "DRT") {
        _mint(msg.sender, 1000000 * 10**decimals());
    }

    address public owner;
    uint BankBalance;

    struct details {
        string accName;
        address creator;
        uint balance;
        bool isAcc;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier isAccOwner(string memory accName) {
        require(
            msg.sender == accountsMapping[accName].creator,
            "You're not the owner of this account!"
        );
        _;
    }

    // mapping of accounts
    mapping(string => details) public accountsMapping;

    function createNewAccount(string memory _accName) public {
        // Only create an account when the name is Unique
        if (!accountsMapping[_accName].isAcc) {
            accountsMapping[_accName] = details(_accName, msg.sender, 0, true);
        }
    }

    function deposit(string memory _accName, uint _amount) public payable {
        transfer(address(this), _amount);
        accountsMapping[_accName].balance += _amount;
        BankBalance += _amount;
    }

    //     function withdraw(string memory _accName, uint _amount) public payable isAccOwner(_accName) {
    // if (accountsMapping[_accName].balance >= _amount) {
    //     approve(address(this), BankBalance);
    // }
    // transferFrom(address(this), msg.sender, _amount);
    // (bool callSuccess, ) = payable(msg.sender).call{value: _wdAmount}("");
    // require(callSuccess, "Call failed");
    // }

    function transfer(
        string memory _accNameFrom,
        string memory _accNameTo,
        uint _amount
    ) public payable isAccOwner(_accNameFrom) {
        require(accountsMapping[_accNameFrom].balance >= _amount);
        if (
            accountsMapping[_accNameFrom].creator ==
            accountsMapping[_accNameTo].creator
        ) {
            accountsMapping[_accNameFrom].balance -= _amount;
            accountsMapping[_accNameTo].balance += _amount;
        } else {
            //     transferFrom(accountsMapping[_accNameFrom].creator, accountsMapping[_accNameTo].creator, _amount);
        }
    }
}

contract manager {
    address public DoraTokenAddress;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function setDoraTokenAddress(address _myTokenAddress) public onlyOwner {
        DoraTokenAddress = _myTokenAddress;
    }

    function withdraw(string memory _accName, uint _amount)
        public
        payable
        isAccOwner(_accName)
    {
        (bool success, ) = DoraTokenAddress.call(
            abi.encodeWithSignature(
                "withdraw(address,uint256)",
                accountsMapping[_accName].creator,
                _amount
            )
        );
        accountsMapping[_accName].balance -= _amount;
    }
}
