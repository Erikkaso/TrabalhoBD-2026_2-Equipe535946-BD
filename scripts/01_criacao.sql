-- Trabalho Final - BD 2026.2 - Biblioteca acadêmica
-- Equipe 535946: Giovanna dos Santos Marques (536930),
--                Iarley Cavalcante Tavares Balreira (535946),
--                Pedro Eric Carneiro (538121)
-- Script 01: criação do banco. MySQL 5.7+

SET NAMES utf8mb4;
DROP DATABASE IF EXISTS equipe535946;
CREATE DATABASE equipe535946
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;
USE equipe535946;

-- TABELAS

-- Curso (referenciado por alunos e professores)
CREATE TABLE curso (
  cod_curso  INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome_curso VARCHAR(100) NOT NULL,
  PRIMARY KEY (cod_curso),
  UNIQUE KEY uq_curso_nome (nome_curso)
) ENGINE = InnoDB;

-- Categoria e subcategoria (chave única composta permite a FK composta de livro)
CREATE TABLE categoria (
  cod_categoria INT UNSIGNED NOT NULL AUTO_INCREMENT,
  descricao     VARCHAR(100) NOT NULL,
  PRIMARY KEY (cod_categoria),
  UNIQUE KEY uq_categoria_descricao (descricao)
) ENGINE = InnoDB;

