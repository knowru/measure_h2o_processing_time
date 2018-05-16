# Algorithms Experimented
# ========================
# List of available supervised algorithms in H2O from H2O document (http://docs.h2o.ai/h2o/latest-stable/h2o-docs/data-science.html#supervised)
# Skipped algorithms: GLM, Naive Bayes (processing time should be very short)
# Experimented algorithms: DRF, GBM, Deep Learning, Stacked Ensembles (GBM + RF), XGBoost

# Parameters Adjusted
# ===================
# DRF: ntrees (10, 100, 1000, 10000), max_depth (5, 10, 20) => 4 x 3 = 12 models

# Code reference: http://docs.h2o.ai/h2o/latest-stable/h2o-docs/data-science/stacked-ensembles.html
library(h2o)
h2o.init()

# Import a sample binary outcome train/test set into H2O
train <- h2o.importFile("https://s3.amazonaws.com/erin-data/higgs/higgs_train_10k.csv")
test <- h2o.importFile("https://s3.amazonaws.com/erin-data/higgs/higgs_test_5k.csv")

# Identify predictors and response
y <- "response"
x <- setdiff(names(train), y)

# For binary classification, response should be a factor
train[,y] <- as.factor(train[,y])
test[,y] <- as.factor(test[,y])

# Build DRF models
log_loc <- paste(getwd(), "/logs/DRF.log", sep="")
con <- file(log_loc, "w")
for (ntrees in c(10, 100, 100, 1000, 10000)) {
    for (max_depth in c(5, 10, 20)) {
        start_time <- Sys.time()
        cat(paste("Starting building a DRF model (ntrees: ", ntrees, ", max_depth: ", max_depth, ") at ", start_time, "\n", sep=""), file=con)
        rf <- h2o.randomForest(x = x,
                            y = y,
                            training_frame = train,
                            ntrees = ntrees,
                            seed = 1)
        end_time <- Sys.time()
        elapsed_time = format(round(end_time - start_time, 2))
        cat(paste("Finished building the DRF model (ntrees: ", ntrees, ", max_depth: ", max_depth, ") at ", end_time, " (elapsed time: ",elapsed_time, ")", "\n", sep=""), file=con)
        model_path <- h2o.saveModel(object=rf, path=paste(getwd(), "/DRF_models/", sep=""), force=TRUE)
        new_model_path = paste(getwd(), "/DRF_models/DRF_ntrees-", ntrees, "_max_depth-", max_depth, sep="")
        file.rename(model_path, new_model_path)
        cat(paste("Saved the model at ", new_model_path, sep=""), "\n\n", file=con)
    }
}
close(con)
