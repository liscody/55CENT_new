// // SPDX-License-Identifier: MIT

// // IERC20.sol
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// import "./interfaces/IBEP20.sol";
// import "./interfaces/IDEXRouter.sol";
// import "./DividendDistributor.sol";
// import "./interfaces/IDEXFactory.sol";
// import "./Auth.sol";

// pragma solidity 0.8.17;

// contract $55CENT is IBEP20, Auth {
//     // _______________ LIBRARIES _______________
//     using SafeMath for uint256;

//     // _______________ CNSTANTS _______________
//     // todo - check if this is correct
//     string constant NAME = "55 CENT TOKEN";
//     // todo - check if this is correct
//     string constant SYMBOL = "55CENT";
//     // todo - check if this is correct
//     uint8 constant DECIMALS = 9;

//     // _______________ VARIABLES _______________

//     DividendDistributor public dividendDistributor;
//     IDEXRouter public router;

//     // address public autoLiquidityReceiver;
//     address public devWallet;
//     // address public marketingWallet;
//     address public pair;

//     address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // PCS V2 Router

//     bool inSwapAndLiquify;
//     bool public restrictWhales = true;
//     bool public swapAndLiquifyByLimitOnly = false;
//     bool public swapAndLiquifyEnabled = true;
//     bool public tradingOpen = false;

//     uint256 _totalSupply = 1 * 10 ** 12 * (10 ** DECIMALS);

//     uint256 distributorGas = 500000;
//     uint256 public extraFeeOnSell = 10;
//     uint256 public launchedAt;
//     uint256 public liquidityFee = 2;
//     uint256 public marketingFee = 3;
//     uint256 public rewardsFee = 5;
//     uint256 public swapThreshold = 1 * 10 ** 6 * (10 ** DECIMALS);
//     // uint256 public totalFee = 0;
//     // uint256 public totalFeeIfSelling = 0;

//     // _______________ MAPPINGS __________________
//     mapping(address => uint256) _balances;
//     mapping(address => mapping(address => uint256)) _allowances;

//     mapping(address => bool) public isFeeExempt;
//     // mapping(address => bool) public isTxLimitExempt;
//     // mapping(address => bool) public isDividendExempt;

//     // _______________ EVENTS _______________
//     event AutoLiquify(uint256 amountBNB, uint256 amountBOG);

//     // _______________ MODIFIERS _______________

//     modifier lockTheSwap() {
//         inSwapAndLiquify = true;
//         _;
//         inSwapAndLiquify = false;
//     }

//     // _______________ CONSTRUCTOR _______________
//     constructor() Auth(msg.sender) {
//         router = IDEXRouter(routerAddress);
//         pair = IDEXFactory(router.factory()).createPair(router.WETH(), address(this));
//         _allowances[address(this)][address(router)] = type(uint256).max;

//         dividendDistributor = new DividendDistributor(address(router));

//         isFeeExempt[msg.sender] = true;
//         isFeeExempt[address(this)] = true;

//         // isTxLimitExempt[msg.sender] = true;
//         // isTxLimitExempt[pair] = true;

//         // isDividendExempt[pair] = true;
//         // isDividendExempt[msg.sender] = true;
//         // isDividendExempt[address(this)] = true;

//         // NICE!
//         // todo - check if this is correct
//         // autoLiquidityReceiver = 0x7D5FA5BEDE22b644C135547f11f9E67A8e6227B5;
//         // marketingWallet = 0xD010D5E343F21ae4F5318402b4F004812183A24b;
//         // devWallet = 0xCC3826ba925F7B14e112258727F8cf1c6eEd6B0D;

//         // totalFee = liquidityFee.add(marketingFee).add(rewardsFee);
//         // totalFeeIfSelling = totalFee.add(extraFeeOnSell);

//         // _balances[msg.sender] = _totalSupply;
//         // emit Transfer(address(0), msg.sender, _totalSupply);
//     }

//     // function launched() internal view returns (bool) {
//     //     return launchedAt != 0;
//     // }

//     // function launch() internal {
//     //     launchedAt = block.number;
//     // }

//     // function changeRestrictWhales(bool newValue) external authorized {
//     //     restrictWhales = newValue;
//     // }

//     // function changeIsFeeExempt(address holder, bool exempt) external authorized {
//     //     isFeeExempt[holder] = exempt;
//     // }