CREATE TABLE subcategoria (
  cod_subcategoria INT UNSIGNED NOT NULL AUTO_INCREMENT,
  cod_categoria    INT UNSIGNED NOT NULL,
  descricao        VARCHAR(100) NOT NULL,
  PRIMARY KEY (cod_subcategoria),
  UNIQUE KEY uq_subcategoria_cod_cat (cod_subcategoria, cod_categoria),
  UNIQUE KEY uq_subcategoria_desc_cat (cod_categoria, descricao),
  CONSTRAINT fk_subcategoria_categoria
    FOREIGN KEY (cod_categoria) REFERENCES categoria (cod_categoria)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

-- Livro (qtd_exemplares é mantida por triggers)
CREATE TABLE livro (
  isbn             VARCHAR(17)       NOT NULL,
  titulo           VARCHAR(200)      NOT NULL,
  ano_lancamento   SMALLINT UNSIGNED NOT NULL,
  editora          VARCHAR(100)      NOT NULL,
  qtd_exemplares   INT UNSIGNED      NOT NULL DEFAULT 0,
  cod_categoria    INT UNSIGNED      NOT NULL,
  cod_subcategoria INT UNSIGNED      NOT NULL,
  PRIMARY KEY (isbn),
  KEY idx_livro_titulo (titulo),
  KEY idx_livro_editora (editora),
  KEY idx_livro_ano (ano_lancamento),
  KEY idx_livro_categoria (cod_categoria),
  CONSTRAINT fk_livro_categoria
    FOREIGN KEY (cod_categoria) REFERENCES categoria (cod_categoria)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  -- a subcategoria tem que pertencer à categoria do livro
  CONSTRAINT fk_livro_subcategoria
    FOREIGN KEY (cod_subcategoria, cod_categoria)
    REFERENCES subcategoria (cod_subcategoria, cod_categoria)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

-- Exemplar (entidade fraca de livro; número sequencial por trigger)
CREATE TABLE exemplar (
  isbn            VARCHAR(17)  NOT NULL,
  numero_exemplar INT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (isbn, numero_exemplar),
  CONSTRAINT fk_exemplar_livro
    FOREIGN KEY (isbn) REFERENCES livro (isbn)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB;

-- Autor e relacionamento N:N com Livro (com indicação do autor principal)
CREATE TABLE autor (
  cod_autor     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome          VARCHAR(120) NOT NULL,
  email         VARCHAR(120) NOT NULL,
  nacionalidade VARCHAR(60)  NOT NULL,
  PRIMARY KEY (cod_autor),
  UNIQUE KEY uq_autor_email (email),
  KEY idx_autor_nome (nome)
) ENGINE = InnoDB;

CREATE TABLE livro_autor (
  isbn            VARCHAR(17)  NOT NULL,
  cod_autor       INT UNSIGNED NOT NULL,
  autor_principal TINYINT(1)   NOT NULL DEFAULT 0,
  PRIMARY KEY (isbn, cod_autor),
  KEY idx_livro_autor_autor (cod_autor),
  CONSTRAINT fk_livro_autor_livro
    FOREIGN KEY (isbn) REFERENCES livro (isbn)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_livro_autor_autor
    FOREIGN KEY (cod_autor) REFERENCES autor (cod_autor)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

-- Tipo de usuário: limite de livros, prazo e multa por dia de atraso
CREATE TABLE tipo_usuario (
  tipo       VARCHAR(11)       NOT NULL,
  max_livros TINYINT UNSIGNED  NOT NULL,
  prazo_dias SMALLINT UNSIGNED NOT NULL,
  multa_dia  DECIMAL(6, 2)     NOT NULL,
  PRIMARY KEY (tipo)
) ENGINE = InnoDB;

-- Política de empréstimo
INSERT INTO tipo_usuario (tipo, max_livros, prazo_dias, multa_dia) VALUES
  ('ALUNO',       3, 15, 1.00),
  ('FUNCIONARIO', 4, 21, 1.50),
  ('PROFESSOR',   5, 30, 2.00);

-- Usuários: generalização (aluno, professor, funcionário); o tipo é fixado por trigger
CREATE TABLE usuario (
  id_usuario        INT UNSIGNED NOT NULL AUTO_INCREMENT,
  tipo              VARCHAR(11)  NOT NULL,
  nome              VARCHAR(120) NOT NULL,
  endereco          VARCHAR(255) NOT NULL,
  situacao          ENUM('ATIVO', 'CANCELADO') NOT NULL DEFAULT 'ATIVO',
  data_cadastro     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  data_cancelamento DATETIME     NULL,
  PRIMARY KEY (id_usuario),
  UNIQUE KEY uq_usuario_id_tipo (id_usuario, tipo),
  KEY idx_usuario_nome (nome),
  CONSTRAINT fk_usuario_tipo
    FOREIGN KEY (tipo) REFERENCES tipo_usuario (tipo)
    ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE = InnoDB;

CREATE TABLE aluno (
  id_usuario             INT UNSIGNED NOT NULL,
  tipo                   VARCHAR(11) NOT NULL DEFAULT 'ALUNO',
  matricula              INT UNSIGNED NOT NULL,
  cod_curso              INT UNSIGNED NOT NULL,
  data_ingresso          DATE         NOT NULL,
  data_conclusao_prevista DATE        NOT NULL,
  PRIMARY KEY (id_usuario),
  UNIQUE KEY uq_aluno_matricula (matricula),
  KEY idx_aluno_curso (cod_curso),
  CONSTRAINT fk_aluno_usuario
    FOREIGN KEY (id_usuario, tipo) REFERENCES usuario (id_usuario, tipo)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_aluno_curso
    FOREIGN KEY (cod_curso) REFERENCES curso (cod_curso)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

CREATE TABLE professor (
  id_usuario       INT UNSIGNED NOT NULL,
  tipo             VARCHAR(11) NOT NULL DEFAULT 'PROFESSOR',
  mat_siape        INT UNSIGNED NOT NULL,
  cod_curso        INT UNSIGNED NOT NULL,
  -- domínio do regime de trabalho
  regime_trabalho  ENUM('20h', '40h', 'DE') NOT NULL,
  data_contratacao DATE         NOT NULL,
  PRIMARY KEY (id_usuario),
  UNIQUE KEY uq_professor_siape (mat_siape),
  KEY idx_professor_curso (cod_curso),
  CONSTRAINT fk_professor_usuario
    FOREIGN KEY (id_usuario, tipo) REFERENCES usuario (id_usuario, tipo)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_professor_curso
    FOREIGN KEY (cod_curso) REFERENCES curso (cod_curso)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

CREATE TABLE funcionario (
  id_usuario INT UNSIGNED NOT NULL,
  tipo       VARCHAR(11) NOT NULL DEFAULT 'FUNCIONARIO',
  matricula  INT UNSIGNED NOT NULL,
  PRIMARY KEY (id_usuario),
  UNIQUE KEY uq_funcionario_matricula (matricula),
  CONSTRAINT fk_funcionario_usuario
    FOREIGN KEY (id_usuario, tipo) REFERENCES usuario (id_usuario, tipo)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB;

-- Telefones (atributo multivalorado): quantidade ilimitada por usuário
CREATE TABLE telefone_usuario (
  id_usuario INT UNSIGNED NOT NULL,
  numero     VARCHAR(20)  NOT NULL,
  PRIMARY KEY (id_usuario, numero),
  CONSTRAINT fk_telefone_usuario
    FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB;

-- Reserva (N:N usuário x livro, com data da reserva)
CREATE TABLE reserva (
  id_usuario   INT UNSIGNED NOT NULL,
  isbn         VARCHAR(17)  NOT NULL,
  data_reserva DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_usuario, isbn, data_reserva),
  KEY idx_reserva_livro (isbn, data_reserva),
  CONSTRAINT fk_reserva_usuario
    FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_reserva_livro
    FOREIGN KEY (isbn) REFERENCES livro (isbn)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB;

-- Empréstimo e itens (um ou mais exemplares, devolução individual)
CREATE TABLE emprestimo (
  id_emprestimo   INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_usuario      INT UNSIGNED NOT NULL,
  data_emprestimo DATE         NOT NULL,   -- padrão: CURDATE() (trigger)
  PRIMARY KEY (id_emprestimo),
  KEY idx_emprestimo_usuario (id_usuario),
  CONSTRAINT fk_emprestimo_usuario
    FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

CREATE TABLE item_emprestimo (
  id_emprestimo           INT UNSIGNED  NOT NULL,
  isbn                    VARCHAR(17)   NOT NULL,
  numero_exemplar         INT UNSIGNED  NOT NULL,
  data_prevista_devolucao DATE          NOT NULL,  -- calculada pelo trigger
  data_devolucao_efetiva  DATE          NULL,      -- NULL = ainda emprestado
  valor_multa             DECIMAL(8, 2) NULL,      -- calculado na devolução
  PRIMARY KEY (id_emprestimo, isbn, numero_exemplar),
  KEY idx_item_exemplar (isbn, numero_exemplar),
  CONSTRAINT fk_item_emprestimo
    FOREIGN KEY (id_emprestimo) REFERENCES emprestimo (id_emprestimo)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_item_exemplar
    FOREIGN KEY (isbn, numero_exemplar) REFERENCES exemplar (isbn, numero_exemplar)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

-- TRIGGERS
DELIMITER $$

-- LIVRO / EXEMPLAR: qtd_exemplares sempre = nº de registros de exemplar
CREATE TRIGGER trg_livro_bi BEFORE INSERT ON livro
FOR EACH ROW
BEGIN
  -- a quantidade vem dos registros de exemplar
  SET NEW.qtd_exemplares = 0;
END$$

CREATE TRIGGER trg_livro_bu BEFORE UPDATE ON livro
FOR EACH ROW
BEGIN
  -- impede valor inconsistente
  SET NEW.qtd_exemplares =
      (SELECT COUNT(*) FROM exemplar WHERE isbn = OLD.isbn);
END$$

CREATE TRIGGER trg_exemplar_bi BEFORE INSERT ON exemplar
FOR EACH ROW
BEGIN
  -- número sequencial dentro do livro
  IF NEW.numero_exemplar IS NULL OR NEW.numero_exemplar = 0 THEN
    SET NEW.numero_exemplar =
        (SELECT COALESCE(MAX(numero_exemplar), 0) + 1
           FROM exemplar WHERE isbn = NEW.isbn);
  END IF;
END$$

CREATE TRIGGER trg_exemplar_ai AFTER INSERT ON exemplar
FOR EACH ROW
BEGIN
  UPDATE livro
     SET qtd_exemplares = (SELECT COUNT(*) FROM exemplar WHERE isbn = NEW.isbn)
   WHERE isbn = NEW.isbn;
END$$

CREATE TRIGGER trg_exemplar_ad AFTER DELETE ON exemplar
FOR EACH ROW
BEGIN
  UPDATE livro
     SET qtd_exemplares = (SELECT COUNT(*) FROM exemplar WHERE isbn = OLD.isbn)
   WHERE isbn = OLD.isbn;
END$$

-- LIVRO_AUTOR: no máximo um autor principal por livro
CREATE TRIGGER trg_livro_autor_bi BEFORE INSERT ON livro_autor
FOR EACH ROW
BEGIN
  DECLARE v_ja_tem_principal INT;
  SELECT COUNT(*) INTO v_ja_tem_principal
    FROM livro_autor WHERE isbn = NEW.isbn AND autor_principal = 1;

  IF NEW.autor_principal = 1 AND v_ja_tem_principal > 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Este livro já possui um autor principal';
  ELSEIF v_ja_tem_principal = 0 THEN
    -- o primeiro autor vira o principal
    SET NEW.autor_principal = 1;
  END IF;
END$$

CREATE TRIGGER trg_livro_autor_bu BEFORE UPDATE ON livro_autor
FOR EACH ROW
BEGIN
  IF NEW.autor_principal = 1 AND EXISTS (
       SELECT 1 FROM livro_autor
        WHERE isbn = OLD.isbn AND autor_principal = 1
          AND cod_autor <> OLD.cod_autor) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Este livro já possui um autor principal';
  END IF;
END$$

-- ALUNO: não cadastrar quem já atingiu a data de conclusão prevista
CREATE TRIGGER trg_aluno_bi BEFORE INSERT ON aluno
FOR EACH ROW
BEGIN
  SET NEW.tipo = 'ALUNO';
  IF NEW.data_conclusao_prevista <= CURDATE() THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Cadastro negado: a data de conclusão prevista do aluno já foi atingida';
  END IF;
END$$

CREATE TRIGGER trg_aluno_bu BEFORE UPDATE ON aluno
FOR EACH ROW
BEGIN
  SET NEW.tipo = 'ALUNO';
END$$

-- PROFESSOR / FUNCIONARIO: fixam o tipo da especialização
CREATE TRIGGER trg_professor_bi BEFORE INSERT ON professor
FOR EACH ROW
BEGIN
  SET NEW.tipo = 'PROFESSOR';
END$$

CREATE TRIGGER trg_professor_bu BEFORE UPDATE ON professor
FOR EACH ROW
BEGIN
  SET NEW.tipo = 'PROFESSOR';
END$$

CREATE TRIGGER trg_funcionario_bi BEFORE INSERT ON funcionario
FOR EACH ROW
BEGIN
  SET NEW.tipo = 'FUNCIONARIO';
END$$

CREATE TRIGGER trg_funcionario_bu BEFORE UPDATE ON funcionario
FOR EACH ROW
BEGIN
  SET NEW.tipo = 'FUNCIONARIO';
END$$

-- USUARIO: controla a data de cancelamento do cadastro
CREATE TRIGGER trg_usuario_bu BEFORE UPDATE ON usuario
FOR EACH ROW
BEGIN
  IF NEW.situacao = 'CANCELADO' AND OLD.situacao <> 'CANCELADO' THEN
    SET NEW.data_cancelamento = NOW();
  ELSEIF NEW.situacao = 'ATIVO' AND OLD.situacao <> 'ATIVO' THEN
    SET NEW.data_cancelamento = NULL;
  END IF;
END$$

-- RESERVA: usuário com cadastro cancelado não reserva
CREATE TRIGGER trg_reserva_bi BEFORE INSERT ON reserva
FOR EACH ROW
BEGIN
  DECLARE v_situacao VARCHAR(20);
  SELECT situacao INTO v_situacao FROM usuario WHERE id_usuario = NEW.id_usuario;
  IF v_situacao <> 'ATIVO' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Usuário com cadastro cancelado não pode fazer reservas';
  END IF;
END$$

-- EMPRESTIMO: usuário com cadastro cancelado não pega livros
CREATE TRIGGER trg_emprestimo_bi BEFORE INSERT ON emprestimo
FOR EACH ROW
BEGIN
  DECLARE v_situacao VARCHAR(20);
  SELECT situacao INTO v_situacao FROM usuario WHERE id_usuario = NEW.id_usuario;
  IF v_situacao <> 'ATIVO' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Usuário com cadastro cancelado não pode fazer empréstimos';
  END IF;
  IF NEW.data_emprestimo IS NULL THEN
    SET NEW.data_emprestimo = CURDATE();
  END IF;
END$$

-- ITEM_EMPRESTIMO: limite por tipo, exemplar livre e prazo de devolução
CREATE TRIGGER trg_item_emprestimo_bi BEFORE INSERT ON item_emprestimo
FOR EACH ROW
BEGIN
  DECLARE v_id_usuario INT UNSIGNED;
  DECLARE v_tipo       VARCHAR(20);
  DECLARE v_situacao   VARCHAR(20);
  DECLARE v_data_emp   DATE;
  DECLARE v_max        INT;
  DECLARE v_prazo      INT;
  DECLARE v_abertos    INT;

  SELECT e.id_usuario, e.data_emprestimo, u.tipo, u.situacao
    INTO v_id_usuario, v_data_emp, v_tipo, v_situacao
    FROM emprestimo e
    JOIN usuario u ON u.id_usuario = e.id_usuario
   WHERE e.id_emprestimo = NEW.id_emprestimo;

  IF v_situacao <> 'ATIVO' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Usuário com cadastro cancelado não pode fazer empréstimos';
  END IF;

  SELECT max_livros, prazo_dias INTO v_max, v_prazo
    FROM tipo_usuario WHERE tipo = v_tipo;

  -- exemplares ainda não devolvidos pelo usuário
  SELECT COUNT(*) INTO v_abertos
    FROM item_emprestimo i
    JOIN emprestimo e2 ON e2.id_emprestimo = i.id_emprestimo
   WHERE e2.id_usuario = v_id_usuario
     AND i.data_devolucao_efetiva IS NULL;

  IF v_abertos >= v_max THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Limite de livros emprestados atingido para este tipo de usuário';
  END IF;

  -- exemplar não pode estar emprestado
  IF EXISTS (SELECT 1 FROM item_emprestimo
              WHERE isbn = NEW.isbn
                AND numero_exemplar = NEW.numero_exemplar
                AND data_devolucao_efetiva IS NULL) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Este exemplar já está emprestado e ainda não foi devolvido';
  END IF;

  -- prazo conforme o tipo de usuário
  SET NEW.data_prevista_devolucao = DATE_ADD(v_data_emp, INTERVAL v_prazo DAY);
  SET NEW.data_devolucao_efetiva  = NULL;
  SET NEW.valor_multa             = NULL;
END$$

-- ITEM_EMPRESTIMO: ao devolver, calcula a multa por dia de atraso
CREATE TRIGGER trg_item_emprestimo_bu BEFORE UPDATE ON item_emprestimo
FOR EACH ROW
BEGIN
  DECLARE v_tipo      VARCHAR(20);
  DECLARE v_data_emp  DATE;
  DECLARE v_multa_dia DECIMAL(6, 2);
  DECLARE v_dias      INT;

  IF NEW.data_devolucao_efetiva IS NULL THEN
    SET NEW.valor_multa = NULL;
  ELSE
    SELECT e.data_emprestimo, u.tipo INTO v_data_emp, v_tipo
      FROM emprestimo e
      JOIN usuario u ON u.id_usuario = e.id_usuario
     WHERE e.id_emprestimo = NEW.id_emprestimo;

    IF NEW.data_devolucao_efetiva < v_data_emp THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A data de devolução não pode ser anterior à data do empréstimo';
    END IF;

    SELECT multa_dia INTO v_multa_dia
      FROM tipo_usuario WHERE tipo = v_tipo;

    SET v_dias = GREATEST(DATEDIFF(NEW.data_devolucao_efetiva,
                                   NEW.data_prevista_devolucao), 0);
    SET NEW.valor_multa = v_dias * v_multa_dia;
  END IF;
END$$

-- PROCEDURES (regras de negócio usadas pela aplicação)

-- Insere telefones separados por vírgula
CREATE PROCEDURE sp_inserir_telefones(IN p_id_usuario INT UNSIGNED,
                                      IN p_lista VARCHAR(500))
BEGIN
  DECLARE v_resto VARCHAR(500);
  DECLARE v_tel   VARCHAR(20);

  SET v_resto = TRIM(COALESCE(p_lista, ''));
  WHILE CHAR_LENGTH(v_resto) > 0 DO
    SET v_tel = TRIM(SUBSTRING_INDEX(v_resto, ',', 1));
    IF CHAR_LENGTH(v_tel) > 0 THEN
      INSERT IGNORE INTO telefone_usuario (id_usuario, numero)
      VALUES (p_id_usuario, v_tel);
    END IF;
    IF LOCATE(',', v_resto) = 0 THEN
      SET v_resto = '';
    ELSE
      SET v_resto = TRIM(SUBSTRING(v_resto, LOCATE(',', v_resto) + 1));
    END IF;
  END WHILE;
END$$

-- Cadastros de usuário (cada um em uma transação)
CREATE PROCEDURE sp_cadastrar_aluno(
  IN  p_matricula INT UNSIGNED,
  IN  p_nome VARCHAR(120),
  IN  p_cod_curso INT UNSIGNED,
  IN  p_endereco VARCHAR(255),
  IN  p_telefones VARCHAR(500),
  IN  p_data_ingresso DATE,
  IN  p_data_conclusao_prevista DATE,
  OUT p_id_usuario INT UNSIGNED)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;
  INSERT INTO usuario (tipo, nome, endereco)
  VALUES ('ALUNO', p_nome, p_endereco);
  SET p_id_usuario = LAST_INSERT_ID();

  INSERT INTO aluno (id_usuario, matricula, cod_curso, data_ingresso,
                     data_conclusao_prevista)
  VALUES (p_id_usuario, p_matricula, p_cod_curso, p_data_ingresso,
          p_data_conclusao_prevista);

  CALL sp_inserir_telefones(p_id_usuario, p_telefones);
  COMMIT;
END$$

CREATE PROCEDURE sp_cadastrar_professor(
  IN  p_mat_siape INT UNSIGNED,
  IN  p_nome VARCHAR(120),
  IN  p_cod_curso INT UNSIGNED,
  IN  p_endereco VARCHAR(255),
  IN  p_telefones VARCHAR(500),
  IN  p_regime_trabalho VARCHAR(5),
  IN  p_data_contratacao DATE,
  OUT p_id_usuario INT UNSIGNED)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  IF p_regime_trabalho IS NULL OR p_regime_trabalho NOT IN ('20h', '40h', 'DE') THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Regime de trabalho inválido (use 20h, 40h ou DE)';
  END IF;

  START TRANSACTION;
  INSERT INTO usuario (tipo, nome, endereco)
  VALUES ('PROFESSOR', p_nome, p_endereco);
  SET p_id_usuario = LAST_INSERT_ID();

  INSERT INTO professor (id_usuario, mat_siape, cod_curso, regime_trabalho,
                         data_contratacao)
  VALUES (p_id_usuario, p_mat_siape, p_cod_curso, p_regime_trabalho,
          p_data_contratacao);

  CALL sp_inserir_telefones(p_id_usuario, p_telefones);
  COMMIT;
END$$

CREATE PROCEDURE sp_cadastrar_funcionario(
  IN  p_matricula INT UNSIGNED,
  IN  p_nome VARCHAR(120),
  IN  p_endereco VARCHAR(255),
  IN  p_telefones VARCHAR(500),
  OUT p_id_usuario INT UNSIGNED)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;
  INSERT INTO usuario (tipo, nome, endereco)
  VALUES ('FUNCIONARIO', p_nome, p_endereco);
  SET p_id_usuario = LAST_INSERT_ID();

  INSERT INTO funcionario (id_usuario, matricula)
  VALUES (p_id_usuario, p_matricula);

  CALL sp_inserir_telefones(p_id_usuario, p_telefones);
  COMMIT;
END$$

-- Cancelamento de cadastro (bloqueia reservas e empréstimos)
CREATE PROCEDURE sp_cancelar_cadastro(IN p_id_usuario INT UNSIGNED)
BEGIN
  DECLARE v_situacao VARCHAR(20);
  SELECT situacao INTO v_situacao FROM usuario WHERE id_usuario = p_id_usuario;

  IF v_situacao IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Usuário não encontrado';
  ELSEIF v_situacao = 'CANCELADO' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O cadastro deste usuário já está cancelado';
  END IF;

  UPDATE usuario SET situacao = 'CANCELADO' WHERE id_usuario = p_id_usuario;
END$$

-- Localiza o usuário pela matrícula (aluno, funcionário) ou SIAPE (professor)
CREATE PROCEDURE sp_identificar_usuario(IN p_matricula INT UNSIGNED)
BEGIN
  SELECT u.id_usuario, u.tipo, u.nome, u.situacao
    FROM usuario u JOIN aluno a ON a.id_usuario = u.id_usuario
   WHERE a.matricula = p_matricula
  UNION ALL
  SELECT u.id_usuario, u.tipo, u.nome, u.situacao
    FROM usuario u JOIN professor p ON p.id_usuario = u.id_usuario
   WHERE p.mat_siape = p_matricula
  UNION ALL
  SELECT u.id_usuario, u.tipo, u.nome, u.situacao
    FROM usuario u JOIN funcionario f ON f.id_usuario = u.id_usuario
   WHERE f.matricula = p_matricula;
END$$

-- Reserva on-line (usada pelo nível "usuário")
CREATE PROCEDURE sp_reservar_livro(IN p_id_usuario INT UNSIGNED,
                                   IN p_isbn VARCHAR(17))
BEGIN
  INSERT INTO reserva (id_usuario, isbn, data_reserva)
  VALUES (p_id_usuario, p_isbn, NOW());
END$$

-- Devolve um exemplar e exibe a multa, se houver atraso
CREATE PROCEDURE sp_devolver_exemplar(IN p_id_emprestimo INT UNSIGNED,
                                      IN p_isbn VARCHAR(17),
                                      IN p_numero_exemplar INT UNSIGNED,
                                      IN p_data_devolucao DATE)
BEGIN
  DECLARE v_efetiva DATE;
  DECLARE v_data    DATE;

  SELECT data_devolucao_efetiva INTO v_efetiva
    FROM item_emprestimo
   WHERE id_emprestimo = p_id_emprestimo AND isbn = p_isbn
     AND numero_exemplar = p_numero_exemplar;

  IF NOT EXISTS (SELECT 1 FROM item_emprestimo
                  WHERE id_emprestimo = p_id_emprestimo AND isbn = p_isbn
                    AND numero_exemplar = p_numero_exemplar) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Exemplar não encontrado neste empréstimo';
  END IF;
  IF v_efetiva IS NOT NULL THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Este exemplar já foi devolvido';
  END IF;

  SET v_data = COALESCE(p_data_devolucao, CURDATE());

  UPDATE item_emprestimo
     SET data_devolucao_efetiva = v_data
   WHERE id_emprestimo = p_id_emprestimo AND isbn = p_isbn
     AND numero_exemplar = p_numero_exemplar;

  SELECT i.isbn,
         l.titulo,
         i.numero_exemplar,
         i.data_prevista_devolucao,
         i.data_devolucao_efetiva,
         GREATEST(DATEDIFF(i.data_devolucao_efetiva,
                           i.data_prevista_devolucao), 0) AS dias_atraso,
         i.valor_multa,
         IF(i.valor_multa > 0,
            CONCAT('Devolução FORA do prazo. Multa a pagar: R$ ',
                   FORMAT(i.valor_multa, 2)),
            'Devolução dentro do prazo. Sem multa.') AS mensagem
    FROM item_emprestimo i
    JOIN livro l ON l.isbn = i.isbn
   WHERE i.id_emprestimo = p_id_emprestimo AND i.isbn = p_isbn
     AND i.numero_exemplar = p_numero_exemplar;
END$$

-- Empréstimos de um usuário (para o nível "usuário" consultar os seus)
CREATE PROCEDURE sp_consultar_emprestimos_usuario(IN p_id_usuario INT UNSIGNED)
BEGIN
  SELECT e.id_emprestimo, e.data_emprestimo, l.titulo, i.isbn,
         i.numero_exemplar, i.data_prevista_devolucao,
         i.data_devolucao_efetiva, i.valor_multa,
         CASE
           WHEN i.data_devolucao_efetiva IS NOT NULL THEN 'DEVOLVIDO'
           WHEN i.data_prevista_devolucao < CURDATE() THEN 'ATRASADO'
           ELSE 'EM ANDAMENTO'
         END AS situacao
    FROM emprestimo e
    JOIN item_emprestimo i ON i.id_emprestimo = e.id_emprestimo
    JOIN livro l ON l.isbn = i.isbn
   WHERE e.id_usuario = p_id_usuario
   ORDER BY e.data_emprestimo DESC, l.titulo;
END$$

DELIMITER ;

-- VISÕES (filtrar com WHERE, ex.: WHERE categoria = 'Computação')

-- Catálogo com disponibilidade (consulta do usuário)
CREATE VIEW vw_catalogo_livros AS
SELECT l.isbn,
       l.titulo,
       l.ano_lancamento,
       l.editora,
       c.descricao AS categoria,
       s.descricao AS subcategoria,
       GROUP_CONCAT(a.nome ORDER BY la.autor_principal DESC, a.nome
                    SEPARATOR '; ') AS autores,
       l.qtd_exemplares,
       l.qtd_exemplares - (SELECT COUNT(*)
                             FROM item_emprestimo i
                            WHERE i.isbn = l.isbn
                              AND i.data_devolucao_efetiva IS NULL)
         AS exemplares_disponiveis
  FROM livro l
  JOIN categoria c    ON c.cod_categoria = l.cod_categoria
  JOIN subcategoria s ON s.cod_subcategoria = l.cod_subcategoria
  LEFT JOIN livro_autor la ON la.isbn = l.isbn
  LEFT JOIN autor a        ON a.cod_autor = la.cod_autor
 GROUP BY l.isbn, l.titulo, l.ano_lancamento, l.editora, c.descricao,
          s.descricao, l.qtd_exemplares
 ORDER BY l.titulo;

-- Livro (qtd_exemplares é mantida por triggers)
CREATE VIEW vw_livros_por_categoria AS
SELECT c.descricao AS categoria,
       s.descricao AS subcategoria,
       l.isbn,
       l.titulo,
       l.ano_lancamento,
       l.editora,
       GROUP_CONCAT(a.nome ORDER BY la.autor_principal DESC, a.nome
                    SEPARATOR '; ') AS autores,
       l.qtd_exemplares
  FROM livro l
  JOIN categoria c    ON c.cod_categoria = l.cod_categoria
  JOIN subcategoria s ON s.cod_subcategoria = l.cod_subcategoria
  LEFT JOIN livro_autor la ON la.isbn = l.isbn
  LEFT JOIN autor a        ON a.cod_autor = la.cod_autor
 GROUP BY c.cod_categoria, c.descricao, s.cod_subcategoria, s.descricao,
          l.isbn, l.titulo, l.ano_lancamento, l.editora, l.qtd_exemplares
 ORDER BY c.descricao, s.descricao, l.titulo;

-- Livro (qtd_exemplares é mantida por triggers)
CREATE VIEW vw_livros_por_subcategoria AS
SELECT s.descricao AS subcategoria,
       c.descricao AS categoria,
       l.isbn,
       l.titulo,
       l.ano_lancamento,
       l.editora,
       GROUP_CONCAT(a.nome ORDER BY la.autor_principal DESC, a.nome
                    SEPARATOR '; ') AS autores,
       l.qtd_exemplares
  FROM livro l
  JOIN categoria c    ON c.cod_categoria = l.cod_categoria
  JOIN subcategoria s ON s.cod_subcategoria = l.cod_subcategoria
  LEFT JOIN livro_autor la ON la.isbn = l.isbn
  LEFT JOIN autor a        ON a.cod_autor = la.cod_autor
 GROUP BY s.cod_subcategoria, s.descricao, c.descricao, l.isbn, l.titulo,
          l.ano_lancamento, l.editora, l.qtd_exemplares
 ORDER BY s.descricao, l.titulo;

-- Livro (qtd_exemplares é mantida por triggers)
CREATE VIEW vw_livros_por_editora AS
SELECT l.editora,
       l.isbn,
       l.titulo,
       l.ano_lancamento,
       c.descricao AS categoria,
       s.descricao AS subcategoria,
       GROUP_CONCAT(a.nome ORDER BY la.autor_principal DESC, a.nome
                    SEPARATOR '; ') AS autores,
       l.qtd_exemplares
  FROM livro l
  JOIN categoria c    ON c.cod_categoria = l.cod_categoria
  JOIN subcategoria s ON s.cod_subcategoria = l.cod_subcategoria
  LEFT JOIN livro_autor la ON la.isbn = l.isbn
  LEFT JOIN autor a        ON a.cod_autor = la.cod_autor
 GROUP BY l.editora, l.isbn, l.titulo, l.ano_lancamento, c.descricao,
          s.descricao, l.qtd_exemplares
 ORDER BY l.editora, l.titulo;

-- Livro (qtd_exemplares é mantida por triggers)
CREATE VIEW vw_livros_por_ano AS
SELECT l.ano_lancamento,
       l.isbn,
       l.titulo,
       l.editora,
       c.descricao AS categoria,
       s.descricao AS subcategoria,
       GROUP_CONCAT(a.nome ORDER BY la.autor_principal DESC, a.nome
                    SEPARATOR '; ') AS autores,
       l.qtd_exemplares
  FROM livro l
  JOIN categoria c    ON c.cod_categoria = l.cod_categoria
  JOIN subcategoria s ON s.cod_subcategoria = l.cod_subcategoria
  LEFT JOIN livro_autor la ON la.isbn = l.isbn
  LEFT JOIN autor a        ON a.cod_autor = la.cod_autor
 GROUP BY l.ano_lancamento, l.isbn, l.titulo, l.editora, c.descricao,
          s.descricao, l.qtd_exemplares
 ORDER BY l.ano_lancamento, l.titulo;

-- Livro (qtd_exemplares é mantida por triggers)
CREATE VIEW vw_livros_por_autor AS
SELECT a.nome AS autor,
       a.nacionalidade,
       IF(MAX(la.autor_principal) = 1, 'Autor principal', 'Coautor') AS papel,
       l.isbn,
       l.titulo,
       l.ano_lancamento,
       l.editora,
       c.descricao AS categoria,
       s.descricao AS subcategoria,
       l.qtd_exemplares
  FROM autor a
  JOIN livro_autor la ON la.cod_autor = a.cod_autor
  JOIN livro l        ON l.isbn = la.isbn
  JOIN categoria c    ON c.cod_categoria = l.cod_categoria
  JOIN subcategoria s ON s.cod_subcategoria = l.cod_subcategoria
 GROUP BY a.cod_autor, a.nome, a.nacionalidade, l.isbn, l.titulo,
          l.ano_lancamento, l.editora, c.descricao, s.descricao,
          l.qtd_exemplares
 ORDER BY a.nome, l.titulo;

-- Professores por curso
CREATE VIEW vw_professores_por_curso AS
SELECT cu.nome_curso AS curso,
       u.nome        AS professor,
       p.mat_siape,
       p.regime_trabalho,
       p.data_contratacao,
       u.situacao,
       GROUP_CONCAT(t.numero ORDER BY t.numero SEPARATOR ', ') AS telefones
  FROM professor p
  JOIN usuario u ON u.id_usuario = p.id_usuario
  JOIN curso cu  ON cu.cod_curso = p.cod_curso
  LEFT JOIN telefone_usuario t ON t.id_usuario = p.id_usuario
 GROUP BY cu.cod_curso, cu.nome_curso, p.id_usuario, u.nome, p.mat_siape,
          p.regime_trabalho, p.data_contratacao, u.situacao
 ORDER BY cu.nome_curso, u.nome;

-- Reservas por livro (filtrar por isbn ou titulo)
CREATE VIEW vw_reservas_por_livro AS
SELECT l.titulo,
       l.isbn,
       r.data_reserva,
       u.nome AS usuario,
       u.tipo AS tipo_usuario,
       GROUP_CONCAT(t.numero ORDER BY t.numero SEPARATOR ', ') AS telefones
  FROM reserva r
  JOIN livro l   ON l.isbn = r.isbn
  JOIN usuario u ON u.id_usuario = r.id_usuario
  LEFT JOIN telefone_usuario t ON t.id_usuario = u.id_usuario
 GROUP BY l.isbn, l.titulo, r.id_usuario, r.data_reserva, u.nome, u.tipo
 ORDER BY l.titulo, r.data_reserva;

-- NÍVEIS DE ACESSO: Admin/Root, bibliotecario/Biblioteca, usuario/Usuario
DROP USER IF EXISTS 'Admin'@'%';
DROP USER IF EXISTS 'bibliotecario'@'%';
DROP USER IF EXISTS 'usuario'@'%';

CREATE USER 'Admin'@'%'         IDENTIFIED WITH mysql_native_password BY 'Root';
CREATE USER 'bibliotecario'@'%' IDENTIFIED WITH mysql_native_password BY 'Biblioteca';
CREATE USER 'usuario'@'%'       IDENTIFIED WITH mysql_native_password BY 'Usuario';

-- Administrador: tudo no banco da biblioteca
GRANT ALL PRIVILEGES ON equipe535946.* TO 'Admin'@'%';

-- Bibliotecário: consulta tudo; realiza, altera e dá baixa em empréstimos
GRANT SELECT ON equipe535946.* TO 'bibliotecario'@'%';
GRANT INSERT, UPDATE ON equipe535946.emprestimo TO 'bibliotecario'@'%';
GRANT INSERT, UPDATE ON equipe535946.item_emprestimo TO 'bibliotecario'@'%';
GRANT EXECUTE ON PROCEDURE equipe535946.sp_devolver_exemplar TO 'bibliotecario'@'%';
GRANT EXECUTE ON PROCEDURE equipe535946.sp_identificar_usuario TO 'bibliotecario'@'%';
GRANT EXECUTE ON PROCEDURE equipe535946.sp_consultar_emprestimos_usuario TO 'bibliotecario'@'%';

-- Usuário: só consulta o acervo (visões), reserva on-line e se cadastra/cancela
GRANT SELECT ON equipe535946.vw_catalogo_livros TO 'usuario'@'%';
GRANT SELECT ON equipe535946.curso TO 'usuario'@'%';
GRANT EXECUTE ON PROCEDURE equipe535946.sp_reservar_livro TO 'usuario'@'%';
GRANT EXECUTE ON PROCEDURE equipe535946.sp_identificar_usuario TO 'usuario'@'%';
GRANT EXECUTE ON PROCEDURE equipe535946.sp_consultar_emprestimos_usuario TO 'usuario'@'%';
GRANT EXECUTE ON PROCEDURE equipe535946.sp_cadastrar_aluno TO 'usuario'@'%';
GRANT EXECUTE ON PROCEDURE equipe535946.sp_cadastrar_professor TO 'usuario'@'%';
GRANT EXECUTE ON PROCEDURE equipe535946.sp_cadastrar_funcionario TO 'usuario'@'%';
GRANT EXECUTE ON PROCEDURE equipe535946.sp_cancelar_cadastro TO 'usuario'@'%';

FLUSH PRIVILEGES;
