-- Trabalho Final - BD 2026.2 - Biblioteca acadêmica
-- Equipe 535946: Giovanna dos Santos Marques (536930),
--                Iarley Cavalcante Tavares Balreira (535946),
--                Pedro Eric Carneiro (538121)
-- Script 02: povoamento (executar após o 01_criacao.sql)
SET NAMES utf8mb4;
USE equipe535946;

-- Cursos
INSERT INTO curso (cod_curso, nome_curso) VALUES
  (1, 'Engenharia da Computação'),
  (2, 'Engenharia Elétrica'),
  (3, 'Engenharia Civil'),
  (4, 'Ciências Econômicas'),
  (5, 'Música');

-- Categorias e subcategorias
INSERT INTO categoria (cod_categoria, descricao) VALUES
  (1, 'Computação'),
  (2, 'Engenharia'),
  (3, 'Matemática'),
  (4, 'Literatura'),
  (5, 'Economia');

INSERT INTO subcategoria (cod_subcategoria, cod_categoria, descricao) VALUES
  (1,  1, 'Banco de Dados'),
  (2,  1, 'Engenharia de Software'),
  (3,  1, 'Redes de Computadores'),
  (4,  1, 'Algoritmos e Estruturas de Dados'),
  (5,  2, 'Circuitos Elétricos'),
  (6,  2, 'Estruturas'),
  (7,  3, 'Cálculo'),
  (8,  3, 'Álgebra Linear'),
  (9,  4, 'Romance'),
  (10, 4, 'Poesia'),
  (11, 5, 'Microeconomia'),
  (12, 5, 'Macroeconomia');

-- Autores
INSERT INTO autor (cod_autor, nome, email, nacionalidade) VALUES
  (1,  'Ramez Elmasri',           'ramez.elmasri@exemplo.com',     'Estados Unidos'),
  (2,  'Shamkant B. Navathe',     'snavathe@exemplo.com',          'Índia'),
  (3,  'Abraham Silberschatz',    'silberschatz@exemplo.com',      'Estados Unidos'),
  (4,  'Henry F. Korth',          'henry.korth@exemplo.com',       'Estados Unidos'),
  (5,  'S. Sudarshan',            's.sudarshan@exemplo.com',       'Índia'),
  (6,  'Ian Sommerville',         'ian.sommerville@exemplo.com',   'Reino Unido'),
  (7,  'Andrew S. Tanenbaum',     'a.tanenbaum@exemplo.com',       'Estados Unidos'),
  (8,  'Thomas H. Cormen',        'thomas.cormen@exemplo.com',     'Estados Unidos'),
  (9,  'James Stewart',           'james.stewart@exemplo.com',     'Canadá'),
  (10, 'Machado de Assis',        'machado@exemplo.com',           'Brasil'),
  (11, 'Carlos Drummond de Andrade', 'drummond@exemplo.com',       'Brasil'),
  (12, 'N. Gregory Mankiw',       'greg.mankiw@exemplo.com',       'Estados Unidos'),
  (13, 'David Poole',             'david.poole@exemplo.com',       'Estados Unidos'),
  (14, 'Charles K. Alexander',    'c.alexander@exemplo.com',       'Estados Unidos');

-- Livros
INSERT INTO livro (isbn, titulo, ano_lancamento, editora, cod_categoria, cod_subcategoria) VALUES
  ('978-85-4301-381-7', 'Sistemas de Banco de Dados', 2019, 'Pearson', 1, 1),
  ('978-85-352-4535-6', 'Sistema de Banco de Dados', 2020, 'Elsevier', 1, 1),
  ('978-85-8260-406-8', 'Engenharia de Software', 2018, 'Pearson', 1, 2),
  ('978-85-4301-393-0', 'Redes de Computadores', 2021, 'Pearson', 1, 3),
  ('978-85-352-3699-6', 'Algoritmos: Teoria e Prática', 2012, 'Elsevier', 1, 4),
  ('978-85-221-2587-3', 'Cálculo - Volume 1', 2016, 'Cengage', 3, 7),
  ('978-85-221-2588-0', 'Cálculo - Volume 2', 2016, 'Cengage', 3, 7),
  ('978-85-221-2146-2', 'Álgebra Linear com Aplicações', 2017, 'Cengage', 3, 8),
  ('978-85-8055-308-0', 'Fundamentos de Circuitos Elétricos', 2013, 'AMGH', 2, 5),
  ('978-85-359-0277-5', 'Dom Casmurro', 1899, 'Companhia das Letras', 4, 9),
  ('978-85-359-1096-1', 'Memórias Póstumas de Brás Cubas', 1881, 'Companhia das Letras', 4, 9),
  ('978-85-359-0823-4', 'A Rosa do Povo', 1945, 'Companhia das Letras', 4, 10),
  ('978-85-221-1230-9', 'Introdução à Economia', 2015, 'Cengage', 5, 11),
  ('978-85-352-5555-3', 'Princípios de Macroeconomia', 2014, 'Elsevier', 5, 12);

