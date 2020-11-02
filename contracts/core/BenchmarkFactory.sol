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
pragma solidity ^0.7.0;

import "./BenchmarkForge.sol";
import "./BenchmarkMarket.sol";
import "../interfaces/IBenchmark.sol";
import "../interfaces/IBenchmarkData.sol";
import "../interfaces/IBenchmarkFactory.sol";
import "../interfaces/IBenchmarkProvider.sol";
import "../interfaces/IBenchmarkYieldToken.sol";
import "../periphery/Permissions.sol";


contract BenchmarkFactory is IBenchmarkFactory, Permissions {
    IBenchmark public override core;
    IForgeCreator public forgeCreator;
    IMarketCreator public marketCreator;
    address[] private allForges;
    address[] private allMarkets;
    address private initializer;

    constructor(address _governance) Permissions(_governance) {
        initializer = msg.sender;
    }

    function initialize(
        IBenchmark _core,
        IForgeCreator _forgeCreator,
        IMarketCreator _marketCreator
    ) external {
        require(msg.sender == initializer, "Benchmark: forbidden");
        require(address(_core) != address(0), "Benchmark: zero address");
        require(address(_forgeCreator) != address(0), "Benchmark: zero address");
        require(address(_marketCreator) != address(0), "Benchmark: zero address");

        initializer = address(0);
        core = _core;
        forgeCreator = _forgeCreator;
        marketCreator = _marketCreator;
    }

    function createForge(address _underlyingAsset, address _underlyingYieldToken)
        external
        override
        returns (address forge)
    {
        require(initializer == address(0), "Benchmark: not initialized");
        require(_underlyingAsset != address(0), "Benchmark: zero address");
        require(_underlyingYieldToken != address(0), "Benchmark: zero address");

        IBenchmarkData data = core.data();
        IBenchmarkProvider provider = core.provider();

        require(
            data.getForge(_underlyingAsset, _underlyingYieldToken) == address(0),
            "Benchmark: forge exists"
        );
        require(
            provider.getATokenAddress(_underlyingYieldToken) != address(0),
            "Benchmark: underlying not found"
        );

        forge = IForgeCreator(forgeCreator).create(_underlyingAsset, _underlyingYieldToken);
        data.addForge(_underlyingAsset, _underlyingYieldToken, forge);
        allForges.push(forge);

        emit ForgeCreated(_underlyingAsset, _underlyingYieldToken, forge);
    }

    function createMarket(
        address _xyt,
        address _token,
        uint256 _expiry
    ) external override returns (address market) {
        require(initializer == address(0), "Benchmark: not initialized");
        require(_xyt != _token, "Benchmark: similar tokens");
        require(_xyt != address(0) && _token != address(0), "Benchmark: zero address");

        IBenchmarkData data = core.data();
        IBenchmarkYieldToken xyt = IBenchmarkYieldToken(_xyt);

        require(data.getMarket(_xyt, _token) == address(0), "Benchmark: market already exists");
        require(
            data.getForge(xyt.underlyingAsset(), xyt.underlyingYieldToken()) == xyt.forge(),
            "Benchmark: not xyt token"
        );

        market = IMarketCreator(marketCreator).create(_xyt, _token, _expiry);
        data.addMarket(_xyt, _token, market);
        allMarkets.push(market);

        emit MarketCreated(_xyt, _token, market);
    }

    function setCore(IBenchmark _core) public override {
        require(address(_core) != address(0), "Benchmark: zero address");

        core = _core;
        emit CoreSet(address(_core));
    }

    function allForgesLength() external view override returns (uint256) {
        return allForges.length;
    }

    function getAllForges() public view override returns (address[] memory) {
        return allForges;
    }

    function allMarketsLength() external view override returns (uint256) {
        return allMarkets.length;
    }

    function getAllMarkets() public view override returns (address[] memory) {
        return allMarkets;
    }
}