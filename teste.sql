CREATE TABLE Metric 
( 
 ID SERIAL PRIMARY KEY,  
 name VARCHAR,  
 description VARCHAR,  
 type VARCHAR  -- type - (Clustering, Classification) VARCHAR, 
); 

CREATE TABLE Aspect 
( 
 ID SERIAL PRIMARY KEY 
); 

CREATE TABLE Feature 
( 
 ID SERIAL PRIMARY KEY,  
 description VARCHAR,  
 name VARCHAR
); 

CREATE TABLE EngineeredFeature 
( 
 value VARCHAR,  
 idFeature INT,
 PRIMARY KEY (idFeature)
);

CREATE TABLE GenarationMethod 
( 
 method VARCHAR,  
 idFeature INT
);

CREATE TABLE Attribute 
( 
 ID SERIAL PRIMARY KEY,
 name VARCHAR  
); 

CREATE TABLE BaseFeature 
( 
 idFeature INT,  
 idAttribute INT,
 --PRIMARY KEY (idFeature, idAttribute)
 PRIMARY KEY (idFeature, idAttribute)
);

CREATE TABLE hasAttribute 
( 
 value VARCHAR,  
 idAspect INT,  
 idAttribute INT
);

CREATE TABLE ClusteringSchema 
( 
 ID SERIAL PRIMARY KEY,  
 method VARCHAR,  
 description VARCHAR,  
 idMetric INT,  
 value VARCHAR  
);

CREATE TABLE HasFeatureClustering 
( 
 idClusteringSchema INT,  
 idFeature INT
); 

CREATE TABLE Parameter 
( 
 ID SERIAL PRIMARY KEY,  
 description VARCHAR,  
 name VARCHAR,  
 value VARCHAR,  
 Type VARCHAR   --Type (Clustering or Classification) VARCHAR,
); 

CREATE TABLE Point 
( 
 ID SERIAL PRIMARY KEY  
); 

CREATE TABLE MovingEntity 
( 
 ID SERIAL PRIMARY KEY,  
 Type VARCHAR --Type (MO - MAT) VARCHAR,   
); 


CREATE TABLE HasParameterClustering 
( 
 idClusteringSchema INT,  
 idParameter INT 
); 

CREATE TABLE Cluster 
( 
 ID SERIAL PRIMARY KEY,  
 description VARCHAR,  
 timestamp VARCHAR,  
 value VARCHAR,  
 Type VARCHAR,  --Type (MO - Point - MAT) VARCHAR,  
 idClusteringSchema INT
); 

CREATE TABLE HasPoint 
( 
 idCluster INT,  
 idPoint INT 
); 

CREATE TABLE HasMO 
( 
 idCluster INT,  
 idTable INT
); 

CREATE TABLE HasMAT 
( 
 idCluster INT,  
 idTable INT
);

-- ----------------------------------------- DEPENDÊNCIA CIRCULAR ------------------------------------------------
CREATE TABLE Dataset -- Inserir FKs como NULL para liberar dependência circular
( 
 ID SERIAL PRIMARY KEY,  
 idTrainingSet INT,  
 idTestSet INT  
); 

CREATE TABLE TrainingSet 
( 
 ID SERIAL PRIMARY KEY,  
 description VARCHAR,  
 name VARCHAR,  --name (Data Split) VARCHAR, 
 idDataset INT 
);

CREATE TABLE hasInstanceClassValue 
( 
 ID SERIAL PRIMARY KEY,
 idTrainingSet INT,  
 idMovingEntity INT,
 UNIQUE(idTrainingSet, idMovingEntity)
);

CREATE TABLE ClassValue 
( 
 value VARCHAR,  
 idHasInstanceClassValue INT  
); 

CREATE TABLE ClassificationSchema --CREATE TABLE Classification Schema (Model) 
( 
 ID SERIAL PRIMARY KEY,  
 classAttribute VARCHAR,  
 description VARCHAR,  
 method VARCHAR,  
 evaluationMethod VARCHAR,  
 descriptionModel VARCHAR,  
 idTrainingSet INT
); 