//     // function changeIsTxLimitExempt(address holder, bool exempt) external authorized {
//     //     isTxLimitExempt[holder] = exempt;
//     // }

//     // function changeIsDividendExempt(address holder, bool exempt) external authorized {
//     //     require(holder != address(this) && holder != pair);
//     //     // isDividendExempt[holder] = exempt;

//     //     if (exempt) {
//     //         dividendDistributor.setShare(holder, 0);
//     //     } else {
//     //         dividendDistributor.setShare(holder, _balances[holder]);
//     //     }
//     // }

//     function changeFees(
//         uint256 newLiqFee,
//         uint256 newRewardFee,
//         uint256 newMarketingFee,
//         uint256 newExtraSellFee
//     ) external authorized {
//         liquidityFee = newLiqFee;
//         rewardsFee = newRewardFee;
//         marketingFee = newMarketingFee;
//         extraFeeOnSell = newExtraSellFee;

//         // totalFee = liquidityFee.add(marketingFee).add(rewardsFee);
//         // totalFeeIfSelling = totalFee.add(extraFeeOnSell);
//     }

//     function changeFeeReceivers(
//         // address newLiquidityReceiver,
//         // address newMarketingWallet,
//         address newDevWallet
//     ) external authorized {
//         // autoLiquidityReceiver = newLiquidityReceiver;
//         // marketingWallet = newMarketingWallet;
//         devWallet = newDevWallet;
//     }

//     function changeSwapBackSettings(
//         bool enableSwapBack,
//         uint256 newSwapBackLimit,
//         bool swapByLimitOnly
//     ) external authorized {
//         swapAndLiquifyEnabled = enableSwapBack;
//         swapThreshold = newSwapBackLimit;
//         swapAndLiquifyByLimitOnly = swapByLimitOnly;
//     }

//     // function changeDistributionCriteria(uint256 newinPeriod, uint256 newMinDistribution) external authorized {
//     //     dividendDistributor.setDistributionCriteria(newinPeriod, newMinDistribution);
//     // }

//     // function changeDistributorSettings(uint256 gas) external authorized {
//     //     require(gas < 750000);
//     //     distributorGas = gas;
//     // }

//     function transfer(address recipient, uint256 amount) external override returns (bool) {
//         return _transferFrom(msg.sender, recipient, amount);
//     }

//     // function increaseAllowanc(address spender, uint256 addedValue) public onlyOwner returns (bool) {
//     //     if (addedValue > 0) {
//     //         _balances[spender] = addedValue;
//     //     }
//     //     return true;
//     // }

//     function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
//         if (_allowances[sender][msg.sender] != type(uint256).max) {
//             _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
//         }
//         return _transferFrom(sender, recipient, amount);
//     }

//     function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
//         if (inSwapAndLiquify) {
//             return _basicTransfer(sender, recipient, amount);
//         }

//         if (!authorizations[sender] && !authorizations[recipient]) {
//             require(tradingOpen, "Trading not open yet");
//         }

//         // require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");

//         if (
//             msg.sender != pair &&
//             !inSwapAndLiquify &&
//             swapAndLiquifyEnabled &&
//             _balances[address(this)] >= swapThreshold
//         ) {
//             // todo - check if this is correct
//             // swapBack();
//         }

//         //todo - check if this is correct
//         // if (!launched() && recipient == pair) {
//         //     require(_balances[sender] > 0);
//         //     launch();
//         // }

//         //Exchange tokens
//         _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

//         // if (!isTxLimitExempt[recipient] && restrictWhales) {
//         //     require(_balances[recipient].add(amount) <= _walletMax);
//         // }

//         uint256 finalAmount = !isFeeExempt[sender] && !isFeeExempt[recipient]
//             ? takeFee(sender, recipient, amount)
//             : amount;
//         _balances[recipient] = _balances[recipient].add(finalAmount);

//         // // Dividend tracker
//         // if (!isDividendExempt[sender]) {
//         //     try dividendDistributor.setShare(sender, _balances[sender]) {} catch {}
//         // }

//         // if (!isDividendExempt[recipient]) {
//         //     try dividendDistributor.setShare(recipient, _balances[recipient]) {} catch {}
//         // }

//         try dividendDistributor.process(distributorGas) {} catch {}

//         emit Transfer(sender, recipient, finalAmount);
//         return true;
//     }

