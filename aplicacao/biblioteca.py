# Sistema de biblioteca acadêmica - Trabalho Final BD 2026.2 - Equipe 535946
# Giovanna dos Santos Marques (536930), Iarley Cavalcante Tavares Balreira (535946),
# Pedro Eric Carneiro (538121)

import getpass
import mysql.connector

HOST = "localhost"
BANCO = "equipe535946"

# nome da listagem, visão, filtro (WHERE) e quantidade de parâmetros do filtro
RELATORIOS = [
    ("Livros por categoria", "vw_livros_por_categoria", "categoria LIKE %s", 1),
    ("Livros por subcategoria", "vw_livros_por_subcategoria", "subcategoria LIKE %s", 1),
    ("Livros por editora", "vw_livros_por_editora", "editora LIKE %s", 1),
    ("Livros por ano", "vw_livros_por_ano", "ano_lancamento LIKE %s", 1),
    ("Livros por autor", "vw_livros_por_autor", "autor LIKE %s", 1),
    ("Professores por curso", "vw_professores_por_curso", "curso LIKE %s", 1),
    ("Reservas por livro (nome ou ISBN)", "vw_reservas_por_livro", "(titulo LIKE %s OR isbn LIKE %s)", 2),
]


def mostrar(cur):
    # imprime o resultado de uma consulta
    linhas = cur.fetchall()
    if not linhas:
        print("Nenhum registro encontrado.")
        return
    titulos = []
    for coluna in cur.description:
        titulos.append(coluna[0])
    print(" | ".join(titulos))
    for linha in linhas:
        valores = []
        for valor in linha:
            if valor is None:
                valores.append("")
            else:
                valores.append(str(valor))
        print(" | ".join(valores))


def consultar(cur, sql, parametros=()):
    # executa um SELECT e mostra o resultado
    cur.execute(sql, parametros)
    mostrar(cur)


def chamar(cur, nome, argumentos):
    # chama uma procedure e mostra o que ela retornar
    marcadores = ", ".join(["%s"] * len(argumentos))
    cur.execute("CALL " + nome + "(" + marcadores + ")", argumentos)
    while True:
        if cur.description is not None:
            mostrar(cur)
        if not cur.nextset():
            break


def identificar(cur):
    # pede a matrícula e devolve o código do usuário
    matricula = input("Matrícula (SIAPE para professor): ").strip()
    cur.execute("CALL sp_identificar_usuario(%s)", (matricula,))
    pessoas = cur.fetchall()
    while cur.nextset():
        pass
    if not pessoas:
        print("Usuário não encontrado.")
        return None
    print("Usuário:", pessoas[0][2], "-", pessoas[0][1], "-", pessoas[0][3])
    return pessoas[0][0]


def consultar_livros(cur):
    # busca livros por nome, autor, editora, categoria e ano
    filtros = [("titulo", "Nome"), ("autores", "Autor"), ("editora", "Editora"),
               ("categoria", "Categoria"), ("ano_lancamento", "Ano")]
    condicoes = []
    parametros = []
    for coluna, rotulo in filtros:
        texto = input(rotulo + " (Enter para ignorar): ").strip()
        if texto != "":
            condicoes.append(coluna + " LIKE %s")
            parametros.append("%" + texto + "%")
    sql = ("SELECT isbn, titulo, autores, editora, categoria, ano_lancamento, "
           "qtd_exemplares, exemplares_disponiveis FROM vw_catalogo_livros")
    if condicoes:
        sql = sql + " WHERE " + " AND ".join(condicoes)
    consultar(cur, sql, parametros)


def relatorios(cur):
    # listagens feitas com as visões do banco
    for i in range(len(RELATORIOS)):
        print(i + 1, "-", RELATORIOS[i][0])
    escolha = input("Listagem: ").strip()
    if not escolha.isdigit() or not 1 <= int(escolha) <= len(RELATORIOS):
        print("Opção inválida.")
        return
    nome, visao, filtro, quantidade = RELATORIOS[int(escolha) - 1]
    texto = input("Filtro (Enter para listar tudo): ").strip()
    if texto == "":
        consultar(cur, "SELECT * FROM " + visao)
    else:
        consultar(cur, "SELECT * FROM " + visao + " WHERE " + filtro, ["%" + texto + "%"] * quantidade)


