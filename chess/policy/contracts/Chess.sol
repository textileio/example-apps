//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@tableland/eth/contracts/ITablelandController.sol";
import "./GameToken.sol";


interface IGameToken {
    function getPlayerGames(address player) external view returns (uint256[] memory);
}

contract Chess is ITablelandController {
    IGameToken private gameToken;

    constructor(address _gameTokenAddr) {
        gameToken = IGameToken(_gameTokenAddr);
    }

    function getPolicy(address caller)
        public
        payable
        override
        returns(ITablelandController.Policy memory)
    {
        uint256[] memory playerGames = gameToken.getPlayerGames(caller);

        string memory wc;
        string[] memory uc;

        return ITablelandController.Policy({
            allowInsert: true,
            allowUpdate: false,
            allowDelete: false,
            whereClause: string.concat(
                "player_address = 0x",
                _addressToString(caller),
                " AND game_id IN (",
                _gamesToString(playerGames),
                ")"
            ),
            withCheck: wc,
            updatableColumns: uc
        });
    }

    function _addressToString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);
        }
        return string(s);
    }

    function _gamesToString(uint256[] memory games) internal pure returns (string memory) {
        string memory gamesString = "";
        for (uint i = 0; i < games.length; i++) {
            if (i + 1 < games.length) {
                gamesString = string.concat(gamesString, "'", Strings.toString(games[i]), "', ");
            } else {
                gamesString = string.concat(gamesString, "'", Strings.toString(games[i]), "'");
            }
        }

        return gamesString;
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

}
