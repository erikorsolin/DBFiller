import psycopg2
from config import user
from config import senha

# Parâmetros de conexão com o banco de dados PostgreSQL
dbname = 'MAT_Analytics'
user = user
password = senha
host = 'localhost'
port = '5432'

try:
    # Conectando ao banco de dados
    conn = psycopg2.connect(dbname=dbname, user=user, password=password, host=host, port=port)
    
    # Criando um cursor para executar operações no banco de dados
    cursor = conn.cursor()
    
    # Exemplo: Executando uma consulta SQL
    cursor.execute("SELECT * FROM appliedon;")
    
    # Obtendo os resultados da consulta
    rows = cursor.fetchall()
    
    # Imprimindo os resultados
    for row in rows:
        print(row)
    
    # Fechando o cursor e a conexão com o banco de dados
    cursor.close()
    conn.close()

except psycopg2.Error as e:
    print("Erro ao conectar ao banco de dados PostgreSQL:", e)
