CREATE DATABASE revisaoProva
GO
USE revisaoProva
GO
CREATE TABLE editora (
codigo			INT				NOT NULL,
nome			VARCHAR(30)		NOT NULL,
site			VARCHAR(40)		NULL
PRIMARY KEY (codigo)
)
GO
CREATE TABLE autor (
codigo			INT				NOT NULL,
nome			VARCHAR(30)		NOT NULL,
biografia		VARCHAR(100)	NOT NULL
PRIMARY KEY (codigo)
)
GO
CREATE TABLE estoque (
codigo			INT				NOT NULL,
nome			VARCHAR(100)	NOT NULL	UNIQUE,
quantidade		INT				NOT NULL,
valor			DECIMAL(7,2)	NOT NULL	CHECK(valor > 0.00),
codEditora		INT				NOT NULL,
codAutor		INT				NOT NULL
PRIMARY KEY (codigo)
FOREIGN KEY (codEditora) REFERENCES editora (codigo),
FOREIGN KEY (codAutor) REFERENCES autor (codigo)
)
GO
CREATE TABLE compra (
codigo			INT				NOT NULL,
codEstoque		INT				NOT NULL,
qtdComprada		INT				NOT NULL,
valor			DECIMAL(7,2)	NOT NULL,
dataCompra		DATE			NOT NULL
PRIMARY KEY (codigo, codEstoque, dataCompra)
FOREIGN KEY (codEstoque) REFERENCES estoque (codigo)
)
GO
INSERT INTO editora VALUES
(1,'Pearson','www.pearson.com.br'),
(2,'Civiliza  o Brasileira',NULL),
(3,'Makron Books','www.mbooks.com.br'),
(4,'LTC','www.ltceditora.com.br'),
(5,'Atual','www.atualeditora.com.br'),
(6,'Moderna','www.moderna.com.br')
GO
INSERT INTO autor VALUES
(101,'Andrew Tannenbaun','Desenvolvedor do Minix'),
(102,'Fernando Henrique Cardoso','Ex-Presidente do Brasil'),
(103,'Diva Marilia Flemming','Professora adjunta da UFSC'),
(104,'David Halliday','Ph.D. da University of Pittsburgh'),
(105,'Alfredo Steinbruch','Professor de Matematica da UFRS e da PUCRS'),
(106,'Willian Roberto Cereja','Doutorado em Linguistica Aplicada e Estudos da Linguagem'),
(107,'William Stallings','Doutorado em Ciencias da Computac o pelo MIT'),
(108,'Carlos Morimoto','Criador do Kurumin Linux')
GO
INSERT INTO estoque VALUES
(10001,'Sistemas Operacionais Modernos ',4,108.00,1,101),
(10002,'A Arte da Pol tica',2,55.00,2,102),
(10003,'Calculo A',12,79.00,3,103),
(10004,'Fundamentos de Fisica I',26,68.00,4,104),
(10005,'Geometria Analitica',1,95.00,3,105),
(10006,'Gram tica Reflexiva',10,49.00,5,106),
(10007,'Fundamentos de Fisica III',1,78.00,4,104),
(10008,'Calculo B',3,95.00,3,103)
GO
INSERT INTO compra VALUES
(15051,10003,2,158.00,'04/07/2021'),
(15051,10008,1,95.00,'04/07/2021'),
(15051,10004,1,68.00,'04/07/2021'),
(15051,10007,1,78.00,'04/07/2021'),
(15052,10006,1,49.00,'05/07/2021'),
(15052,10002,3,165.00,'05/07/2021'),
(15053,10001,1,108.00,'05/07/2021'),
(15054,10003,1,79.00,'06/08/2021'),
(15054,10008,1,95.00,'06/08/2021')

--Pede-se:	
--1) Consultar nome, valor unit�rio, nome da editora e nome do autor dos livros do estoque que foram vendidos. N�o podem haver repeti��es.

SELECT DISTINCT estoque.nome AS Nome_Livro,
		estoque.valor AS Valor_Unit�rio,
		editora.nome AS Nome_Editora,
		autor.nome AS Nome_Autor
	
FROM estoque
INNER JOIN editora ON estoque.codEditora = editora.codigo
INNER JOIN autor ON estoque.codAutor = autor.codigo;


--2) Consultar nome do livro, quantidade comprada e valor de compra da compra 15051

SELECT 	estoque.nome AS Nome_Livro,
	compra.qtdComprada AS Qtd_Comprada,
	compra.valor AS Valor

FROM compra
INNER JOIN estoque ON compra.codEstoque = estoque.codigo
WHERE compra.codigo = 15051;

	
--3) Consultar Nome do livro e site da editora dos livros da Makron books (Caso o site tenha mais de 10 d�gitos, remover o www.).	

SELECT 	estoque.nome AS Nome_Livro,
	CASE 
		WHEN LEN(editora.site) > 10 AND LEFT (editora.site, 4) = 'www.'
		THEN SUBSTRING (editora.site, 5, LEN(editora.site) -4)
	ELSE 
		editora.site
	END AS Site
FROM estoque
INNER JOIN editora ON estoque.codEditora = editora.codigo
WHERE editora.nome = 'Makron books';


--4) Consultar nome do livro e Breve Biografia do David Halliday	


SELECT 	estoque.nome AS Nome_Livro,	
	autor.biografia AS Biografia
FROM estoque
INNER JOIN autor ON estoque.codAutor = autor.codigo
WHERE autor.nome = 'David Halliday';

--5) Consultar c�digo de compra e quantidade comprada do livro Sistemas Operacionais Modernos	


SELECT  compra.codigo AS Codigo_Compra,
	compra.qtdComprada AS Qtd_Comprada
