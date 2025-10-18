// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract MiniEtherBank {
    // State variable to store the contract owner's address
    address public owner;
    
    // Mapping to track each user's balance in the bank
    mapping(address => uint) public balances;
    
    // Event emitted when a user deposits Ether
    event Deposited(address indexed user, uint amount);
    
    // Event emitted when a transfer occurs between users
    event Transferred(address indexed from, address indexed to, uint amount);
    
    // Event emitted when a user withdraws Ether
    event Withdraw(address indexed user, uint amount);
    
    // Modifier to restrict access to only the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    // Constructor sets the contract deployer as the owner
    constructor() {
        owner = msg.sender;
    }
    
    /**
     * @dev Allows users to deposit Ether into their bank account
     * @notice This function is payable, meaning it can receive Ether
     * The deposited amount is added to the user's balance
     */
    function deposit() public payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        
        // Add the sent Ether to the user's balance
        balances[msg.sender] += msg.value;
        
        // Emit event to log the deposit (FIXED: use msg.sender instead of address(this))
        emit Deposited(msg.sender, msg.value);
    }
    
    /**
     * @dev Transfer funds between users
     * @param _to Recipient address
     * @param _amount Amount to transfer
     * @notice Transfers balance from sender to recipient
     */
    function transferInternal(address _to, uint _amount) public {
        require(_to != address(0), "Cannot transfer to zero address");
        require(_amount > 0, "Transfer amount must be greater than 0");
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        require(_to != msg.sender, "Cannot transfer to yourself");
        
        // Deduct from sender's balance
        balances[msg.sender] -= _amount;
        
        // Add to recipient's balance
        balances[_to] += _amount;
        
        // Emit transfer event
        emit Transferred(msg.sender, _to, _amount);
    }
    
    /**
     * @dev Allows users to withdraw Ether from the contract
     * @param _to Recipient address (payable to receive Ether)
     * @param _amount Amount to withdraw
     * @notice Checks user balance and contract balance before withdrawal
     */
    function withdraw(address payable _to, uint _amount) public {
        require(_to != address(0), "Cannot withdraw to zero address");
        require(_amount > 0, "Withdrawal amount must be greater than 0");
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        require(address(this).balance >= _amount, "Contract has insufficient Ether");
        
        // Deduct from user's balance BEFORE sending Ether (checks-effects-interactions pattern)
        balances[msg.sender] -= _amount;
        
        // Attempt to send Ether to the specified address
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Ether transfer failed");
        
        // Emit event to log the withdrawal (FIXED: use msg.sender instead of _to for consistency)
        emit Withdraw(msg.sender, _amount);
    }
    
    /**
     * @dev Returns the caller's balance in the bank
     * @return uint The balance of the message sender
     */
    function getMyBalance() public view returns(uint) {
        return balances[msg.sender];
    }
    
    /**
     * @dev Get the total balance of the contract
     * @return uint The total Ether balance of the contract
     */
    function getContractBalance() public view returns(uint) {
        return address(this).balance;
    }
    

    
    

}