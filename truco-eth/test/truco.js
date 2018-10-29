var Truco = artifacts.require("./Truco.sol");

contract("Truco", function (accounts) {
    var trucoInstance;

    it("Começar a partida", function () {
        return Truco.deployed().then(function (instance) {
            trucoInstance = instance;

            return trucoInstance.entrarPartida({from: accounts[0]});
        }).then(function (address) {
            return trucoInstance.entrarPartida({from: accounts[1]});
        }).then(function (address) {
            return trucoInstance.receberCartas(accounts[0], {from: accounts[0]});
        }).then(function (cartas) {
            assert.equal(cartas.length, 3, "Número de cartas jogador 1");
            return trucoInstance.receberCartas(accounts[0], {from: accounts[1]});
        }).then(function (cartas) {
            assert.equal(cartas.length, 3, "Número de cartas jogador 2");
        });
    });

    it("Comparar cartas", function () {
       return Truco.deployed().then(function (instance) {
           trucoInstance = instance;
           return trucoInstance.compararCartas(1, 1);
       }).catch(function (error) {
           assert(error.message.indexOf('revert') >= 0, "error message must contain revert");
           return trucoInstance.compararCartas(1, 2);
       }).then(function (value) {
           assert.equal(value, 2, "As x 2 - Segundo ganhou");
           return trucoInstance.compararCartas(6, 5);
       }).then(function (value) {
           // console.log("oi - " + value);
           assert.equal(value, 1, "6 x 5 - Primeiro ganhou");
           return trucoInstance.compararCartas(6, 2);
       }).then(function (value) {
           assert.equal(value, 2, "6 x 2 - Segundo ganhou");
           return trucoInstance.compararCartas(7, 2);
       }).then(function (value) {
           assert.equal(value, 1, "7o x 2 - Primeiro ganhou");
           return trucoInstance.compararCartas(6, 16);
       }).then(function (value) {
           assert.equal(value, 0, "6o x 6e - Empate - 50");
           return trucoInstance.compararCartas(7, 27);
       }).then(function (value) {
           assert.equal(value, 2, "7o x 7c - Segundo ganhou");
           return trucoInstance.compararCartas(27, 7);
       }).then(function (value) {
           assert.equal(value, 1, "7c x 7o - Primeiro ganhou");
           return trucoInstance.compararCartas(34, 7);
       }).then(function (value) {
           assert.equal(value, 1, "4p x 7o - Primeiro ganhou");
           return trucoInstance.compararCartas(34, 27);
       }).then(function (value) {
           assert.equal(value, 1, "4p x 7o - Primeiro ganhou");
           return trucoInstance.compararCartas(27, 34);
       }).then(function (value) {
           assert.equal(value, 2, "7o x 7c - Segundo ganhou");
       });
    });
});
