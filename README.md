# PPD Mancala
 
 ### Primeiro trabalho da disciplina Programação Paralela e Distribuída.
 
 O jogo foi desenvolvido utilizando arquitetura Cliente/Servidor, onde a comunicação é feita através de stream sockets. Foi implementado um Echo Server para receber mensagens dos clientes, e enviá-las de volta para todos os sockets conectados.
 
 Passos para rodar o jogo: 
 -  Executar (abrindo no xcode e selecionando o botão run ou cmd + R) a aplicação do servidor MancalaEchoServer (código no arquivo main.swift). Depois é necessário digitar a porta desejada no console para conexão dos sockets.
 
 - Executar o projeto MancalaClient em dois Simuladores diferentes, e entrar com seu username, IP (127.0.0.1) e a mesma porta selecionada no servidor.
 
 - Os jogadores devem decidir entre si quais as suas cores, usando o chat, lembrando que o verde sempre começa primeiro. As regras do jogo já estão implementadas, ou seja, movimentos inválidos não serão permitido, e o controle de turno também é automático. - 
 
  - O jogo detectará o vencedor e dará a opção de sair do jogo ou jogar novamente.
