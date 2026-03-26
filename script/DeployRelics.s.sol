// SPDX-License-Identifier: MIT
pragma solidity 0.8.34;

import {Script, console} from "forge-std/Script.sol";
import {Relics} from "../src/Relics.sol";

/// @title DeployRelics
/// @author SockLove (socklove.eth)
/// @notice Deployment script for Relics contract
/// @dev Bytecode for Safe's CreateCall: forge inspect Relics bytecode
contract DeployRelics is Script {
    function run() public returns (Relics) {
        vm.startBroadcast();
        Relics relics = new Relics();
        vm.stopBroadcast();

        console.log("Relics contract has been deployed to:", address(relics));

        return relics;
    }
}
