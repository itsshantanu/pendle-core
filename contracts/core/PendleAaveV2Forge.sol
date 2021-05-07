// SPDX-License-Identifier: MIT
/*
 * MIT License
 * ===========
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 */
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

import "../interfaces/IAaveV2LendingPool.sol";
import "../interfaces/IPendleAaveForge.sol";
import "./abstract/PendleForgeBase.sol";
import "./PendleAaveV2YieldTokenHolder.sol";

/**
* @dev This contract will be very similar to AaveForge. Any major differences between the two
are likely to be bugs
*/
contract PendleAaveV2Forge is PendleForgeBase, IPendleAaveForge {
    using ExpiryUtils for string;
    using SafeMath for uint256;
    using Math for uint256;

    IAaveV2LendingPool public immutable aaveLendingPool;
    IAaveIncentivesController public immutable aaveIncentivesController;

    mapping(address => mapping(uint256 => uint256)) public lastNormalisedIncomeBeforeExpiry;
    mapping(address => mapping(uint256 => uint256)) public lastNormalisedIncomeForForgeFee;
    mapping(address => mapping(uint256 => mapping(address => uint256)))
        public lastNormalisedIncome; //lastNormalisedIncome[underlyingAsset][expiry][account]
    mapping(address => address) private reserveATokenAddress;

    constructor(
        address _governance,
        IPendleRouter _router,
        IAaveV2LendingPool _aaveLendingPool,
        bytes32 _forgeId,
        address _rewardToken,
        address _rewardManager,
        address _yieldContractDeployer,
        address _aaveIncentivesController
    )
        PendleForgeBase(
            _governance,
            _router,
            _forgeId,
            _rewardToken,
            _rewardManager,
            _yieldContractDeployer
        )
    {
        require(address(_aaveLendingPool) != address(0), "ZERO_ADDRESS");
        require(address(_aaveIncentivesController) != address(0), "ZERO_ADDRESS");

        aaveIncentivesController = IAaveIncentivesController(_aaveIncentivesController);
        aaveLendingPool = _aaveLendingPool;
    }

    /// Refer to PendleAaveForge
    function _calcTotalAfterExpiry(
        address _underlyingAsset,
        uint256 _expiry,
        uint256 redeemedAmount
    ) internal view override returns (uint256 totalAfterExpiry) {
        uint256 currentNormalizedIncome = getReserveNormalizedIncome(_underlyingAsset);
        totalAfterExpiry = currentNormalizedIncome.mul(redeemedAmount).div(
            lastNormalisedIncomeBeforeExpiry[_underlyingAsset][_expiry]
        );
    }

    /// Refer to PendleAaveForge
    function getReserveNormalizedIncomeBeforeExpiry(address _underlyingAsset, uint256 _expiry)
        internal
        returns (uint256)
    {
        if (block.timestamp > _expiry) {
            return lastNormalisedIncomeBeforeExpiry[_underlyingAsset][_expiry];
        }

        uint256 normalizedIncome = aaveLendingPool.getReserveNormalizedIncome(_underlyingAsset);

        lastNormalisedIncomeBeforeExpiry[_underlyingAsset][_expiry] = normalizedIncome;
        return normalizedIncome;
    }

    /// Refer to PendleAaveForge
    function getReserveNormalizedIncome(address _underlyingAsset)
        public
        view
        override
        returns (uint256)
    {
        return aaveLendingPool.getReserveNormalizedIncome(_underlyingAsset);
    }

    /// Refer to PendleAaveForge
    function _getYieldBearingToken(address _underlyingAsset) internal override returns (address) {
        if (reserveATokenAddress[_underlyingAsset] == address(0)) {
            reserveATokenAddress[_underlyingAsset] = aaveLendingPool
                .getReserveData(_underlyingAsset)
                .aTokenAddress;
            require(
                reserveATokenAddress[_underlyingAsset] != address(0),
                "INVALID_UNDERLYING_ASSET"
            );
        }
        return reserveATokenAddress[_underlyingAsset];
    }

    /// @inheritdoc PendleForgeBase
    // Copy pasted from PendleAaveForge
    function _updateDueInterests(
        uint256 _principal,
        address _underlyingAsset,
        uint256 _expiry,
        address _account
    ) internal override {
        uint256 lastIncome = lastNormalisedIncome[_underlyingAsset][_expiry][_account];
        uint256 normIncomeBeforeExpiry =
            getReserveNormalizedIncomeBeforeExpiry(_underlyingAsset, _expiry);
        // if the XYT hasn't expired, normIncomeNow = normIncomeBeforeExpiry
        // else, get the current income from Aave directly
        uint256 normIncomeNow =
            block.timestamp > _expiry
                ? getReserveNormalizedIncome(_underlyingAsset)
                : normIncomeBeforeExpiry;

        // first time getting XYT
        if (lastIncome == 0) {
            lastNormalisedIncome[_underlyingAsset][_expiry][_account] = normIncomeNow;
            return;
        }

        uint256 interestFromXyt;

        // if this if is true, means that there are still unclaimed interests from XYT
        if (normIncomeBeforeExpiry >= lastIncome) {
            interestFromXyt = _principal.mul(normIncomeBeforeExpiry).div(lastIncome).sub(
                _principal
            );

            // the interestFromXyt has only been calculated until normIncomeBeforeExpiry
            // we need to calculate the compound interest of it from normIncomeBeforeExpiry -> now
            interestFromXyt = interestFromXyt.mul(normIncomeNow).div(normIncomeBeforeExpiry);
        }

        // update the dueInterest (because it can generate compound interest on its own)
        // then add the newly received interestFromXyt
        dueInterests[_underlyingAsset][_expiry][_account] = dueInterests[_underlyingAsset][
            _expiry
        ][_account]
            .mul(normIncomeNow)
            .div(lastIncome)
            .add(interestFromXyt);

        lastNormalisedIncome[_underlyingAsset][_expiry][_account] = normIncomeNow;
    }

    /// @inheritdoc PendleForgeBase
    // Copy pasted from PendleAaveForge
    function _updateForgeFee(
        address _underlyingAsset,
        uint256 _expiry,
        uint256 _feeAmount
    ) internal override {
        uint256 normIncomeNow = getReserveNormalizedIncome(_underlyingAsset);
        // first time receiving fee
        if (lastNormalisedIncomeForForgeFee[_underlyingAsset][_expiry] == 0) {
            lastNormalisedIncomeForForgeFee[_underlyingAsset][_expiry] = normIncomeNow;
        }

        // update the totalFee (because it can generate compound interest on its own)
        // then add the newly received fee
        totalFee[_underlyingAsset][_expiry] = totalFee[_underlyingAsset][_expiry]
            .mul(normIncomeNow)
            .div(lastNormalisedIncomeForForgeFee[_underlyingAsset][_expiry])
            .add(_feeAmount);
        lastNormalisedIncomeForForgeFee[_underlyingAsset][_expiry] = normIncomeNow;
    }
}
