// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// @title MultisigWallet - Allows multiple parties to agree on transactions before execution.

contract MultiSigWallet {

    event OwnerAddition(address indexed owner);
    event OwnerRemoval(address indexed owner);
    event RequirementChange(uint indexed requireed);
    event Submission(uint indexed transactionId);
    event Confirmation(uint indexed transactionId, address indexed owner);
    event Revocation(uint indexed transactionId, address indexed owner);
    event Execution(uint indexed transactoinId);
    event ExecutionFailure(uint indexed transactoinId);
    event Deposit(address indexed sender, uint value);
    
    address[] owners;
    uint required;
    uint transactionCount;

    mapping(uint => Transaction) public transactions;
    mapping(uint => mapping(address => bool)) public confirmations;
    mapping(address => bool) public isOwner;
    
    struct Transaction {
        address to;
        uint amount;
        bytes data;
        bool executed;
        }

    modifier onlyWallet() {
        require(msg.sender == address(this), "Not the Wallet");
        _;
      }

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not an owner");
        _;
      }

    modifier notNull(address _address) {
        require(_address != address(0), "Invaild Addrss");
        _;
      }

    modifier OwnerDoesExist(address owner) {
        require(isOwner[owner], "Ownre does exist");
        _;
      }

    modifier OwnerDoesNotExist(address owner) {
        require(!isOwner[owner], "Owner does not exist");
        _;
      }

    modifier transactionIdDoesExist(uint transactionId) {
        require(transactions[transactionId].to != address(0), "TransactionId does exist");
        _;
      }

    modifier notConfrimed(uint transactionId) {
        require(!confirmations[transactionId][msg.sender], "transaction not confrimed");
        _;
      }

    modifier confrimed(uint transactionId) {
        require(!confirmations[transactionId][msg.sender], "tranaction confrimed");
        _;
      }

    modifier notExecuted(uint transactionId) {
        require(!transactions[transactionId].executed,"");
        _;
      }
      /**
       * @dev Sets the values for {owners} and {required}
       * @param _owners List of initial owners.
       * @param _required Number of required confirmations. 
       */
      constructor(address[] memory _owners, uint _required) {
            require(_owners.length > 0, "Owners required");
            require(_required > 0 && _owners.length >= _required, "Invaild number of required!");
            for(uint i = 0; i < _owners.length; i++) {
                  require(_owners[i] != address(0), "Invaild Address");
                  require(!isOwner[_owners[i]], "Duplicate owner");
                  isOwner[_owners[i]] = true;
                  owners.push(_owners[i]);
                  }
            required = _required;
      }

      /**
       * @dev Allows to add a new Owner. Transaction has to be sent by wallet.
       * @param newOwner Address of new owner.
       */
      function addOwner(address newOwner)
            public
            onlyWallet
            OwnerDoesNotExist(newOwner)
            notNull(newOwner) 
            {
                  isOwner[newOwner] = true;
                  owners.push(newOwner);
                  emit OwnerAddition(newOwner);
                  }
      
      /**
       * @dev Allows to remove an owner. Transaction has to be sent by wallet. 
       * @param owner Address of owner
       */
      function removeOwner(address owner)
            public
            onlyWallet
            OwnerDoesExist(owner)
            notNull(owner)
            {
                  isOwner[owner] = false;
                  uint index;
                  for(uint i = 0; i < owners.length; i++) {
                  if(owners[i] == owner) {
                        index = i;
                        break;
                        }
                  }
                  for(uint j = index; j < owners.length; j++) {
                        owners[j+1] = owners[j];
                        }
                  owners.pop();
                  emit OwnerRemoval(owner);
            }
      
      /**
       * @dev Allowsto replace an owner with a new owner. Transaction has to be sent by wallet.
       * @param oldOwner Address of owner to be replaced. 
       * @param newOwner Address of new owner.
       */
      function changeOwner(address oldOwner, address newOwner)
            public
            onlyWallet
            OwnerDoesExist(oldOwner)
            OwnerDoesNotExist(newOwner)
            notNull(newOwner)
            {
                  isOwner[oldOwner] = false;
                  isOwner[newOwner] = true;
                  for(uint i = 0; i < owners.length; i++) {
                  if(oldOwner == owners[i]) {
                        owners[i] = newOwner;
                        break;
                        }
                  }
                  emit OwnerAddition(newOwner);
                  emit OwnerRemoval(oldOwner);
            }
      /**
       * @dev Allow to change the number of required confirmations. Transaction has to be sent by wallet.
       * @param _required Number of required confirmations.
       */
      function changeRequirement(uint _required) public {
            require(_required > 0);
            required = _required;
            emit RequirementChange(_required);
      }
      
      /**
       * @dev Allows an owner to submit and confirm a transaction.
       * @param to destination Transaction target address.
       * @param amount Transaction ether value.
       * @param data Transaction data payload.
       * @return transactionId Returns transaction ID. 
       */
      function submitTransaction(address to, uint amount, bytes memory data)
            public
            onlyOwner
            notNull(to)
            returns(uint transactionId)
            {
                  transactionId = transactionCount;
                  transactions[transactionId] = Transaction(to, amount, data, false);
                  transactionCount++;
                  emit Submission(transactionId);
            }
      
      /**
       * @dev Allows an owner to confirm a transaction.
       * @param transactionId Transaction ID.
       */
      function confirmTransaction(uint transactionId)
            public
            transactionIdDoesExist(transactionId)
            notConfrimed(transactionId)
            onlyOwner
            {
                  confirmations[transactionId][msg.sender] = true;
                  emit Confirmation(transactionId, msg.sender); 
            }
      
      /**
       * @dev Allows an owner to revoke a confirmation for a transaction.
       * @param transactionId Transaction ID. 
       */
      function revokeConfirmation(uint transactionId)
            public
            transactionIdDoesExist(transactionId)
            confrimed(transactionId)
            onlyOwner
            {
                  confirmations[transactionId][msg.sender] = false;
                  emit Revocation(transactionId, msg.sender);
            }
      /**
       * @dev Returns the confirmation status of a transaction.
       * @param transactionId Transaction ID.
       * @return Transaction status.
       */
      function isConfirmed(uint transactionId)
            public
            view 
            transactionIdDoesExist(transactionId)
            returns(bool)
            {
                  return getConfirmationCount(transactionId) >= required;
            }

      /**
       * @dev Allows anyone to execute a confirmed transaction.
       * @param transactionId Transaction Id.
       */
      function executeTransaction(uint transactionId)
            public
            onlyOwner
            transactionIdDoesExist(transactionId)
            notExecuted(transactionId)
            {
                  require(isConfirmed(transactionId));
                  Transaction storage _tx = transactions[transactionId];
                  (bool success, ) = _tx.to.call{ value: _tx.amount }(_tx.data);
                  if (success) {
                        _tx.executed = true;
                        emit Execution(transactionId);
                        }
                  emit ExecutionFailure(transactionId);
            }

      function getOwner() public view  returns(address[] memory) {
            return owners;
            }

      function getRequired() public view returns(uint) {
            return required;
            }

      function getTransactionCount() public view returns(uint) {
            return transactionCount;
            }

      function getTransaction(uint transactionId)
        public
        view
        transactionIdDoesExist(transactionId)
        returns(address, uint, bytes memory, bool) 
        {
            Transaction storage _tx = transactions[transactionId];
            return (
                _tx.to,
                _tx.amount,
                _tx.data,
                _tx.executed
                );
            }


    function getConfirmationCount(uint transactionId)
        public
        view
        transactionIdDoesExist(transactionId)
        returns(uint total)
        {
            for(uint i = 0; i < owners.length; i++) {
                if (confirmations[transactionId][owners[i]]) {
                    total++;
                    }
                }
                return total;
            }

    receive() payable external{}
}
