CREATE TABLE Metric 
( 
 ID SERIAL PRIMARY KEY,  
 name VARCHAR,  
 description VARCHAR,  
 type VARCHAR  -- type - (Clustering, Classification) VARCHAR, 
); 

CREATE TABLE ClusteringSchema 
( 
 ID SERIAL PRIMARY KEY,  
 method VARCHAR,  
 description VARCHAR,  
 idMetric SERIAL,  
 value VARCHAR  
); 

CREATE TABLE HasParameterClustering 
( 
 idClusteringSchema SERIAL,  
 idParameter SERIAL 
); 

CREATE TABLE Cluster 
( 
 ID SERIAL PRIMARY KEY,  
 description VARCHAR,  
 timestamp VARCHAR,  
 value VARCHAR,  
 Type VARCHAR,  --Type (MO - Point - MAT) VARCHAR,  
 idClusteringSchema SERIAL
); 

CREATE TABLE Parameter 
( 
 ID SERIAL PRIMARY KEY,  
 description VARCHAR,  
 name VARCHAR,  
 value VARCHAR,  
 Type VARCHAR   --Type (Clustering or Classification) VARCHAR,
); 

CREATE TABLE HasParameterClassification 
( 
 idParameter SERIAL,  
 idClassificationSchema SERIAL,  --idClassification Schema (Model) INT,
 PRIMARY KEY (idParameter, idClassificationSchema) -- arrumar os outros com base nessa
); 

CREATE TABLE ClassificationSchema --CREATE TABLE Classification Schema (Model) 
( 
 ID SERIAL PRIMARY KEY,  
 classAttribute VARCHAR,  
 description VARCHAR,  
 method VARCHAR,  
 evaluationMethod VARCHAR,  
 descriptionModel VARCHAR,  
 idTrainingSet SERIAL
); 

CREATE TABLE HasMetricClassificationSchema 
( 
 idMetric SERIAL,  
 idClassificationSchema SERIAL, --idClassification Schema (Model) INT,  
 Value VARCHAR
); 

CREATE TABLE HasPoint 
( 
 idCluster SERIAL,  
 idPoint SERIAL 
); 

CREATE TABLE HasMO 
( 
 idCluster SERIAL,  
 idTable SERIAL
); 

CREATE TABLE HasMAT 
( 
 idCluster SERIAL,  
 idTable SERIAL
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

CREATE TABLE HasMetricAppliedOn
( 
 Value VARCHAR,  
 idMetric SERIAL,  
 idAppliedOn SERIAL
); 

CREATE TABLE HasFeatureClustering 
( 
 idClusteringSchema SERIAL,  
 idFeature SERIAL
); 

CREATE TABLE Feature 
( 
 ID SERIAL PRIMARY KEY,  
 description VARCHAR,  
 name VARCHAR
); 

CREATE TABLE BaseFeature 
( 
 idFeature SERIAL,  
 idAttribute SERIAL,
 PRIMARY KEY (idFeature, idAttribute)
); 

CREATE TABLE Attribute 
( 
 ID SERIAL PRIMARY KEY,
 name VARCHAR  
); 

CREATE TABLE Aspect 
( 
 ID SERIAL PRIMARY KEY 
); 

CREATE TABLE GenarationMethod 
( 
 method VARCHAR,  
 idFeature SERIAL
); 

CREATE TABLE EngineeredFeature 
( 
 value VARCHAR,  
 idFeature SERIAL,
 PRIMARY KEY (idFeature)
); 

CREATE TABLE Considers 
( 
 idAttribute SERIAL,  
 idFeature SERIAL  
); 

CREATE TABLE HasFeatureClassification 
( 
 idClassificationSchema SERIAL,  --idClassification Schema (Model) INT, 
 idFeature SERIAL
); 

CREATE TABLE AppliedOn 
( 
 ID SERIAL PRIMARY KEY,  
 idTestSet SERIAL,  
 idClassificationModel SERIAL,
 UNIQUE(idTestSet, idClassificationModel)
); 

CREATE TABLE TestSet 
( 
 ID SERIAL PRIMARY KEY,  
 description VARCHAR,  
 idAppliedOn SERIAL,  
 Name VARCHAR,  --Name (Data Split) VARCHAR,  
 idDataset SERIAL  
); 

CREATE TABLE ClassificationModel 
( 
 ID SERIAL PRIMARY KEY,  
 description VARCHAR,  
 idClassificationSchema SERIAL NOT NULL UNIQUE  --idClassification Schema (Model) INT NOT NULL UNIQUE, 
); 

CREATE TABLE Classifies 
( 
 label VARCHAR,  
 idClassificationModel SERIAL,  
 idMovingEntity SERIAL
); 

CREATE TABLE Dataset 
( 
 ID SERIAL PRIMARY KEY,  
 idTrainingSet SERIAL,  
 idTestSet SERIAL  
); 

CREATE TABLE TrainingSet 
( 
 ID SERIAL PRIMARY KEY,  
 description VARCHAR,  
 name VARCHAR,  --name (Data Split) VARCHAR, 
 idDataset SERIAL 
); 

CREATE TABLE hasInstanceMoving 
( 
 idTestSet SERIAL,  
 idMovingEntity SERIAL  
); 

CREATE TABLE hasInstanceClassValue 
( 
 idHasInstanceClassValue SERIAL PRIMARY KEY,
 idTrainingSet SERIAL ,  
 idMovingEntity SERIAL,
 UNIQUE(idTrainingSet, idMovingEntity)
); 

CREATE TABLE ClassValue 
( 
 value VARCHAR,  
 idHasInstanceClassValue SERIAL  
); 

CREATE TABLE hasAttribute 
( 
 value VARCHAR,  
 idAspect SERIAL,  
 idAttribute SERIAL
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