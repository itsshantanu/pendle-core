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

import "./abstract/PendleYieldTokenHolderBase.sol";
import "../interfaces/IAaveIncentivesController.sol";
import "hardhat/console.sol";

contract PendleAaveV2YieldTokenHolder is PendleYieldTokenHolderBase {
    IAaveIncentivesController private aaveIncentivesController;
    address rewardToken; //TODO: remove this. This is only for debugging

    constructor(
        address _router,
        address _yieldToken,
        address _rewardToken,
        address _rewardManager,
        address _aaveIncentivesController
    ) PendleYieldTokenHolderBase(_router, _yieldToken, _rewardToken, _rewardManager) {
        require(_aaveIncentivesController != address(0), "ZERO_ADDRESS");
        aaveIncentivesController = IAaveIncentivesController(_aaveIncentivesController);
        rewardToken = _rewardToken; //TODO: remove
    }

    function claimRewards() external override {
        address[] memory assets = new address[](1);
        assets[0] = yieldToken;
        console.log(
            "yieldToken = %s, balance = %s",
            yieldToken,
            IERC20(yieldToken).balanceOf(address(this))
        );

        aaveIncentivesController.claimRewards(assets, uint256(-1), address(this));
        console.log(
            "After claiming stkAave rewards: rewardToken = %s, balance = %s",
            rewardToken,
            IERC20(rewardToken).balanceOf(address(this))
        );
    }
}
