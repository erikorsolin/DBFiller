import psycopg2
import random
import string
from config import user
from config import senha
from config import name

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

cursor = conn.cursor()

# Insere dados na tabela Feature
for _ in range(5):
    description = ''.join(random.choices(string.ascii_lowercase, k=10))
    name = ''.join(random.choices(string.ascii_uppercase, k=5))
    cursor.execute("INSERT INTO Feature (description, name) VALUES (%s, %s)", (description, name))

# Insere dados na tabela EngineeredFeature
for _ in range(5):
    value = ''.join(random.choices(string.ascii_uppercase + string.digits, k=5))
    id_feature = random.randint(1, 5)
    cursor.execute("INSERT INTO EngineeredFeature (value, idFeature) VALUES (%s, %s)", (value, id_feature))

# Confirma as transações
conn.commit()


conn.close()