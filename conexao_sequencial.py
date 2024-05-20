import psycopg2
import random
import string
from config import user
from config import senha
from config import name

def random_string(length, chars=string.ascii_letters + string.digits):
    return ''.join(random.choices(chars, k=length))

def fetch_ids(cursor, table_name):
    cursor.execute(f"SELECT ID FROM {table_name}")
    ids = [row[0] for row in cursor.fetchall()]
    return ids

# Parâmetros de conexão com o banco de dados PostgreSQL
dbname = name
user = user
password = senha
host = 'localhost'
port = '5432'

# Número de linhas a serem inseridas em cada tabela
num_entries = 10000 

try:
    # Conectando ao banco de dados
    conn = psycopg2.connect(dbname=dbname, user=user,
                            password=password, host=host, port=port)
    cursor = conn.cursor()
    
    # Insere dados e busca IDs para as tabelas com chaves estrangeiras
    for _ in range(num_entries):
        cursor.execute("INSERT INTO Metric (name, description, type) VALUES (%s, %s, %s)",
                       (random_string(10), random_string(50), random.choice(['Clustering', 'Classification'])))
    metric_ids = fetch_ids(cursor, 'Metric')
    
    for _ in range(num_entries):
        cursor.execute("INSERT INTO Aspect DEFAULT VALUES")
    aspect_ids = fetch_ids(cursor, 'Aspect')

    for _ in range(num_entries):
        cursor.execute("INSERT INTO Feature (description, name) VALUES (%s, %s)",
                       (random_string(50), random_string(10)))
    feature_ids = fetch_ids(cursor, 'Feature')
    
    copy_feature_ids = feature_ids.copy()
    for _ in range(num_entries):
        sorteado = random.choice(copy_feature_ids)
        cursor.execute("INSERT INTO EngineeredFeature (value, idFeature) VALUES (%s, %s)", #----------------------------------------------
                       (random_string(10), sorteado))
        if sorteado in copy_feature_ids:
            copy_feature_ids.remove(sorteado)

    for _ in range(num_entries):
        random_c = random.choice(feature_ids);
        cursor.execute("INSERT INTO GenarationMethod (method, idFeature) VALUES (%s, %s)",
                       (random_string(15), random.choice(feature_ids)))
    
    for _ in range(num_entries):
        cursor.execute("INSERT INTO Attribute (name) VALUES (%s)", (random_string(20),))
    attribute_ids = fetch_ids(cursor, 'Attribute')

    copy_feature_ids = feature_ids.copy()
    copy_attribute_ids = attribute_ids.copy()
    for _ in range(num_entries):
        sorteado_feature = random.choice(copy_feature_ids)
        sorteado_attribute = random.choice(copy_attribute_ids)
        cursor.execute("INSERT INTO BaseFeature (idFeature, idAttribute) VALUES (%s, %s)", #------------------------------------------------
                       (sorteado_feature, sorteado_attribute))
        if sorteado_feature in copy_feature_ids and sorteado_attribute in copy_attribute_ids:
            copy_feature_ids.remove(sorteado_feature)
            copy_attribute_ids.remove(sorteado_attribute)

    for _ in range(num_entries):
        cursor.execute("INSERT INTO hasAttribute (value, idAspect, idAttribute) VALUES (%s, %s, %s)",
                       (random_string(10), random.choice(aspect_ids), random.choice(attribute_ids)))

    for _ in range(num_entries):
        cursor.execute("INSERT INTO ClusteringSchema (method, description, idMetric, value) VALUES (%s, %s, %s, %s)",
                       (random_string(15), random_string(50), random.choice(metric_ids), random_string(10)))
    clustering_schema_ids = fetch_ids(cursor, 'ClusteringSchema')

    for _ in range(num_entries):
        cursor.execute("INSERT INTO HasFeatureClustering (idClusteringSchema, idFeature) VALUES (%s, %s)",
                       (random.choice(clustering_schema_ids), random.choice(feature_ids)))

    for _ in range(num_entries):
        cursor.execute("INSERT INTO Parameter (description, name, value, Type) VALUES (%s, %s, %s, %s)",
                       (random_string(50), random_string(10), random_string(10), random.choice(['Clustering', 'Classification'])))
    parameter_ids = fetch_ids(cursor, 'Parameter')

    for _ in range(num_entries):
        cursor.execute("INSERT INTO Point DEFAULT VALUES")
    point_ids = fetch_ids(cursor, 'Point')

    for _ in range(num_entries):
        cursor.execute("INSERT INTO MovingEntity (Type) VALUES (%s)",
                       (random.choice(['MO', 'MAT']),))
    moving_entity_ids = fetch_ids(cursor, 'MovingEntity')

    for _ in range(num_entries):
        cursor.execute("INSERT INTO HasParameterClustering (idClusteringSchema, idParameter) VALUES (%s, %s)",
                       (random.choice(clustering_schema_ids), random.choice(parameter_ids)))

    for _ in range(num_entries):
        cursor.execute("INSERT INTO Cluster (description, timestamp, value, Type, idClusteringSchema) VALUES (%s, %s, %s, %s, %s)",
                       (random_string(50), random_string(10, string.digits), random_string(10), random.choice(['MO', 'Point', 'MAT']), random.choice(clustering_schema_ids)))
    cluster_ids = fetch_ids(cursor, 'Cluster')

    for _ in range(num_entries):
        cursor.execute("INSERT INTO HasPoint (idCluster, idPoint) VALUES (%s, %s)",
                       (random.choice(cluster_ids), random.choice(point_ids)))

    for _ in range(num_entries):
        cursor.execute("INSERT INTO HasMO (idCluster, idTable) VALUES (%s, %s)",
                       (random.choice(cluster_ids), random.choice(moving_entity_ids)))

    for _ in range(num_entries):
        cursor.execute("INSERT INTO HasMAT (idCluster, idTable) VALUES (%s, %s)",
                       (random.choice(cluster_ids), random.choice(moving_entity_ids)))
    
    
    # ------------------------------------ Dependência circular ---------------------------------------------------

    # LEMBRAR DE ATUALIZAR AS CHAVES ESTRANGEIRAS DEPOIS
    for _ in range(num_entries):
        cursor.execute("INSERT INTO Dataset (idTrainingSet, idTestSet) VALUES (NULL, NULL)")
    data_set_ids = fetch_ids(cursor, 'Dataset')

    for _ in range(num_entries):
        cursor.execute("INSERT INTO TrainingSet (description, name, idDataset) VALUES (%s, %s, %s)",
                       (random_string(50), random_string(10),random.choice(data_set_ids)))
    training_set_ids = fetch_ids(cursor, 'TrainingSet')

    copy_training_set_ids = training_set_ids.copy()
    copy_moving_entity_ids = moving_entity_ids.copy()
    for _ in range(num_entries):
        sorteado_training_set = random.choice(copy_training_set_ids)
        sorteado_moving_entity = random.choice(copy_moving_entity_ids)
        cursor.execute("INSERT INTO hasInstanceClassValue (idTrainingSet, idMovingEntity) VALUES (%s, %s)", #------------------------------------------------
                       (sorteado_training_set, sorteado_moving_entity))
        if sorteado_training_set in copy_training_set_ids and sorteado_moving_entity in copy_moving_entity_ids:
            copy_training_set_ids.remove(sorteado_training_set)
            copy_moving_entity_ids.remove(sorteado_moving_entity)
    has_instance_class_value_ids = fetch_ids(cursor, 'hasInstanceClassValue')
    
    for _ in range(num_entries):
        cursor.execute("INSERT INTO ClassValue (value, idHasInstanceClassValue) VALUES (%s, %s)",
                       (random_string(50),random.choice(has_instance_class_value_ids)))

    for _ in range(num_entries):
        cursor.execute("INSERT INTO ClassificationSchema (classAttribute, description, method, evaluationMethod, descriptionModel, idTrainingSet) VALUES (%s, %s, %s, %s, %s, %s)",
                       (random_string(10), random_string(10), random_string(10), random_string(10), random_string(10), random.choice(training_set_ids)))
    classification_schema_ids = fetch_ids(cursor, 'ClassificationSchema')

    copy_parameter_ids = parameter_ids.copy()
    copy_classification_schema_ids = classification_schema_ids.copy()
    for _ in range(num_entries):
        sorteado_parameter = random.choice(copy_parameter_ids)
        sorteado_classification_schema = random.choice(copy_classification_schema_ids)
        cursor.execute("INSERT INTO HasParameterClassification (idParameter, idClassificationSchema) VALUES (%s, %s)", #------------------------------------------------
                       (sorteado_parameter, sorteado_classification_schema))
        if sorteado_parameter in copy_parameter_ids and sorteado_classification_schema in copy_classification_schema_ids:
            copy_parameter_ids.remove(sorteado_parameter)
            copy_classification_schema_ids.remove(sorteado_classification_schema)
    
    for _ in range(num_entries):
        cursor.execute("INSERT INTO HasFeatureClassification (idClassificationSchema, idFeature) VALUES (%s, %s)",
                       (random.choice(classification_schema_ids), random.choice(feature_ids)))
    
    copy_classification_schema_ids = classification_schema_ids.copy()
    for _ in range(num_entries):
        sorteado_classification_schema = random.choice(copy_classification_schema_ids)
        cursor.execute("INSERT INTO ClassificationModel (description, idClassificationSchema) VALUES (%s, %s)", #----------------------------------------------
                       (random_string(50), sorteado_classification_schema))
        if sorteado_classification_schema in copy_classification_schema_ids:
            copy_classification_schema_ids.remove(sorteado_classification_schema)
    classification_model_ids = fetch_ids(cursor, 'ClassificationModel')
    
    for _ in range(num_entries):
        cursor.execute("INSERT INTO Classifies (label, idClassificationModel, idMovingEntity) VALUES (%s, %s, %s)",
                       (random_string(10), random.choice(classification_model_ids), random.choice(moving_entity_ids)))
        
    for _ in range(num_entries):
        cursor.execute("INSERT INTO HasMetricClassificationSchema (idMetric, idClassificationSchema, Value) VALUES (%s, %s, %s)",
                       (random.choice(metric_ids), random.choice(classification_schema_ids), random_string(10)))
    
    for _ in range(num_entries):
        cursor.execute("INSERT INTO Considers (idAttribute, idFeature) VALUES (%s, %s)",
                       (random.choice(attribute_ids), random.choice(feature_ids)))
        
    # LEMBRAR DE ATUALIZAR AS CHAVES ESTRANGEIRAS DEPOIS ------------------------------
    for _ in range(num_entries):
        cursor.execute("INSERT INTO AppliedOn (idTestSet, idClassificationModel) VALUES (NULL, NULL)")
    applied_on_ids = fetch_ids(cursor, 'AppliedOn')

    for _ in range(num_entries):
        cursor.execute("INSERT INTO HasMetricAppliedOn (Value, idMetric, idAppliedOn) VALUES (%s, %s, %s)",
                       (random_string(10), random.choice(metric_ids), random.choice(applied_on_ids)))

    for _ in range(num_entries):
        cursor.execute("INSERT INTO TestSet (description, idAppliedOn, Name, idDataset) VALUES (%s, %s, %s, %s)",
                       (random_string(50), random.choice(applied_on_ids), random_string(10), random.choice(data_set_ids)))
    test_set_ids = fetch_ids(cursor, 'TestSet')

    for _ in range(num_entries):
        cursor.execute("INSERT INTO hasInstanceMoving (idTestSet, idMovingEntity) VALUES (%s, %s)",
                       (random.choice(test_set_ids), random.choice(moving_entity_ids)))
        
    # ------------------------- Atualizar as chaves estrangeiras inicializadas em NULL ---------------------------
    copy_data_set_ids = data_set_ids.copy()
    copy_test_set_ids = test_set_ids.copy()
    for _ in range(num_entries):
        sorteado_data_set_ids = random.choice(copy_data_set_ids)
        sorteado_test_set_ids = random.choice(copy_test_set_ids)
        cursor.execute("UPDATE Dataset SET idTestSet = %s WHERE ID = %s",
                       (sorteado_test_set_ids, sorteado_data_set_ids))
        if sorteado_data_set_ids in copy_data_set_ids and sorteado_test_set_ids in copy_test_set_ids:
            copy_data_set_ids.remove(sorteado_data_set_ids)
            copy_test_set_ids.remove(sorteado_test_set_ids)
    
    copy_data_set_ids = data_set_ids.copy()
    copy_training_set_ids = training_set_ids.copy()
    for _ in range(num_entries):
        sorteado_data_set_ids = random.choice(copy_data_set_ids)
        sorteado_training_set_ids = random.choice(copy_training_set_ids)
        cursor.execute("UPDATE Dataset SET idTrainingSet = %s WHERE ID = %s",
                       (sorteado_training_set_ids, sorteado_data_set_ids))
        if sorteado_data_set_ids in copy_data_set_ids and sorteado_training_set_ids in copy_training_set_ids:
            copy_data_set_ids.remove(sorteado_data_set_ids)
            copy_training_set_ids.remove(sorteado_training_set_ids)
    
    copy_applied_on_ids = applied_on_ids.copy()
    copy_test_set_ids = test_set_ids.copy()
    for _ in range(num_entries):
        sorteado_applied_on_ids = random.choice(copy_applied_on_ids)
        sorteado_test_set_ids = random.choice(copy_test_set_ids)
        cursor.execute("UPDATE AppliedOn SET idTestSet = %s WHERE ID = %s",
                       (sorteado_test_set_ids, sorteado_applied_on_ids))
        if sorteado_applied_on_ids in copy_applied_on_ids and sorteado_test_set_ids in copy_test_set_ids:
            copy_applied_on_ids.remove(sorteado_applied_on_ids)
            copy_test_set_ids.remove(sorteado_test_set_ids)

    copy_applied_on_ids = applied_on_ids.copy()
    copy_classification_model_ids = classification_model_ids.copy()
    for _ in range(num_entries):
        sorteado_applied_on_ids = random.choice(copy_applied_on_ids)
        sorteado_classification_model_ids = random.choice(copy_classification_model_ids)
        cursor.execute("UPDATE AppliedOn SET idClassificationModel = %s WHERE ID = %s",
                       (sorteado_classification_model_ids, sorteado_applied_on_ids))
        if sorteado_applied_on_ids in copy_applied_on_ids and sorteado_classification_model_ids in copy_classification_model_ids:
            copy_applied_on_ids.remove(sorteado_applied_on_ids)
            copy_classification_model_ids.remove(sorteado_classification_model_ids)

except Exception as error:
    print("Erro ao inserir dados:", error)
    if conn:
        conn.rollback()
finally:
    conn.commit()
    if cursor:
        cursor.close()
    if conn:
        conn.close()
    print("Dados inseridos com sucesso!")
