package main

import (
	"fmt"
	"net/http"

	"github.com/krjackso/treatmehealth/api/controllers"
	"github.com/krjackso/treatmehealth/api/models"
	"github.com/krjackso/treatmehealth/api/services"
)

func main() {
	fmt.Println("Hello World!!")

	datastore := services.NewDatastore("treatme-health", "dev")

	userModel := &models.UserModelImpl{Datastore: datastore}

	router := controllers.Bootstrap(userModel)

	http.ListenAndServe(":8080", router)

}
