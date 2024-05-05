import psycopg2
from faker import Faker
import re
from collections import defaultdict
from config import user
from config import senha
from config import name

# Função para inserir dados em uma tabela
def insert_data(table, fields, conn, fk_relations):
    faker = Faker()
    cur = conn.cursor()
    for _ in range(10):
        try:
            # Se a tabela não tiver atributos além do ID
            if len(fields) == 1 and fields[0] == "ID":
                cur.execute(f"INSERT INTO {table} DEFAULT VALUES")
            else:
                values = []
                for field in fields:
                    if field in ["ID", "PRIMARY"]:  # Ignorar o campo ID e 'PRIMARY'
                        continue

                    # Verificar se o campo é uma chave estrangeira
                    foreign_keys = fk_relations.get(table, [])
                    foreign_key = next((fk for fk in foreign_keys if fk[0] == field), None)
                    if foreign_key:
                        foreign_table = foreign_key[1]
                        cur.execute(f'SELECT ID FROM {foreign_table} ORDER BY RANDOM() LIMIT 1')
                        result = cur.fetchone()
                        if result:
                            values.append(result[0])
                        else:
                            values.append(None)
                    else:
                        # Inserir valores aleatórios apropriados
                        if field.startswith("id") or "int" in field.lower() or "serial" in field.lower():
                            values.append(faker.random_int(1, 10))
                        else:
                            values.append(faker.word())

                # Gerar lista de campos sem o ID e 'PRIMARY'
                fields_without_id = [field for field in fields if field not in ["ID", "PRIMARY"]]

                # Inserir os dados na tabela
                insert_query = f"INSERT INTO {table} ({', '.join(fields_without_id)}) VALUES ({', '.join(['%s'] * len(fields_without_id))})"
                print(insert_query, tuple(values))
                cur.execute(insert_query, tuple(values))
                conn.commit()
                
        except Exception as e:
                print(f"Error inserting into {table}: {e}")
                conn.rollback()
                cur.execute("BEGIN")

    cur.close()


# Parâmetros de conexão com o banco de dados PostgreSQL
dbname = name
user = user
password = senha
host = 'localhost'
port = '5432'

try:
    # Conectando ao banco de dados
    conn = psycopg2.connect(dbname=dbname, user=user,
                            password=password, host=host, port=port)
except psycopg2.Error as e:
    print("Erro ao conectar ao banco de dados PostgreSQL:", e)

# --------------------------------------- Ler o conteúdo sql do arquivo -------------------------------------------
# Ler o conteúdo do arquivo
with open("teste.sql", "r") as file:
    sql_content = file.read()

# ------------------------------------------------------------------------------------------------------------------

# --------------------------------------- Encontrar tabelas e chaves estrangeiras ---------------------------------

# Padrão para encontrar as definições de tabelas
table_pattern = r'CREATE TABLE (\w+)\s*\((.*?)\);'
# Padrão para encontrar as definições de chaves estrangeiras
fk_pattern = r'ALTER TABLE (\w+) ADD FOREIGN KEY\((\w+)\) REFERENCES (\w+);'

# Encontrar todas as definições de tabelas
tables = re.findall(table_pattern, sql_content, re.DOTALL)

# Dicionário para armazenar informações das tabelas
table_info = {}
fk_relations = defaultdict(list)

for table, fields in tables:
    # Limpar e separar os campos
    fields = fields.strip().splitlines()
    fields = [f.strip().split()[0] for f in fields if f.strip() and not f.strip().startswith("--")]
    table_info[table] = fields

# Encontrar as chaves estrangeiras
for fk in re.findall(fk_pattern, sql_content):
    table, field, ref_table = fk
    fk_relations[table].append((field, ref_table))

# -----------------------------------------------------------------------------------------------------------------

# Inserir dados em todas as tabelas
for table, fields in table_info.items():
        insert_data(table, fields, conn, fk_relations)

conn.close()