
CREATE PROCEDURE sp_valida_cpf(@cpf CHAR(11), @valido BIT OUTPUT)
	AS
		DECLARE @contador INT,
				@indice INT, 
				@somatoria INT,
				@num1 INT,
				@num2 INT,
				@verifica INT,
				@tamanho INT,
				@resto INT

		SET @contador =0
		SET @indice = 10
		SET @somatoria =0
		SET @tamanho =1

	WHILE (@contador < 9)
	BEGIN
	
		SET @num1 = CONVERT(INT, substring(@cpf, @tamanho, 1))
		SET @somatoria = @somatoria+(@indice*@num1)

		SET @contador = @contador +1
		SET @tamanho = @tamanho+1
		SET @indice = @indice -1
	END

	SET @resto = @somatoria%11

	IF(@resto < 2)
	BEGIN
		SET @num1 = 0
	END

	ELSE
	BEGIN 
		SET @num1 = 11- @resto
	END

--Segundo digito 

	SET @contador =0
	SET @indice = 11
	SET @somatoria =0
	SET @tamanho = 1

	WHILE (@contador < 10)
	BEGIN
		IF(@contador< 9)
		BEGIN
			SET @num2 = CONVERT(INT, substring(@cpf, @tamanho, 1))
			SET @somatoria = @somatoria+(@indice*@num2)

			SET @contador = @contador +1
			SET @tamanho = @tamanho+1
			SET @indice = @indice -1
		END
		
		ELSE
		BEGIN
			SET @somatoria = @somatoria+(@num1*@indice)
			SET @contador = @contador +1
		END
	END

	SET @resto = @somatoria%11

	IF(@resto < 2)
	BEGIN
		SET @num2 = 0
	END

	ELSE
	BEGIN 
		SET @num2 = 11- @resto
	END

-- Verificação se os digitos são iguais aos digitados

IF(@num1 = CONVERT(INT, SUBSTRING(@cpf, 10,1)) AND @num2 = CONVERT(INT, SUBSTRING(@cpf, 11,1)))
BEGIN
	SET @valido = 1
END
ELSE
BEGIN
	SET @valido = 0
END
-- verificação se todos são iguais
SET @contador = 0
SET @num1 = 0
SET @somatoria =0
SET @tamanho = 1
SET @verifica = CONVERT(INT, substring(@cpf, @tamanho, 1))

WHILE(@contador<11)
BEGIN
	SET @contador = @contador+1
	SET @num1 = CONVERT(INT, substring(@cpf, @tamanho, 1))
	SET @tamanho = @tamanho+1
	IF(@num1 = @verifica)
	BEGIN 
		SET @somatoria = @somatoria +1
	END
END
print @somatoria 

IF(@somatoria = 11)
BEGIN
	SET @valido = 0
END
ELSE
BEGIN
	SET @valido = 1
END


 --criar uma DATABASE, com uma tabela 
--cadastro (cpf, nome, logradouro, numero)

create database validacao_cpf
go
use validacao_cpf

create table pessoa(
id int not null,
nome varchar(100) not null,
cpf char(11) not null,
logradouro varchar(100) not null,
numero char(11) not null

primary key(id)
)


--Op = D (Delete) ; Op = U (Update) ; Op = I (Insert)
CREATE PROCEDURE sp_pessoa_cpf (@op CHAR(1), @id INT, 
	@nome VARCHAR(100), @cpf CHAR(11), @logradouro VARCHAR(100), @numero char(11),
	@saida VARCHAR(200) OUTPUT)
AS
	DECLARE @valido_cpf	BIT,
			@cont			INT,
			@novo_id		INT
 
	IF (UPPER(@op)='D' AND @id IS NOT NULL)
	BEGIN
		DELETE pessoa WHERE id = @id
		SET @saida = 'Pessoa ID = '+CAST(@id AS VARCHAR(5))+
			' excluída'
	END
	ELSE
	BEGIN
		IF (UPPER(@op)='D' AND @id IS NULL)
		BEGIN
			RAISERROR('ID não pode ser nulo para operação de delete', 16, 1)
		END
		ELSE
		BEGIN
			EXEC sp_valida_cpf @cpf,
				@valido_cpf OUTPUT
			PRINT @valido_cpf
 
			IF (@valido_cpf = 0 )
			BEGIN
				RAISERROR('CPF inválido (Números Iguais, nulos ou incorretos)', 16, 1)
			END
			ELSE 
				IF (UPPER(@op) = 'I')
				BEGIN
					SET @cont = (SELECT COUNT(id) FROM pessoa)
					IF (@cont = 0)
					BEGIN
						SET @novo_id = 1
					END
					ELSE
					BEGIN
						SELECT @novo_id = MAX(id) + 1 FROM pessoa
					END
 
					INSERT INTO pessoa VALUES
					(@novo_id, @nome, @cpf, @logradouro, @numero)
 
					SET @saida = 'Pessoa cadastrada'
				END
				ELSE
				BEGIN
					IF (UPPER(@op) = 'U')
					BEGIN
						UPDATE pessoa
						SET nome = @nome, cpf = @cpf,
							logradouro = @logradouro, numero = @numero
						WHERE id = @id
 
						SET @saida = 'Pessoa ID = ' +
							CAST(@id AS VARCHAR(5)) + ' atualizada'
					END
					ELSE
					BEGIN
						RAISERROR('Operação Inválida', 16, 1)
					END
				END
			END
		END


SELECT*FROM pessoa 

(@op CHAR(1), @id INT, 
	@nome VARCHAR(100), @cpf CHAR(11), @logradouro VARCHAR(100), @numero char(11),
	@saida VARCHAR(200) OUTPUT)
AS

-- testes 
DECLARE @out VARCHAR(200)
EXEC sp_pessoa_cpf 'I', 1 , 'Cicrano da silva', '94710932018', 'rua dos lokos', '11111111111', 
	@out OUTPUT
PRINT @out

DECLARE @out2 VARCHAR(200)
EXEC sp_pessoa_cpf 'D', 1 , 'Fulano da silva', '17922027095', 'rua dos lokos', '11111111111', 
	@out2 OUTPUT
PRINT @out2

DECLARE @out3 VARCHAR(200)
EXEC sp_pessoa_cpf 'U', 2 , 'Ronaldo fenomeno', '76002598006', 'rua dos craques', '11111111111', 
	@out3 OUTPUT
PRINT @out3