def cadastrar_aluno(cur):
    # cadastra um aluno (o banco recusa se a data de conclusão já passou)
    consultar(cur, "SELECT cod_curso, nome_curso FROM curso ORDER BY nome_curso")
    matricula = input("Matrícula: ")
    nome = input("Nome: ")
    curso = input("Código do curso: ")
    endereco = input("Endereço: ")
    telefones = input("Telefones (separados por vírgula): ")
    ingresso = input("Data de ingresso (AAAA-MM-DD): ")
    conclusao = input("Data de conclusão prevista (AAAA-MM-DD): ")
    resultado = cur.callproc("sp_cadastrar_aluno",
                             [matricula, nome, curso, endereco, telefones, ingresso, conclusao, 0])
    print("Aluno cadastrado. Código do usuário:", resultado[-1])


def cadastrar_professor(cur):
    # cadastra um professor
    consultar(cur, "SELECT cod_curso, nome_curso FROM curso ORDER BY nome_curso")
    siape = input("Matrícula SIAPE: ")
    nome = input("Nome: ")
    curso = input("Código do curso: ")
    endereco = input("Endereço: ")
    telefones = input("Telefones (separados por vírgula): ")
    regime = input("Regime de trabalho (20h, 40h ou DE): ")
    contratacao = input("Data de contratação (AAAA-MM-DD): ")
    resultado = cur.callproc("sp_cadastrar_professor",
                             [siape, nome, curso, endereco, telefones, regime, contratacao, 0])
    print("Professor cadastrado. Código do usuário:", resultado[-1])


def cadastrar_funcionario(cur):
    # cadastra um funcionário
    matricula = input("Matrícula: ")
    nome = input("Nome: ")
    endereco = input("Endereço: ")
    telefones = input("Telefones (separados por vírgula): ")
    resultado = cur.callproc("sp_cadastrar_funcionario", [matricula, nome, endereco, telefones, 0])
    print("Funcionário cadastrado. Código do usuário:", resultado[-1])


def escolher_tabela(cur):
    # lista as tabelas do banco e devolve a escolhida
    cur.execute("SHOW FULL TABLES WHERE Table_type = 'BASE TABLE'")
    tabelas = []
    for linha in cur.fetchall():
        tabelas.append(linha[0])
    for i in range(len(tabelas)):
        print(i + 1, "-", tabelas[i])
    escolha = input("Tabela (número): ").strip()
    if escolha.isdigit() and 1 <= int(escolha) <= len(tabelas):
        return tabelas[int(escolha) - 1]
    print("Opção inválida.")
    return None


def nomes_colunas(cur, tabela):
    # devolve os nomes das colunas da tabela
    cur.execute("SHOW COLUMNS FROM " + tabela)
    nomes = []
    for coluna in cur.fetchall():
        nomes.append(coluna[0])
    return nomes


def pedir_chave(cur, tabela):
    # pergunta os valores da chave primária e monta o WHERE
    cur.execute("SHOW COLUMNS FROM " + tabela)
    condicoes = []
    valores = []
    for coluna in cur.fetchall():
        if coluna[3] == "PRI":
            condicoes.append(coluna[0] + " = %s")
            valores.append(input(coluna[0] + ": "))
    return " AND ".join(condicoes), valores


def inserir(cur, tabela):
    # insere um registro (Enter deixa o valor padrão do banco)
    nomes = []
    valores = []
    for coluna in nomes_colunas(cur, tabela):
        texto = input(coluna + " (Enter = padrão): ").strip()
        if texto != "":
            nomes.append(coluna)
            valores.append(texto)
    marcadores = ", ".join(["%s"] * len(nomes))
    cur.execute("INSERT INTO " + tabela + " (" + ", ".join(nomes) + ") VALUES (" + marcadores + ")", valores)
    print("Registro inserido.")


def alterar(cur, tabela):
    # altera uma coluna de um registro
    condicao, valores = pedir_chave(cur, tabela)
    campo = input("Coluna a alterar: ").strip()
    if campo not in nomes_colunas(cur, tabela):
        print("Coluna inexistente.")
        return
    novo = input("Novo valor (vazio = NULL): ").strip()
    if novo == "":
        novo = None
    cur.execute("UPDATE " + tabela + " SET " + campo + " = %s WHERE " + condicao, [novo] + valores)
    print(cur.rowcount, "registro(s) alterado(s).")


def excluir(cur, tabela):
    # exclui um registro
    condicao, valores = pedir_chave(cur, tabela)
    cur.execute("DELETE FROM " + tabela + " WHERE " + condicao, valores)
    print(cur.rowcount, "registro(s) excluído(s).")