FROM compra
INNER JOIN estoque ON compra.codEstoque = estoque.codigo
WHERE estoque.nome = 'Sistemas Operacionais Modernos';


--6) Consultar quais livros n�o foram vendidos


SELECT estoque.nome AS Livros_N�o_Vendidos
FROM estoque
INNER JOIN compra ON estoque.codigo = compra.codEstoque
WHERE compra.codigo  IS NULL;

	
--7) Consultar quais livros foram vendidos e n�o est�o cadastrados. Caso o nome dos livros terminem com espa�o, fazer o trim apropriado.


SELECT DISTINCT
	RTRIM (estoque.nome) AS Nome_Livro
	FROM estoque
	LEFT JOIN compra ON estoque.codigo = compra.codEstoque
	WHERE compra.codigo IS NULL;

	
--8) Consultar Nome e site da editora que n�o tem Livros no estoque (Caso o site tenha mais de 10 d�gitos, remover o www.)	


SELECT  editora.nome AS Nome_Editora,
	CASE 
		WHEN LEN(editora.site) > 10 AND LEFT(editora.site, 4) = 'www.' 
		THEN SUBSTRING (editora.site, 5, LEN(editora.site) - 4)
	ELSE editora.site
	END AS Site
FROM editora
LEFT JOIN estoque ON estoque.codEditora = editora.codigo
WHERE estoque.codigo IS NULL;


--9) Consultar Nome e biografia do autor que n�o tem Livros no estoque (Caso a biografia inicie com Doutorado, substituir por Ph.D.)	


SELECT  autor.nome AS Nome_Autor,
	CASE
	WHEN autor.biografia LIKE 'Doutorado%' 
	THEN REPLACE (autor.biografia, 'Doutorado', 'Ph.D.')
	ELSE autor.biografia
	END AS Biografia
FROM autor
LEFT JOIN estoque ON autor.codigo = estoque.codAutor
WHERE estoque.codigo IS NULL;


--10) Consultar o nome do Autor, e o maior valor de Livro no estoque. Ordenar por valor descendente	


SELECT autor.nome AS Nome_Autor,
       MAX(estoque.valor) AS Valor_Livro
FROM estoque
INNER JOIN autor ON estoque.codAutor = autor.codigo
GROUP BY autor.nome
ORDER BY Valor_Livro DESC;


--11) Consultar o c�digo da compra, o total de livros comprados e a soma dos valores gastos. Ordenar por C�digo da Compra ascendente.


SELECT  codigo AS Codigo_Compra,
	SUM(qtdComprada) AS Total_Livros_Comprados,
	SUM(valor) AS Valor_Total
FROM compra
GROUP BY codigo
ORDER BY codigo ASC;
	
	
--12) Consultar o nome da editora e a m�dia de pre�os dos livros em estoque.Ordenar pela M�dia de Valores ascendente.	


SELECT  editora.nome AS Nome_Editora,
	AVG(estoque.valor) AS Media_Valor 
FROM editora 
INNER JOIN estoque ON editora.codigo = estoque.codEditora
GROUP BY editora.nome
ORDER BY Media_Valor ASC;


--13) Consultar o nome do Livro, a quantidade em estoque o nome da editora, o site da editora (Caso o site tenha mais de 10 d�gitos, remover o www.), criar uma coluna status onde:	
	--Caso tenha menos de 5 livros em estoque, escrever Produto em Ponto de Pedido
	--Caso tenha entre 5 e 10 livros em estoque, escrever Produto Acabando
	--Caso tenha mais de 10 livros em estoque, escrever Estoque Suficiente
	--A Ordena��o deve ser por Quantidade ascendente


SELECT estoque.nome AS Nome_Livro,
       estoque.quantidade AS Quantidade_Estoque,
       editora.nome AS Nome_Editora,
       CASE
           WHEN LEN(editora.site) > 10 AND LEFT(editora.site, 4) = 'www.'
           THEN SUBSTRING(editora.site, 5, LEN(editora.site) - 4)
           ELSE editora.site
       END AS Site,
       CASE
           WHEN estoque.quantidade < 5 THEN 'Produto em Ponto de Pedido'
           WHEN estoque.quantidade BETWEEN 5 AND 10 THEN 'Produto Acabando'
           ELSE 'Estoque Suficiente'
       END AS Status
FROM estoque
INNER JOIN editora ON estoque.codEditora = editora.codigo
ORDER BY estoque.quantidade ASC;

--14) Para montar um relat�rio, � necess�rio montar uma consulta com a seguinte sa�da: C�digo do Livro, Nome do Livro, Nome do Autor, Info Editora (Nome da Editora + Site) de todos os livros	
	--S� pode concatenar sites que n�o s�o nulos


SELECT estoque.codigo AS Codigo_Livro,
       estoque.nome AS Nome_Livro,
       autor.nome AS Nome_Autor,
       CONCAT(editora.nome, ', ', editora.site) AS Info_Editora
FROM estoque
INNER JOIN autor ON estoque.codAutor = autor.codigo
INNER JOIN editora ON estoque.codEditora = editora.codigo
WHERE editora.site IS NOT NULL;


--15) Consultar Codigo da compra, quantos dias da compra at� hoje e quantos meses da compra at� hoje	

SELECT  codigo AS Codigo_Compra,
	DATEDIFF(day, dataCompra, GETDATE()) AS Qtd_Dias_Compra,
	DATEDIFF(month, dataCompra, GETDATE()) AS Qtd_Meses_Compra
FROM compra;


--16) Consultar o c�digo da compra e a soma dos valores gastos das compras que somam mais de 200.00


SELECT  
    codigo AS Compra_Codigo,
    SUM(valor) AS Total_Valor
FROM 
    compra
GROUP BY 
    codigo
HAVING 
    SUM(valor) > 200;