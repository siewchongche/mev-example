pragma solidity ^0.8.10;

interface LendingPool {
    event Borrow(address indexed reserve, address user, address indexed onBehalfOf, uint256 amount, uint256 borrowRateMode, uint256 borrowRate, uint16 indexed referral);
    event Deposit(address indexed reserve, address user, address indexed onBehalfOf, uint256 amount, uint16 indexed referral);
    event FlashLoan(address indexed target, address indexed initiator, address indexed asset, uint256 amount, uint256 premium, uint16 referralCode);
    event LiquidationCall(address indexed collateralAsset, address indexed debtAsset, address indexed user, uint256 debtToCover, uint256 liquidatedCollateralAmount, address liquidator, bool receiveAToken);
    event Paused();
    event RebalanceStableBorrowRate(address indexed reserve, address indexed user);
    event Repay(address indexed reserve, address indexed user, address indexed repayer, uint256 amount);
    event ReserveDataUpdated(address indexed reserve, uint256 liquidityRate, uint256 stableBorrowRate, uint256 variableBorrowRate, uint256 liquidityIndex, uint256 variableBorrowIndex);
    event ReserveUsedAsCollateralDisabled(address indexed reserve, address indexed user);
    event ReserveUsedAsCollateralEnabled(address indexed reserve, address indexed user);
    event Swap(address indexed reserve, address indexed user, uint256 rateMode);
    event Unpaused();
    event Withdraw(address indexed reserve, address indexed user, address indexed to, uint256 amount);

    struct ReserveConfigurationMap { uint256 a; }
    struct UserConfigurationMap { uint256 a; }

    function FLASHLOAN_PREMIUM_TOTAL() view external returns (uint256);
    function LENDINGPOOL_REVISION() view external returns (uint256);
    function MAX_NUMBER_RESERVES() view external returns (uint256);
    function MAX_STABLE_RATE_BORROW_SIZE_PERCENT() view external returns (uint256);
    function borrow(address asset, uint256 amount, uint256 interestRateMode, uint16 referralCode, address onBehalfOf) external;
    function deposit(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external;
    function finalizeTransfer(address asset, address from, address to, uint256 amount, uint256 balanceFromBefore, uint256 balanceToBefore) external;
    function flashLoan(address receiverAddress, address[] memory assets, uint256[] memory amounts, uint256[] memory modes, address onBehalfOf, bytes memory params, uint16 referralCode) external;
    function getAddressesProvider() view external returns (address);
    function getConfiguration(address asset) view external returns (ReserveConfigurationMap memory);
    function getReserveNormalizedIncome(address asset) view external returns (uint256);
    function getReserveNormalizedVariableDebt(address asset) view external returns (uint256);
    function getReservesList() view external returns (address[] memory);
    function getUserAccountData(address user) view external returns (uint256 totalCollateralETH, uint256 totalDebtETH, uint256 availableBorrowsETH, uint256 currentLiquidationThreshold, uint256 ltv, uint256 healthFactor);
    function getUserConfiguration(address user) view external returns (UserConfigurationMap memory);
    function initReserve(address asset, address aTokenAddress, address stableDebtAddress, address variableDebtAddress, address interestRateStrategyAddress) external;
    function initialize(address provider) external;
    function liquidationCall(address collateralAsset, address debtAsset, address user, uint256 debtToCover, bool receiveAToken) external;
    function paused() view external returns (bool);
    function rebalanceStableBorrowRate(address asset, address user) external;
    function repay(address asset, uint256 amount, uint256 rateMode, address onBehalfOf) external returns (uint256);
    function setConfiguration(address asset, uint256 configuration) external;
    function setPause(bool val) external;
    function setReserveInterestRateStrategyAddress(address asset, address rateStrategyAddress) external;
    function setUserUseReserveAsCollateral(address asset, bool useAsCollateral) external;
    function swapBorrowRateMode(address asset, uint256 rateMode) external;
    function withdraw(address asset, uint256 amount, address to) external returns (uint256);
}
