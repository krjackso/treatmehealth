package main

import (
	"net/http"

	"github.com/krjackso/treatmehealth/api/models"
	"github.com/krjackso/treatmehealth/api/routes"
	"github.com/krjackso/treatmehealth/api/services"
)

func main() {
	datastore := services.NewDatastore("treatme-health", "dev")

	userModel := &models.UserModelImpl{Datastore: datastore}

	router := routes.Bootstrap(userModel)

	http.ListenAndServe(":8080", router)
}