CREATE TABLE HasParameterClassification 
( 
 idParameter INT,  
 idClassificationSchema INT,  --idClassification Schema (Model) INT,
 PRIMARY KEY (idParameter, idClassificationSchema) -- arrumar os outros com base nessa
); 

CREATE TABLE HasFeatureClassification 
( 
 idClassificationSchema INT,  --idClassification Schema (Model) INT, 
 idFeature INT
);

CREATE TABLE ClassificationModel 
( 
 ID SERIAL PRIMARY KEY,  
 description VARCHAR,  
 idClassificationSchema INT NOT NULL UNIQUE  --idClassification Schema (Model) INT NOT NULL UNIQUE, 
);

CREATE TABLE Classifies 
( 
 label VARCHAR,  
 idClassificationModel INT,  
 idMovingEntity INT
); 

CREATE TABLE HasMetricClassificationSchema 
( 
 idMetric INT,  
 idClassificationSchema INT, --idClassification Schema (Model) INT,  
 Value VARCHAR
); 

CREATE TABLE Considers 
( 
 idAttribute INT,  
 idFeature INT  
); 

-- Inserir FKs como NULL para liberar dependência circular
CREATE TABLE AppliedOn 
( 
 ID SERIAL PRIMARY KEY,  
 idTestSet INT,  
 idClassificationModel INT,
 UNIQUE(idTestSet, idClassificationModel)
); 

CREATE TABLE HasMetricAppliedOn
( 
 Value VARCHAR,  
 idMetric INT, 
 idAppliedOn INT
);

CREATE TABLE TestSet 
( 
 ID SERIAL PRIMARY KEY,  
 description VARCHAR,  
 idAppliedOn INT,  
 Name VARCHAR,  --Name (Data Split) VARCHAR,  
 idDataset INT  
); 

CREATE TABLE hasInstanceMoving 
( 
 idTestSet INT,  
 idMovingEntity INT  
); 

ALTER TABLE ClusteringSchema ADD FOREIGN KEY(idMetric) REFERENCES Metric;
ALTER TABLE HasParameterClustering ADD FOREIGN KEY(idClusteringSchema) REFERENCES ClusteringSchema;
ALTER TABLE HasParameterClustering ADD FOREIGN KEY(idParameter) REFERENCES Parameter;
ALTER TABLE Cluster ADD FOREIGN KEY(idClusteringSchema) REFERENCES ClusteringSchema;
ALTER TABLE HasParameterClassification ADD FOREIGN KEY(idParameter) REFERENCES Parameter;
ALTER TABLE HasParameterClassification ADD FOREIGN KEY(idClassificationSchema) REFERENCES ClassificationSchema; --ALTER TABLE HasParameterClassification ADD FOREIGN KEY(idClassificationSchema (Model)) REFERENCES ClassificationSchema (Model) (idClassificationSchema (Model));

ALTER TABLE ClassificationSchema ADD FOREIGN KEY(idTrainingSet) REFERENCES TrainingSet;
ALTER TABLE HasMetricClassificationSchema ADD FOREIGN KEY(idMetric) REFERENCES Metric;
ALTER TABLE HasMetricClassificationSchema ADD FOREIGN KEY(idClassificationSchema) REFERENCES ClassificationSchema; --ALTER TABLE HasMetric ADD FOREIGN KEY(idClassification Schema (Model)) REFERENCES Classification Schema (Model) (idClassification Schema (Model));

