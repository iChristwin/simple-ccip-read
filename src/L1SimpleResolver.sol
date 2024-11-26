// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {GatewayFetcher, GatewayRequest} from "@unruggable/gateways@0.1.5/GatewayFetcher.sol";
import {GatewayFetchTarget} from "@unruggable/gateways@0.1.5/GatewayFetchTarget.sol";
import {IGatewayVerifier} from "@unruggable/gateways@0.1.5/IGatewayVerifier.sol";

contract L1SimpleResolver is GatewayFetchTarget {
    using GatewayFetcher for GatewayRequest;

    IGatewayVerifier immutable _verifier;
    address immutable _exampleAddress;

    constructor(IGatewayVerifier verifier, address exampleAddress) {
        _verifier = verifier;
        _exampleAddress = exampleAddress;
    }

    function supportsInterface(bytes4 x) external pure returns (bool) {
        return
            x == 0x01ffc9a7 /*https://eips.ethereum.org/EIPS/eip-165*/ ||
            x == 0x3b3b57de; /*https://docs.ens.domains/ensip/1*/
    }

    function addr(bytes32 node) public view returns (address) {
        GatewayRequest memory r = GatewayFetcher
            .newRequest(1)
            .setTarget(_exampleAddress)
            .setSlot(0)
            .read()
            .setOutput(0);

        fetch(_verifier, r, this.addrCallback.selector);
    }

    function addrCallback(
        bytes[] calldata values,
        uint8,
        bytes calldata extraData
    ) external pure returns (address) {
        return abi.decode(values[0], (address));
    }
}
