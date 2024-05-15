// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IUniswapV2Router02.sol";

contract MyToken is ERC20, Ownable {
    uint256 _maxSupply = 1000000 * 10 ** decimals(); // 1 M
    // router
    IUniswapV2Router02 public router;
    address public pair;

    uint256 fee;
    address public feeReceiver;
    address routerAddress;

    constructor(uint256 fee_, address feeReceiver_, address routerAddress_) ERC20("MyToken", "MTK") Ownable() {
        fee = fee_;
        feeReceiver = feeReceiver_;
        routerAddress = routerAddress_;

        router = IUniswapV2Router02(routerAddress);
        pair = IUniswapV2Router02(router.factory()).createPair(router.WETH(), address(this));

        _mint(msg.sender, _maxSupply);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        if (recipient == address(router) || msg.sender == address(router)) {
            uint256 feeAmount = (amount * fee) / 10000;
            super.transferFrom(sender, feeReceiver, feeAmount);
            super.transferFrom(sender, recipient, amount - feeAmount);
        } else {
            super.transferFrom(sender, recipient, amount);
        }
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function setFeeReceiver(address feeReceiver_) public onlyOwner {
        feeReceiver = feeReceiver_;
    }

    function setFee(uint256 fee_) public onlyOwner {
        fee = fee_;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
