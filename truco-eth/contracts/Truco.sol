pragma solidity ^0.4.24;

contract Truco {
    struct Partida {
        address[2] jogadores;
        uint8 rodada;
        uint8 valorRodada;
        uint8[6] cartas;
        uint8[6] jogadas;
        uint8[2] pontos;
        uint8 turno;
        bool terminou;
    }

    mapping(address => Partida) partidas;
    Partida[] partidasNaoIniciadas;
    uint partidasNaoIniciadasInicio;
    uint  partidasNaoIniciadasFim;

    constructor() public {
        partidasNaoIniciadasInicio = partidasNaoIniciadasFim = 0;
    }

    function random() private view returns (uint8) {
        return uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % 251);
    }

    function criarPartida() public {
        require(partidas[msg.sender].rodada == 0, "O jogador não pode ser o criador de mais de uma partida");

        Partida memory partida = Partida(
            [msg.sender, address(0)],
            1,
            1,
            [1, 2, 3, 4, 5, 6], //[random(), random(), random(), random(), random(), random()],
            [0, 0, 0, 0, 0, 0],
            [0, 0],
            1,
            false);
        if (partidasNaoIniciadasInicio == 0) {
            partidasNaoIniciadasFim++;
            partidasNaoIniciadas.push(partida);
        } else {
            partidasNaoIniciadas[--partidasNaoIniciadasInicio] = partida;
        }
    }

    // TODO não permitir que entre na partida que ele mesmo criou
    function entrarPartida() public returns (address) {
        if (partidasNaoIniciadasInicio < partidasNaoIniciadasFim) {
            Partida storage partida = partidasNaoIniciadas[partidasNaoIniciadasInicio];
            require(partida.jogadores[0] != msg.sender, "O jogador não pode jogar contra ele mesmo");
            partidasNaoIniciadasInicio++;

            partida.jogadores[1] = msg.sender;
            partidas[partida.jogadores[0]] = partida;
            return partida.jogadores[0];
        } else {
            criarPartida();
            return msg.sender;
        }
    }

    function receberCartas(address partidaOwner) public view returns (uint8[3]) {
        Partida storage partida = partidas[partidaOwner];
        require(partida.jogadores[0] == msg.sender || partida.jogadores[1] == msg.sender,
            "O jogador precisa pertencer à partida");

        uint8[3] memory cartas;
        if (partida.jogadores[0] == msg.sender) {
            cartas = [partida.cartas[0], partida.cartas[1], partida.cartas[2]];
        } else {
            cartas = [partida.cartas[3], partida.cartas[4], partida.cartas[5]];
        }
        return cartas;
    }

    function fazerJogada(address partidaOwner, uint8 carta) public {
        uint8 turno = partidas[partidaOwner].turno;
        require(partidas[partidaOwner].jogadores[turno] == msg.sender,
            "O jogador deve estar no seu turno para jogar");
        uint8[6] memory cartas = partidas[partidaOwner].cartas;
        require(turno == 0
            ? (cartas[0] == carta || cartas[1] == carta || cartas[2] == carta)
            : (cartas[3] == carta || cartas[4] == carta || cartas[5] == carta),
            "Jogador deve possuir a carta");
        uint8[6] memory jogadas = partidas[partidaOwner].jogadas;
        bool jogada = false;
        for (uint8 i = 0; !jogada && i < partidas[partidaOwner].rodada; i++) {
            jogada = jogadas[i] == carta;
        }
        require(!jogada, "A carta atual não pode ter sido jogada.");
        partidas[partidaOwner].jogadas[partidas[partidaOwner].rodada++] = carta;
    }

    /**
    * 00-09 Ouro
    * 10-19 Espada
    * 20-29 Copas
    * 30-39 Paus
    */
    function compararCartas(uint8 carta1, uint8 carta2) public pure returns (uint8) {
        require(carta1 != carta2, "As cartas não podem ser iguais");

        // Zape 4 Paus
        if (carta1 == 34 || carta2 == 34) {
            return carta1 == 34 ? 1 : 2;
        }
        // Sete de Copas
        if (carta1 == 27 || carta2 == 27) {
            return carta1 == 27 ? 1 : 2;
        }
        // Espadilha Ás de Espadas
        if (carta1 == 10 || carta2 == 10) {
            return carta1 == 10 ? 1 : 2;
        }
        // Sete de Ouro
        if (carta1 == 7 || carta2 == 7) {
            return carta1 == 7 ? 1 : 2;
        }
        if (carta1 % 10 == 3 || carta2 % 10 == 3) {
            if (carta1 % 10 == 3 && carta2 % 10 == 3) {
                return 0;
            }
            return carta1 % 10 == 3 ? 1 : 2;
        }
        if (carta1 % 10 == 2 || carta2 % 10 == 2) {
            if (carta1 % 10 == 2 && carta2 % 10 == 2) {
                return 0;
            }
            return carta1 % 10 == 2 ? 1 : 2;
        }
        if (carta1 % 10 == 1 || carta2 % 10 == 1) {
            if (carta1 % 10 == 1 && carta2 % 10 == 1) {
                return 0;
            }
            return carta1 % 10 == 1 ? 1 : 2;
        }
        carta1 %= 10;
        carta2 %= 10;

        return carta1 == carta2 ? 0 : (carta1 < carta2 ? 2 : 1);
    }
}
