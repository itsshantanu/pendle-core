import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { PendleConstsType, TokensConstsType } from '@pendle/constants';
import { BigNumber as BN, Contract, Wallet } from 'ethers';
import { ContractMap } from '.';
import {
  IJoeRouter01,
  ProxyAdmin,
  PendleRedeemProxyMulti,
  PendleRouter,
  PendleWrapper,
  PendleZapEstimatorPAP,
  PendleZapEstimatorSingle,
  PendleRetroactiveDistribution,
  IJoeFactory,
  PendleMerkleDistributor,
  PendleRedeemProxyETHDep1,
  PendleData,
  PendleRedactedForge,
  IUniswapV2Router02,
  PendleIncentiveData,
  MultipleBalanceQuery,
} from '../../typechain-types';
import { ForgeMap } from './common-type';

export enum Network {
  ETH,
  AVAX,
  LOCAL_ETH,
  LOCAL_AVAX,
}

export interface PendleEnv {
  multipleBalanceQuery: MultipleBalanceQuery;
  sushiFactory: IJoeFactory;
  sushiRouter: IUniswapV2Router02;
  retroDist: PendleRetroactiveDistribution;
  merkleDistributor: PendleMerkleDistributor;
  incentiveData: PendleIncentiveData;
  joeSimpleRewardManager: Contract;
  joeSimpleYieldContractDeployer: Contract;
  pendleTraderJoeSimpleForge: Contract;
  redeemProxyAvax: PendleRedeemProxyMulti;
  redeemProxyEth: PendleRedeemProxyETHDep1;
  wonderlandRewardManager: Contract;
  redactedRewardManager: Contract;
  wonderlandYieldContractDeployer: Contract;
  redactedYieldContractDeployer: Contract;
  pendleWonderlandForge: Contract;
  pendleRedactedForge: PendleRedactedForge;
  xJoeRewardManager: Contract;
  xJoeYieldContractDeployer: Contract;
  pendleXJoeForge: Contract;
  joeComplexRewardManager: Contract;
  joeComplexYieldContractDeployer: Contract;
  pendleTraderJoeComplexForge: Contract;
  benQiRewardManager: Contract;
  benQiYieldContractDeployer: Contract;
  pendleBenQiForge: Contract;
  compoundV2RewardManager: Contract;
  compoundV2YieldContractDeployer: Contract;
  sushiComplexRewardManager: Contract;
  sushiComplexYieldContractDeployer: Contract;
  pendleSushiswapComplexForge: Contract;
  pendleCompoundV2Forge: Contract;
  pendleGenericMarketFactory: Contract;
  pendleOnePause: Contract;
  sushiSimpleRewardManager: Contract;
  sushiSimpleYieldContractDeployer: Contract;
  pendleSushiswapSimpleForge: Contract;
  a2RewardManager: Contract;
  a2YieldContractDeployer: Contract;
  pendleAaveV2Forge: Contract;
  pendleAaveMarketFactory: Contract;
  compoundRewardManager: Contract;
  compoundYieldContractDeployer: Contract;
  pendleCompoundForge: Contract;
  pendleCompoundMarketFactory: Contract;
  pendleWhitelist: Contract;
  pendleZapEstimatorPAP: PendleZapEstimatorPAP;
  pendleZapEstimatorSingle: PendleZapEstimatorSingle;
  pendleMarketReader: Contract;
  governanceManagerLiqMining: Contract;
  pausingManagerMain: Contract;
  pausingManagerLiqMining: Contract;
  pausingManagerLiqMiningV2: Contract;
  governanceManagerMain: Contract;

  pendleWrapper: PendleWrapper;
  pendleWrapperImplementation: PendleWrapper;
  proxyAdmin: ProxyAdmin;

  joeFactory: IJoeFactory;
  joeRouter: IJoeRouter01;
  contractMap: ContractMap;

  forgeMap: ForgeMap;
  network: Network;
  consts: PendleConstsType;
  tokens: TokensConstsType;
  deployer: SignerWithAddress | Wallet;

  pendleRouter: PendleRouter;
  pendleData: PendleData;
  PENDLE: Contract;

  flat: FlatEnv;
}

export interface FlatEnv {
  FORGE_BENQI: string;
  FORGEID_TRADERJOESIMPLE: string;
  FORGE_TRADERJOESIMPLE: string;

  TOKEN_JLP_WAVAX_PENDLE: string;
  TOKEN_OT_QIUSDC_28_DEC_2023: string;
  TOKEN_YT_QIUSDC_28_DEC_2023: string;
  TOKEN_OT_QIAVAX_28_DEC_2023: string;
  TOKEN_YT_QIAVAX_28_DEC_2023: string;
  TOKEN_OT_JLP_WAVAX_PENDLE_28_DEC_2023: string;
  TOKEN_YT_JLP_WAVAX_PENDLE_28_DEC_2023: string;
  TOKEN_OT_XJOE_30_JUN_2022: string;
  TOKEN_YT_XJOE_30_JUN_2022: string;
  TOKEN_OT_WMEMO_24_FEB_2022: string;
  TOKEN_YT_WMEMO_24_FEB_2022: string;
  TIME_28_DEC_2023: BN;
  TIME_30_JUN_2022: BN;
  TIME_24_FEB_2022: BN;
  POOL_YT_QIUSDC_28_DEC_2023_X_USDC: string;
  POOL_YT_QIAVAX_28_DEC_2023_X_USDC: string;
  POOL_YT_JLP_WAVAX_PENDLE_28_DEC_2023_X_PENDLE: string;
  POOL_YT_XJOE_30_JUN_2022_X_USDC: string;
  POOL_YT_WMEMO_24_FEB_2022_X_MIM: string;
  LIQ_YT_QIUSDC_X_USDC: string;
  LIQ_YT_QIAVAX_X_USDC: string;
  LIQ_YT_JLP_WAVAX_PENDLE_X_PENDLE: string;
  LIQ_YT_XJOE_X_USDC: string;
  LIQ_YT_WMEMO_X_MIM: string;
  POOL_OT_QIUSDC_28_DEC_2023_X_USDC: string;
  POOL_OT_QIAVAX_28_DEC_2023_X_USDC: string;
  POOL_OT_JLP_WAVAX_PENDLE_28_DEC_2023_X_PENDLE: string;
  POOL_OT_XJOE_30_JUN_2022_X_USDC: string;
  POOL_OT_WMEMO_24_FEB_2022_X_MIM: string;
  LIQ_OT_QIUSDC_28_DEC_2023_X_USDC: string;
  LIQ_OT_QIAVAX_28_DEC_2023_X_USDC: string;
  LIQ_OT_JLP_WAVAX_PENDLE_28_DEC_2023_X_PENDLE: string;
  LIQ_OT_XJOE_30_JUN_2022_X_USDC: string;
  LIQ_OT_WMEMO_24_FEB_2022_X_MIM: string;
}