def gerenciar_tabela(cur):
    # menu de cadastro (listar, inserir, alterar, excluir) de uma tabela
    tabela = escolher_tabela(cur)
    if tabela is None:
        return
    while True:
        print("\n[" + tabela + "]  1 - Listar  2 - Inserir  3 - Alterar  4 - Excluir  0 - Voltar")
        opcao = input("Opção: ").strip()
        if opcao == "0":
            break
        try:
            if opcao == "1":
                consultar(cur, "SELECT * FROM " + tabela)
            elif opcao == "2":
                inserir(cur, tabela)
            elif opcao == "3":
                alterar(cur, tabela)
            elif opcao == "4":
                excluir(cur, tabela)
            else:
                print("Opção inválida.")
        except mysql.connector.Error as erro:
            print("Erro:", erro.msg)


def menu_admin(cur):
    # menu do administrador: cadastro de todas as entidades
    while True:
        print("\n=== ADMINISTRADOR ===")
        print("1 - Cadastrar aluno")
        print("2 - Cadastrar professor")
        print("3 - Cadastrar funcionário")
        print("4 - Gerenciar tabelas (listar, inserir, alterar, excluir)")
        print("5 - Listagens")
        print("0 - Sair")
        opcao = input("Opção: ").strip()
        if opcao == "0":
            break
        try:
            if opcao == "1":
                cadastrar_aluno(cur)
            elif opcao == "2":
                cadastrar_professor(cur)
            elif opcao == "3":
                cadastrar_funcionario(cur)
            elif opcao == "4":
                gerenciar_tabela(cur)
            elif opcao == "5":
                relatorios(cur)
            else:
                print("Opção inválida.")
        except mysql.connector.Error as erro:
            print("Erro:", erro.msg)


def realizar_emprestimo(con, cur):
    # abre um empréstimo e inclui os exemplares (desfaz tudo se der erro)
    id_usuario = identificar(cur)
    if id_usuario is None:
        return
    con.start_transaction()
    try:
        cur.execute("INSERT INTO emprestimo (id_usuario, data_emprestimo) VALUES (%s, CURDATE())", (id_usuario,))
        id_emprestimo = cur.lastrowid
        incluidos = 0
        while True:
            isbn = input("ISBN do livro (Enter para finalizar): ").strip()
            if isbn == "":
                break
            cur.execute("SELECT numero_exemplar FROM exemplar e WHERE e.isbn = %s AND NOT EXISTS "
                        "(SELECT 1 FROM item_emprestimo i WHERE i.isbn = e.isbn "
                        "AND i.numero_exemplar = e.numero_exemplar AND i.data_devolucao_efetiva IS NULL) "
                        "ORDER BY numero_exemplar LIMIT 1", (isbn,))
            exemplar = cur.fetchone()
            if exemplar is None:
                print("Nenhum exemplar disponível para este ISBN.")
                continue
            cur.execute("INSERT INTO item_emprestimo (id_emprestimo, isbn, numero_exemplar) VALUES (%s, %s, %s)",
                        (id_emprestimo, isbn, exemplar[0]))
            incluidos = incluidos + 1
            print("Exemplar", exemplar[0], "incluído.")
        if incluidos == 0:
            con.rollback()
            print("Nenhum livro incluído. Empréstimo cancelado.")
            return
        con.commit()
    except mysql.connector.Error:
        con.rollback()
        raise
    print("Empréstimo", id_emprestimo, "realizado.")
    consultar(cur, "SELECT l.titulo, i.numero_exemplar, i.data_prevista_devolucao FROM item_emprestimo i "
                   "JOIN livro l ON l.isbn = i.isbn WHERE i.id_emprestimo = %s", (id_emprestimo,))


def alterar_emprestimo(cur):
    # altera a data de devolução prevista de um exemplar emprestado
    id_emprestimo = input("Código do empréstimo: ")
    isbn = input("ISBN: ")
    numero = input("Número do exemplar: ")
    data = input("Nova data prevista de devolução (AAAA-MM-DD): ")
    cur.execute("UPDATE item_emprestimo SET data_prevista_devolucao = %s "
                "WHERE id_emprestimo = %s AND isbn = %s AND numero_exemplar = %s "
                "AND data_devolucao_efetiva IS NULL", (data, id_emprestimo, isbn, numero))
    print(cur.rowcount, "registro(s) alterado(s).")


def dar_baixa(cur):
    # registra a devolução de um exemplar e mostra a multa, se houver
    id_emprestimo = input("Código do empréstimo: ")
    isbn = input("ISBN: ")
    numero = input("Número do exemplar: ")
    chamar(cur, "sp_devolver_exemplar", [id_emprestimo, isbn, numero, None])


