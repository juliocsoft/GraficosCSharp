/*
Entenda as caracter�sticas das consultas mais usadas

Entenda as caracter�sticas das colunas usadas nas consultas.
  - tipo de dados de inteiro e, tamb�m, colunas exclusivas ou n�o nulas

Determine o melhor local de armazenamento para o �ndice.

N�meros grandes de �ndices em uma tabela afetam o desempenho das instru��es INSERT,
UPDATE, DELETE e MERGE 

Tabelas pequenas n�o s�o boas para ter �ndices.

Utilize indice n�o clusterizado para pesquisas mais frequentes
Utilize indices clusterizado para chave prim�ria, com numera��o sequencial e crescente.

Chaves estrangeiras s�o fortes candidatas a ter �ndices. 

Avalie o uso de indices de cobertura. 

Quanto menor for o comprimento de uma chave de �ndice melhor. Colunas do tipo INT s�o as
melhores para se criar uma chave de �ndice. 

Inclua na chave somente as colunas que s�o pesquis�veis.  

Utilize a seletividade das colunas.
   - Colunas altamente seletivas, tende a ter uma repeti��o de dados baixa. Colunas 100% seletivas, tem dados
     exclusivos. S�o �timas candidatas a ter um �ndices. A coluna CPF em uma tabela de cadastros de pessoas f�sicas
	 � um exemplo. 
   - Colunas com baixa seletividade possuem um maior n�mero de dados repetidos. N�o s�o eficientes quando fazem
     parte da primeira chave de um �ndice. Devido ao grande numeros de dados, o SQL SERVER escolha em varrer todos
	 o indice do que fazer a pesquisa pela chave. A coluna SEXO em uma tabela de cadastro de pesssoas f�sicas �
	 um exemplo. 

Em um �ndice composto, seleciona a ordem com que as colunas ser�o criadas em um chave de acordo com pesquisa. 


	



*/