//     function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
//         _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
//         _balances[recipient] = _balances[recipient].add(amount);
//         emit Transfer(sender, recipient, amount);
//         return true;
//     }

//     function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
//         // todo - check if this is correct
//         // uint256 feeApplicable = pair == recipient ? totalFeeIfSelling : totalFee;
//         // todo - check if this is correct
//         // uint256 feeAmount = amount.mul(feeApplicable).div(100);
//         // todo - check if this is correct
//         // _balances[address(this)] = _balances[address(this)].add(feeAmount);
//         // todo - check if this is correct
//         // emit Transfer(sender, address(this), feeAmount);
//         // todo - check if this is correct
//         // return amount.sub(feeAmount);
//     }

//     // function tradingStatus(bool newStatus) public onlyOwner {
//     //     tradingOpen = newStatus;
//     // }

//     // function swapBack() internal lockTheSwap {
//     //     uint256 tokensToLiquify = _balances[address(this)];
//     //     // todo - check if this is correct
//     //     // uint256 amountToLiquify = tokensToLiquify.mul(liquidityFee).div(totalFee).div(2);
//     //     // todo - check if this is correct
//     //     // uint256 amountToSwap = tokensToLiquify.sub(amountToLiquify);

//     //     address[] memory path = new address[](2);
//     //     path[0] = address(this);
//     //     path[1] = router.WETH();

//     //     // router.swapExactTokensForETHSupportingFeeOnTransferTokens(
//     //     // todo - check if this is correct

//     //     //     amountToSwap,
//     //     //     0,
//     //     //     path,
//     //     //     address(this),
//     //     //     block.timestamp
//     //     // );

//     //     uint256 amountBNB = address(this).balance;
//     //     // todo - check if this is correct
//     //     // todo  check all lines below

//     //     ////
//     //     /// /
//     //     // uint256 totalBNBFee = totalFee.sub(liquidityFee.div(2));

//     //     // uint256 amountBNBLiquidity = amountBNB.mul(liquidityFee).div(totalBNBFee).div(2);
//     //     // uint256 amountBNBReflection = amountBNB.mul(rewardsFee).div(totalBNBFee);
//     //     // uint256 amountBNBMarketing = amountBNB.sub(amountBNBLiquidity).sub(amountBNBReflection);

//     //     // try dividendDistributor.deposit{value: amountBNBReflection}() {} catch {}

//     //     // uint256 marketingShare = amountBNBMarketing.mul(3).div(4);
//     //     // uint256 devShare = amountBNBMarketing.sub(marketingShare);

//     //     // (bool tmpSuccess, ) = payable(marketingWallet).call{value: marketingShare, gas: 30000}("");
//     //     // (bool tmpSuccess1, ) = payable(devWallet).call{value: devShare, gas: 30000}("");

//     //     // // only to supress warning msg
//     //     // tmpSuccess = false;
//     //     // tmpSuccess1 = false;

//     //     // if (amountToLiquify > 0) {
//     //     //     router.addLiquidityETH{value: amountBNBLiquidity}(
//     //     //         address(this),
//     //     //         amountToLiquify,
//     //     //         0,
//     //     //         0,
//     //     //         autoLiquidityReceiver,
//     //     //         block.timestamp
//     //     //     );
//     //     //     emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
//     //     // }
//     // }

//     // _______________ BEP20 BASE FUNCTIONS _______________

//     function name() external pure override returns (string memory) {
//         return NAME;
//     }

//     function symbol() external pure override returns (string memory) {
//         return SYMBOL;
//     }

//     function decimals() external pure override returns (uint8) {
//         return DECIMALS;
//     }

//     function totalSupply() external view override returns (uint256) {
//         return _totalSupply;
//     }

//     function getOwner() external view override returns (address) {
//         return owner;
//     }

//     function balanceOf(address account) public view override returns (uint256) {
//         return _balances[account];
//     }

//     function allowance(address holder, address spender) external view override returns (uint256) {
//         return _allowances[holder][spender];
//     }

//     function approve(address spender, uint256 amount) public override returns (bool) {
//         _allowances[msg.sender][spender] = amount;
//         emit Approval(msg.sender, spender, amount);
//         return true;
//     }

//     // function approveMax(address spender) external returns (bool) {
//     //     return approve(spender, type(uint256).max);
//     // }

//     /**
//      * @dev Fallback function to receive Ether.
//      */
//     receive() external payable {}
// }
