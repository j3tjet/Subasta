// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract subasta{
    struct Puja{
        address postor;
        uint valor;
        uint tiempo;
    }
    address payable public immutable  beneficiario ;
    uint public tiempoFinal;
    uint public tiempoParaRetiro;
    address payable public postorMasAlto;
    uint public montoMasAlto;
    mapping (address=>uint) public totalPendiente;
    mapping (address=>uint[]) public pujasPendientes;
    Puja[] public pujas;
    

    error Subasta_LaSubastaFinalizo();
    error Subasta_LaSubastaNoFinalizo();
    error Subasta_AunQuedaTiempoDeRetiro();
    error Subasta_PujaDebeSerMayorACincoPorCientoDeLaAnterior();
    error Subasta_noHayPujasPendientes();
    error Subasta_noSePudoHacerElRetiro();
    error Subasta_NoHayPostores();
    error Subasta_NoEresElBeneficiario();

    event NuevaOferta(address indexed postor,uint valor);
    event SubastaFinalizada(address indexed ganador,uint valor);

    modifier soloBeneficiario() {
        if (msg.sender != beneficiario) {
            revert Subasta_NoEresElBeneficiario();
        }
        _;
    }


    constructor(uint duracionMinutos){
        
        beneficiario = payable(msg.sender);
        uint duracion=duracionMinutos *60;
        tiempoFinal  = block.timestamp + duracion;

    }
    
    function puja() external payable {
        if(block.timestamp > tiempoFinal){
            revert Subasta_LaSubastaFinalizo();
        }
        if(msg.value<montoMasAlto+(montoMasAlto*5/100)){
            revert Subasta_PujaDebeSerMayorACincoPorCientoDeLaAnterior();
        }
        if (postorMasAlto != address(0)){
            totalPendiente[postorMasAlto] += montoMasAlto;
            pujasPendientes[postorMasAlto].push(montoMasAlto);
        }


        postorMasAlto = payable (msg.sender);
        montoMasAlto = msg.value;

        Puja memory nuevaPuja= Puja(postorMasAlto,msg.value, block.timestamp);
        pujas.push(nuevaPuja);

        emit NuevaOferta(msg.sender, msg.value);

        if(block.timestamp > tiempoFinal - 10 minutes){
            tiempoFinal += 10 minutes;
        }
    }

    function retirar() external{

        if(totalPendiente[msg.sender]== 0){
            revert Subasta_noHayPujasPendientes();
        }
        
        uint monto=totalPendiente[msg.sender];
        uint comision=  monto*2/100;
        uint montoAEnviar= monto-comision;
        totalPendiente[msg.sender]=0;
        delete pujasPendientes[msg.sender];

        (bool sent,)=payable (msg.sender).call{value: montoAEnviar}("");
        if (!sent){
            revert Subasta_noSePudoHacerElRetiro();
        }
    }

    function retiroParcial()external{
        if(totalPendiente[msg.sender]== 0){
            revert Subasta_noHayPujasPendientes();
        }

        uint montoPuja= pujasPendientes[msg.sender][pujasPendientes[msg.sender].length - 1];
        uint comision= montoPuja*2/100;
        uint montoAEnviar= montoPuja-comision;

        pujasPendientes[msg.sender].pop();
        totalPendiente[msg.sender]-=montoAEnviar;
        (bool sent,)=payable (msg.sender).call{value: montoAEnviar}("");
        if (!sent){
            revert Subasta_noSePudoHacerElRetiro();
        }

    }

    function mostrarHistorialPujas() public view returns(Puja [] memory){
        return pujas;
    }

    function mostrarGanador() public view returns(address ganador,uint monto){
        if (block.timestamp<tiempoFinal){
            revert Subasta_LaSubastaNoFinalizo();
        }
        if(postorMasAlto == address(0)){
            revert Subasta_NoHayPostores();
        }
        return (postorMasAlto,montoMasAlto);
    }

    function finalizarSubasta() external soloBeneficiario {
        if(tiempoParaRetiro!=0){
            revert Subasta_LaSubastaFinalizo();
        }
        if(block.timestamp<tiempoFinal){
            revert Subasta_LaSubastaNoFinalizo();
        }
        tiempoParaRetiro = block.timestamp +1 days;
        emit SubastaFinalizada(postorMasAlto,montoMasAlto);

    }
    
    function retirarGananciaSubastador()external soloBeneficiario {
        
        if(tiempoParaRetiro==0){
            revert Subasta_LaSubastaNoFinalizo();
        }
        if(block.timestamp<tiempoParaRetiro){
            revert Subasta_AunQuedaTiempoDeRetiro();
        }
        if (postorMasAlto == address(0)){
            revert Subasta_NoHayPostores();
        }
        uint monto = address(this).balance;
        (bool sent,)= payable(beneficiario).call{value:monto }("");
        if(!sent){
            revert Subasta_noSePudoHacerElRetiro();
        }
    }

}