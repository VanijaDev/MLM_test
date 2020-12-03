// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MLM_Token is ERC20 {
    address public mlmContractAddr;

    constructor(address _mlmContractAddr, uint8 _tokensToMint)
        public
        ERC20("MLM_Token", "MLMT")
    {
        require(_mlmContractAddr != address(0), "_mlmContractAddr is 0");
        require(isContract(_mlmContractAddr), "not Smart Contract");
        require(_tokensToMint > 0, "wrong _tokensToMint");

        mlmContractAddr = _mlmContractAddr;
        super._mint(
            msg.sender,
            uint256(_tokensToMint) * 10**uint256(decimals())
        );
    }
    
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        require(recipient != mlmContractAddr, "please use MLM Contract");
        
        return super.transfer(recipient, amount);
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
