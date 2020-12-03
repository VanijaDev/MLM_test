// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

import "./MLM_Token.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract MLM_Contract is Ownable {
    using SafeMath for uint256;
    
    MLM_Token token;

    uint8[3] private levelPercents;
    uint8 constant maxPayedLevel = 2;
    uint8 constant maxChildren = 7;
    mapping(address => address[maxChildren]) private parentsForChild;
    mapping(address => address[maxChildren]) private childrenForParent;
    mapping(address => bool) public admins;
    mapping(address => uint256) public fee;

    modifier onlyNotZeroAddress(address _addr) {
        require(_addr != address(0), "address == 0");
        _;
    }
    
    modifier onlyAdmin() {
        require(admins[msg.sender], "not admin");
        _;
    }

    event LevelPercentsUpdated(uint8[3] _levelPercents);

    constructor(uint8[3] memory _levelPercents) public {
        updateLevelPercents(_levelPercents);
    }

    function updateMLMToken(address _tokenAddr)
        external
        onlyOwner
        onlyNotZeroAddress(_tokenAddr)
    {
        require(isContract(_tokenAddr), "not Smart Contract");

        token = MLM_Token(_tokenAddr);
    }

    function getLevellevelPercents()
        public
        view
        returns (uint8[3] memory _levelPercents)
    {
        _levelPercents = levelPercents;
    }

    /**
      * @notice Same comments for each func should be added.
      * @dev Gets percentage for level.
      * @param _level Level to get percentage for.
      * @return _percent Percentage for level.
    */
    function percentageForLevel(uint8 _level)
        public
        view
        returns (uint8 _percent)
    {
        require(_level <= maxPayedLevel, "wrong level");

        _percent = levelPercents[_level];
    }

    function updateLevelPercents(uint8[3] memory _levelPercents)
        public
        onlyOwner
    {
        levelPercents = _levelPercents;
        emit LevelPercentsUpdated(_levelPercents);
    }

    /**
      * @notice May be issues with manual changes.
    */
    function updateParentForChildInLevel(
        address _child,
        address _parent,
        uint8 _level
    ) external onlyAdmin {
        require(_child != address(0), "_child == 0");
        require(_parent != address(0), "_parent == 0");
        require(_level < maxChildren, "wrong level");

        parentsForChild[_child][_level] = _parent;
    }
    
    function updateAdmin(address _address, bool _isAdmin) external onlyOwner onlyNotZeroAddress(_address) {
        admins[_address] = _isAdmin;
    }

    function invite(address _childInvited)
        external
        onlyNotZeroAddress(_childInvited)
    {
        require(msg.sender != _childInvited, "same address");
        require(parentsForChild[_childInvited][0] == address(0), "already invited");
        require(childrenForParent[msg.sender][maxChildren-1] == address(0), "no more children");
        
        parentsForChild[_childInvited][0] = msg.sender;
        
        address[maxChildren] storage childrenSender = childrenForParent[msg.sender];
        for (uint8 i = 0; i < maxChildren; i ++) {
            if (childrenSender[i] == address(0)) {
                childrenSender[i] = _childInvited;
                break;
            }
        }
        
        address[maxChildren] storage parents = parentsForChild[msg.sender];
        for (uint8 i = 0; i < maxChildren-1; i ++) {
            address parent = parents[i];
            if (parent == address(0)) {
                return;
            }
            
            parentsForChild[_childInvited][i+1] = parent;
            
            address[maxChildren] storage children = childrenForParent[parent];
            if (children[maxChildren-1] == address(0)) {
                for (uint8 j = 0; j < maxChildren; j ++) {
                    if (children[j] == address(0)) {
                        children[j] = _childInvited;
                        break;
                    }
                }
            }
        }
    }
    
    function getChildrenForParent(address _parent) external view onlyNotZeroAddress(_parent) returns (address[7] memory) {
        return childrenForParent[_parent];
    }
    
    function getParentsForChild(address _child) external view onlyNotZeroAddress(_child) returns (address[7] memory) {
        return parentsForChild[_child];
    }

    /**
      * @notice User must approve before usage of this method.
    */
    function doSmtUseful(uint256 _tokens) external {
        require(_tokens > 100, "min 100 tokens");
        
        for (uint8 i = 0; i < maxPayedLevel; i ++) {
            address parent = parentsForChild[msg.sender][i];
            uint256 feeAmount = _tokens.mul(levelPercents[i]).div(100);
            fee[parent] = fee[parent].add(feeAmount);
        }
        
        token.transferFrom(msg.sender, address(this), _tokens);
    }
    
    function claimFee() external {
        uint256 feeTmp = fee[msg.sender];
        require(feeTmp > 0, "no fee");
        
        delete fee[msg.sender];
        token.transfer(msg.sender, feeTmp);
    }

    //  HELPERS

    function isContract(address _addr) private view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }
}