def menu_bibliotecario(con, cur):
    # menu do bibliotecário: consultas e empréstimos
    while True:
        print("\n=== BIBLIOTECÁRIO ===")
        print("1 - Consultar livros")
        print("2 - Consultar usuários")
        print("3 - Consultar reservas")
        print("4 - Listagens")
        print("5 - Empréstimos em aberto")
        print("6 - Realizar empréstimo")
        print("7 - Alterar data de devolução prevista")
        print("8 - Dar baixa (devolução)")
        print("0 - Sair")
        opcao = input("Opção: ").strip()
        if opcao == "0":
            break
        try:
            if opcao == "1":
                consultar_livros(cur)
            elif opcao == "2":
                consultar(cur, "SELECT u.id_usuario, u.tipo, u.nome, "
                               "COALESCE(a.matricula, p.mat_siape, f.matricula) AS matricula, u.situacao "
                               "FROM usuario u LEFT JOIN aluno a ON a.id_usuario = u.id_usuario "
                               "LEFT JOIN professor p ON p.id_usuario = u.id_usuario "
                               "LEFT JOIN funcionario f ON f.id_usuario = u.id_usuario ORDER BY u.nome")
            elif opcao == "3":
                consultar(cur, "SELECT * FROM vw_reservas_por_livro")
            elif opcao == "4":
                relatorios(cur)
            elif opcao == "5":
                consultar(cur, "SELECT e.id_emprestimo, u.nome, l.titulo, i.isbn, i.numero_exemplar, "
                               "i.data_prevista_devolucao FROM item_emprestimo i "
                               "JOIN emprestimo e ON e.id_emprestimo = i.id_emprestimo "
                               "JOIN usuario u ON u.id_usuario = e.id_usuario "
                               "JOIN livro l ON l.isbn = i.isbn "
                               "WHERE i.data_devolucao_efetiva IS NULL ORDER BY u.nome")
            elif opcao == "6":
                realizar_emprestimo(con, cur)
            elif opcao == "7":
                alterar_emprestimo(cur)
            elif opcao == "8":
                dar_baixa(cur)
            else:
                print("Opção inválida.")
        except mysql.connector.Error as erro:
            print("Erro:", erro.msg)


def menu_usuario(cur):
    # menu do usuário: consulta, reserva e cadastro
    meu_id = None
    while True:
        print("\n=== USUÁRIO ===")
        print("1 - Consultar livros")
        print("2 - Cadastrar-se")
        print("3 - Identificar-se (matrícula)")
        print("4 - Meus empréstimos")
        print("5 - Reservar livro")
        print("6 - Cancelar meu cadastro")
        print("0 - Sair")
        opcao = input("Opção: ").strip()
        if opcao == "0":
            break
        if opcao in ("4", "5", "6") and meu_id is None:
            print("Identifique-se primeiro (opção 3).")
            continue
        try:
            if opcao == "1":
                consultar_livros(cur)
            elif opcao == "2":
                tipo = input("1 - Aluno  2 - Professor  3 - Funcionário: ").strip()
                if tipo == "1":
                    cadastrar_aluno(cur)
                elif tipo == "2":
                    cadastrar_professor(cur)
                elif tipo == "3":
                    cadastrar_funcionario(cur)
                else:
                    print("Opção inválida.")
            elif opcao == "3":
                meu_id = identificar(cur)
            elif opcao == "4":
                chamar(cur, "sp_consultar_emprestimos_usuario", [meu_id])
            elif opcao == "5":
                isbn = input("ISBN do livro: ").strip()
                chamar(cur, "sp_reservar_livro", [meu_id, isbn])
                print("Reserva realizada.")
            elif opcao == "6":
                if input("Confirma o cancelamento do cadastro? (s/n): ").strip().lower() == "s":
                    chamar(cur, "sp_cancelar_cadastro", [meu_id])
                    print("Cadastro cancelado.")
            else:
                print("Opção inválida.")
        except mysql.connector.Error as erro:
            print("Erro:", erro.msg)


def entrar():
    # tela inicial: pede usuário e senha do banco
    usuario = input("Usuário: ").strip()
    senha = getpass.getpass("Senha: ")
    try:
        con = mysql.connector.connect(host=HOST, user=usuario, password=senha,
                                      database=BANCO, autocommit=True, use_pure=True)
    except mysql.connector.Error as erro:
        print("Não foi possível entrar:", erro.msg)
        return None, usuario
    return con, usuario


def main():
    # entra no sistema e abre o menu do nível de acesso do usuário
    print("=== BIBLIOTECA ACADÊMICA ===")
    con = None
    while con is None:
        con, usuario = entrar()
    cur = con.cursor()
    if usuario == "Admin":
        menu_admin(cur)
    elif usuario == "bibliotecario":
        menu_bibliotecario(con, cur)
    elif usuario == "usuario":
        menu_usuario(cur)
    else:
        print("Este usuário não tem nível de acesso no sistema.")
    con.close()


main()