-- Exemplares (o número sequencial e a quantidade do livro são calculados por trigger)
INSERT INTO exemplar (isbn) VALUES
  ('978-85-4301-381-7'),
  ('978-85-4301-381-7'),
  ('978-85-4301-381-7'),
  ('978-85-4301-381-7'),
  ('978-85-352-4535-6'),
  ('978-85-352-4535-6'),
  ('978-85-352-4535-6'),
  ('978-85-8260-406-8'),
  ('978-85-8260-406-8'),
  ('978-85-8260-406-8'),
  ('978-85-4301-393-0'),
  ('978-85-4301-393-0'),
  ('978-85-352-3699-6'),
  ('978-85-352-3699-6'),
  ('978-85-352-3699-6'),
  ('978-85-221-2587-3'),
  ('978-85-221-2587-3'),
  ('978-85-221-2587-3'),
  ('978-85-221-2587-3'),
  ('978-85-221-2587-3'),
  ('978-85-221-2588-0'),
  ('978-85-221-2588-0'),
  ('978-85-221-2146-2'),
  ('978-85-221-2146-2'),
  ('978-85-8055-308-0'),
  ('978-85-8055-308-0'),
  ('978-85-8055-308-0'),
  ('978-85-8055-308-0'),
  ('978-85-359-0277-5'),
  ('978-85-359-0277-5'),
  ('978-85-359-0277-5'),
  ('978-85-359-1096-1'),
  ('978-85-359-1096-1'),
  ('978-85-359-0823-4'),
  ('978-85-221-1230-9'),
  ('978-85-221-1230-9'),
  ('978-85-221-1230-9');

-- Livro x autor
INSERT INTO livro_autor (isbn, cod_autor, autor_principal) VALUES
  ('978-85-4301-381-7', 1, 1), ('978-85-4301-381-7', 2, 0),
  ('978-85-352-4535-6', 3, 1), ('978-85-352-4535-6', 4, 0), ('978-85-352-4535-6', 5, 0),
  ('978-85-8260-406-8', 6, 1),
  ('978-85-4301-393-0', 7, 1),
  ('978-85-352-3699-6', 8, 1),
  ('978-85-221-2587-3', 9, 1),
  ('978-85-221-2588-0', 9, 1),
  ('978-85-221-2146-2', 13, 1),
  ('978-85-8055-308-0', 14, 1),
  ('978-85-359-0277-5', 10, 1),
  ('978-85-359-1096-1', 10, 1),
  ('978-85-359-0823-4', 11, 1),
  ('978-85-221-1230-9', 12, 1),
  ('978-85-352-5555-3', 12, 1);

-- Usuários
-- Alunos (a data de conclusão precisa ser futura)
CALL sp_cadastrar_aluno(400101, 'Ana Beatriz Lima',    1, 'Rua Coronel Mont''Alverne, 120 - Sobral/CE', '(88) 99911-0001, (88) 3611-0001', '2024-02-01', '2028-12-20', @id);
CALL sp_cadastrar_aluno(400102, 'Bruno Carvalho Sousa', 1, 'Av. Dr. Guarani, 450 - Sobral/CE',          '(88) 99911-0002',                '2023-08-01', '2027-12-20', @id);
CALL sp_cadastrar_aluno(400103, 'Camila Rocha Mendes',  2, 'Rua Antônio Crisóstomo, 33 - Sobral/CE',   '(88) 99911-0003, (88) 99911-1003, (88) 3611-0003', '2025-02-01', '2029-12-20', @id);
CALL sp_cadastrar_aluno(400104, 'Diego Ferreira Alves', 3, 'Rua Oswaldo Cruz, 78 - Sobral/CE',          '(88) 99911-0004',                '2022-02-01', '2026-12-18', @id);
CALL sp_cadastrar_aluno(400105, 'Elisa Nogueira Pinto', 4, 'Rua Domingos Olímpio, 910 - Sobral/CE',     '(88) 99911-0005',                '2024-08-01', '2028-06-30', @id);
CALL sp_cadastrar_aluno(400106, 'Fábio Gomes Teixeira', 1, 'Rua Senador Pompeu, 15 - Sobral/CE',        '(88) 99911-0006',                '2025-08-01', '2029-06-30', @id);

-- Professores
CALL sp_cadastrar_professor(1234567, 'Prof. Fernando Rodrigues',  1, 'Av. John Sanford, 200 - Sobral/CE', '(88) 98811-0001',                  'DE',  '2015-03-10', @id);
CALL sp_cadastrar_professor(1234568, 'Profa. Helena Martins',     1, 'Rua Viriato de Medeiros, 55 - Sobral/CE', '(88) 98811-0002, (88) 3677-0002', '40h', '2018-07-01', @id);
CALL sp_cadastrar_professor(1234569, 'Prof. Ivan Pereira Costa',  2, 'Rua Cel. Diogo Gomes, 301 - Sobral/CE', '(88) 98811-0003',               '20h', '2020-02-15', @id);
CALL sp_cadastrar_professor(1234570, 'Profa. Júlia Albuquerque',  3, 'Av. Padre Ibiapina, 700 - Sobral/CE', '(88) 98811-0004',                 'DE',  '2012-09-03', @id);

