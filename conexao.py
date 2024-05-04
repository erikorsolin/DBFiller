import psycopg2
from config import user
from config import senha

conexao = psycopg2.connect(databe = "MAT_Analytics", 
                           host = "localhost", 
                           user = user, 
                           password = senha, 
                           porta = "5432")
cursor = conexao.cursor()