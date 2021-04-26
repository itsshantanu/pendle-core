import {
  Deployment,
  validAddress,
  deploy,
  getContractFromDeployment,
} from "../helpers/deployHelpers";

export async function step9(
  deployer: any,
  hre: any,
  deployment: Deployment,
  consts: any
) {
  const governanceMultisig = deployment.variables.GOVERNANCE_MULTISIG;
  const pendleRouterAddress = deployment.contracts.PendleRouter.address;

  if (!validAddress("GOVERNANCE_MULTISIG", governanceMultisig)) process.exit(1);
  if (!validAddress("PendleRouter address", pendleRouterAddress))
    process.exit(1);

  console.log(`\tPendleRouter address used = ${pendleRouterAddress}`);
  console.log(`\tGOVERNANCE_MULTISIG used = ${governanceMultisig}`);
  console.log(
    `\tAAVE_V2_LENDING_POOL_ADDRESS used = ${consts.misc.AAVE_V2_LENDING_POOL_ADDRESS}`
  );
  console.log(`\tForge Id used = ${consts.misc.FORGE_AAVE_V2}`);

  const pendleAaveV2Forge = await deploy(hre, deployment, "PendleAaveV2Forge", [
    governanceMultisig,
    pendleRouterAddress,
    consts.misc.AAVE_V2_LENDING_POOL_ADDRESS,
    consts.misc.FORGE_AAVE_V2,
  ]);

  const pendleRouter = await getContractFromDeployment(
    hre,
    deployment,
    "PendleRouter"
  );
  await pendleRouter.addForge(
    consts.misc.FORGE_AAVE_V2,
    pendleAaveV2Forge.address
  );

  const pendleData = await getContractFromDeployment(
    hre,
    deployment,
    "PendleData"
  );

  if (!["kovan", "mainnet"].includes(hre.network.name)) {
    await pendleData.setForgeFactoryValidity(
      consts.misc.FORGE_AAVE_V2,
      consts.misc.MARKET_FACTORY_AAVE,
      true
    );
  } else {
    console.log(
      "[NOTICE - TODO] We will need to use the governance multisig to setForgeFactoryValidity for AaveV2"
    );
    const txDetails = await pendleData.populateTransaction.setForgeFactoryValidity(
      consts.misc.FORGE_AAVE_V2,
      consts.misc.MARKET_FACTORY_AAVE,
      true
    );
    console.log(
      `[NOTICE - TODO] Transaction details: \n${JSON.stringify(
        txDetails,
        null,
        "  "
      )}`
    );
  }
}