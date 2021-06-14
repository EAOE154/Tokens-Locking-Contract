pragma solidity ^0.8.5;

interface lockContractInterface{
    
    function lockStats(address user, uint256 lockID) external view returns(uint256 lockedAmount, uint256 lockingPeriod, uint256 lockedAt);
    
    function locksCount(address user) external view returns(uint256);
    
    function lock(uint256 amount, uint256 time) external returns(bool);
    
    function unlock(uint256 lockID) external returns(bool);
}

contract lockContract is lockContractInterface{
    
    ERC20 token;
    
    mapping (address => uint256) private _locks;
    
    mapping (address => mapping(uint256 => uint256)) private _lockedAmount;
    mapping (address => mapping(uint256 => uint256)) private _lockingPeriod;
    mapping (address => mapping(uint256 => uint256)) private _lockedAt;
    
    
    constructor(address ERC20Token){
        token = ERC20(ERC20Token);
    }
    function lockStats(address user, uint256 lockID) external view override returns(uint256 lockedAmount, uint256 lockingPeriod, uint256 lockedAt){
        lockedAmount = _lockedAmount[user][lockID];
        lockingPeriod = _lockingPeriod[user][lockID];
        lockedAt = _lockedAt[user][lockID];
    }
    
    function locksCount(address user) external view override returns(uint256){
        return _locks[user];
    }
    function lock(uint256 amount, uint256 time) external override returns(bool){
        token.transferFrom(msg.sender, address(this), amount);
        
        uint256 _lock = _locks[msg.sender];
        
        _lockedAmount[msg.sender][_lock] = amount;
        _lockingPeriod[msg.sender][_lock] = time;
        _lockedAt[msg.sender][_lock] = block.number;
        
        ++_locks[msg.sender];
        
        return true;
    }
    
    function unlock(uint256 lockID) external override returns(bool){
        require(block.number >= (_lockedAt[msg.sender][lockID] + _lockingPeriod[msg.sender][lockID]));
        
        token.transfer(msg.sender, _lockedAmount[msg.sender][lockID]);
        
        _lockedAmount[msg.sender][lockID] = 0;
        
        return true;
    }
    
}