-- Funcionários
CALL sp_cadastrar_funcionario(900001, 'Karina Duarte Silva',  'Rua Coronel Joaquim Ribeiro, 12 - Sobral/CE', '(88) 97711-0001, (88) 3611-9001', @id);
CALL sp_cadastrar_funcionario(900002, 'Leandro Matos Rebouças', 'Rua José Euclides, 64 - Sobral/CE',          '(88) 97711-0002', @id);
CALL sp_cadastrar_funcionario(900003, 'Márcia Soares Lopes',  'Rua Maestro José Sabóia, 7 - Sobral/CE',       '(88) 97711-0003', @id);

-- Reservas (usuário x livro x data)
INSERT INTO reserva (id_usuario, isbn, data_reserva) VALUES
  (1,  '978-85-4301-381-7', '2026-11-10 09:15:00'),
  (2,  '978-85-4301-381-7', '2026-11-11 14:40:00'),
  (7,  '978-85-4301-381-7', '2026-11-12 08:05:00'),
  (3,  '978-85-8055-308-0', '2026-11-09 16:20:00'),
  (11, '978-85-359-0277-5', '2026-11-13 10:00:00'),
  (5,  '978-85-221-1230-9', '2026-11-14 11:30:00'),
  (1,  '978-85-221-2587-3', '2026-11-15 17:45:00');

-- Empréstimos

-- (1) Ana: um devolvido no prazo e outro com 5 dias de atraso (R$ 5,00)
INSERT INTO emprestimo (id_emprestimo, id_usuario, data_emprestimo) VALUES (1, 1, '2026-08-03');
INSERT INTO item_emprestimo (id_emprestimo, isbn, numero_exemplar) VALUES
  (1, '978-85-352-3699-6', 1),
  (1, '978-85-221-2587-3', 1);
UPDATE item_emprestimo SET data_devolucao_efetiva = '2026-08-15'
 WHERE id_emprestimo = 1 AND isbn = '978-85-352-3699-6' AND numero_exemplar = 1;
UPDATE item_emprestimo SET data_devolucao_efetiva = '2026-08-23'
 WHERE id_emprestimo = 1 AND isbn = '978-85-221-2587-3' AND numero_exemplar = 1;

-- (2) Fernando: 3 dias de atraso (R$ 6,00)
INSERT INTO emprestimo (id_emprestimo, id_usuario, data_emprestimo) VALUES (2, 7, '2026-09-01');
INSERT INTO item_emprestimo (id_emprestimo, isbn, numero_exemplar) VALUES
  (2, '978-85-352-4535-6', 1);
UPDATE item_emprestimo SET data_devolucao_efetiva = '2026-10-04'
 WHERE id_emprestimo = 2;

-- (3) Karina: 2 dias de atraso (R$ 3,00)
INSERT INTO emprestimo (id_emprestimo, id_usuario, data_emprestimo) VALUES (3, 11, '2026-09-10');
INSERT INTO item_emprestimo (id_emprestimo, isbn, numero_exemplar) VALUES
  (3, '978-85-359-0277-5', 1);
UPDATE item_emprestimo SET data_devolucao_efetiva = '2026-10-03'
 WHERE id_emprestimo = 3;

-- (4) Bruno: em aberto e atrasado
INSERT INTO emprestimo (id_emprestimo, id_usuario, data_emprestimo) VALUES (4, 2, '2026-10-20');
INSERT INTO item_emprestimo (id_emprestimo, isbn, numero_exemplar) VALUES
  (4, '978-85-4301-381-7', 1),
  (4, '978-85-8260-406-8', 1);

-- (5) Camila: 3 livros em aberto (limite de aluno)
INSERT INTO emprestimo (id_emprestimo, id_usuario, data_emprestimo) VALUES (5, 3, '2026-11-10');
INSERT INTO item_emprestimo (id_emprestimo, isbn, numero_exemplar) VALUES
  (5, '978-85-8055-308-0', 1),
  (5, '978-85-8055-308-0', 2),
  (5, '978-85-221-2146-2', 1);

-- (6) Helena: em aberto, devolve um dos livros
INSERT INTO emprestimo (id_emprestimo, id_usuario, data_emprestimo) VALUES (6, 8, '2026-11-02');
INSERT INTO item_emprestimo (id_emprestimo, isbn, numero_exemplar) VALUES
  (6, '978-85-352-4535-6', 2),
  (6, '978-85-4301-393-0', 1),
  (6, '978-85-359-1096-1', 1);
UPDATE item_emprestimo SET data_devolucao_efetiva = '2026-11-12'
 WHERE id_emprestimo = 6 AND isbn = '978-85-4301-393-0' AND numero_exemplar = 1;

-- (7) Leandro: em aberto
INSERT INTO emprestimo (id_emprestimo, id_usuario, data_emprestimo) VALUES (7, 12, '2026-11-05');
INSERT INTO item_emprestimo (id_emprestimo, isbn, numero_exemplar) VALUES
  (7, '978-85-221-1230-9', 1);

-- Usuário com cadastro cancelado
CALL sp_cancelar_cadastro(13);