ALTER TABLE HasPoint ADD FOREIGN KEY(idCluster) REFERENCES Cluster;
ALTER TABLE HasPoint ADD FOREIGN KEY(idPoint) REFERENCES Point;
ALTER TABLE HasMO ADD FOREIGN KEY(idCluster) REFERENCES Cluster;
ALTER TABLE HasMO ADD FOREIGN KEY(idTable) REFERENCES MovingEntity;
ALTER TABLE HasMAT ADD FOREIGN KEY(idCluster) REFERENCES Cluster;
ALTER TABLE HasMAT ADD FOREIGN KEY(idTable) REFERENCES MovingEntity ;
ALTER TABLE HasMetricAppliedOn ADD FOREIGN KEY(idMetric) REFERENCES Metric;
ALTER TABLE HasMetricAppliedOn ADD FOREIGN KEY(idAppliedOn) REFERENCES AppliedOn;
ALTER TABLE HasFeatureClustering ADD FOREIGN KEY(idClusteringSchema) REFERENCES ClusteringSchema;
ALTER TABLE HasFeatureClustering ADD FOREIGN KEY(idFeature) REFERENCES Feature;
ALTER TABLE BaseFeature ADD FOREIGN KEY(idFeature) REFERENCES Feature;
ALTER TABLE BaseFeature ADD FOREIGN KEY(idAttribute) REFERENCES Attribute;
ALTER TABLE GenarationMethod ADD FOREIGN KEY(idFeature) REFERENCES EngineeredFeature;
ALTER TABLE EngineeredFeature ADD FOREIGN KEY(idFeature) REFERENCES Feature;
ALTER TABLE Considers ADD FOREIGN KEY(idAttribute) REFERENCES Attribute;
ALTER TABLE Considers ADD FOREIGN KEY(idFeature) REFERENCES EngineeredFeature;
ALTER TABLE HasFeatureClassification ADD FOREIGN KEY(idClassificationSchema) REFERENCES ClassificationSchema; --ALTER TABLE HasFeatureClassification ADD FOREIGN KEY(idClassificationSchema (Model)) REFERENCES Classification Schema (Model) (idClassification Schema (Model));

ALTER TABLE HasFeatureClassification ADD FOREIGN KEY(idFeature) REFERENCES Feature;
ALTER TABLE AppliedOn ADD FOREIGN KEY(idTestSet) REFERENCES TestSet;
ALTER TABLE AppliedOn ADD FOREIGN KEY(idClassificationModel) REFERENCES ClassificationModel;
ALTER TABLE TestSet ADD FOREIGN KEY(idAppliedOn) REFERENCES AppliedOn;
ALTER TABLE TestSet ADD FOREIGN KEY(idDataset) REFERENCES Dataset;
ALTER TABLE ClassificationModel ADD FOREIGN KEY(idClassificationSchema) REFERENCES ClassificationSchema;
ALTER TABLE Classifies ADD FOREIGN KEY(idClassificationModel) REFERENCES ClassificationModel;
ALTER TABLE Classifies ADD FOREIGN KEY(idMovingEntity) REFERENCES MovingEntity;
ALTER TABLE Dataset ADD FOREIGN KEY(idTrainingSet) REFERENCES TrainingSet;
ALTER TABLE Dataset ADD FOREIGN KEY(idTestSet) REFERENCES TestSet;
ALTER TABLE TrainingSet ADD FOREIGN KEY(idDataset) REFERENCES Dataset;
ALTER TABLE hasInstanceMoving ADD FOREIGN KEY(idTestSet) REFERENCES TestSet;
ALTER TABLE hasInstanceMoving ADD FOREIGN KEY(idMovingEntity) REFERENCES MovingEntity;
ALTER TABLE hasInstanceClassValue ADD FOREIGN KEY(idTrainingSet) REFERENCES TrainingSet;
ALTER TABLE hasInstanceClassValue ADD FOREIGN KEY(idMovingEntity) REFERENCES MovingEntity;
ALTER TABLE ClassValue ADD FOREIGN KEY(idHasInstanceClassValue) REFERENCES hasInstanceClassValue;
ALTER TABLE hasAttribute ADD FOREIGN KEY(idAspect) REFERENCES Aspect;
ALTER TABLE hasAttribute ADD FOREIGN KEY(idAttribute) REFERENCES Attribute;
