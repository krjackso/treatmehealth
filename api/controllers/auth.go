package controllers

import (
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/krjackso/treatmehealth/api/models"
)

type AuthControllerImpl struct {
	userModel models.UserModel
}

type AuthController interface {
	Me(http.ResponseWriter, http.Request)
	Index(http.ResponseWriter, http.Request)
}

func (self *AuthControllerImpl) Me(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	user, err := self.userModel.GetById(ctx, 1)
	body, err := json.Marshal(user)
	if err != nil {
		fmt.Printf("Error: %s", err)
		return
	}
	jsonstring := string(body[:])
	fmt.Fprintf(w, jsonstring)
}

func (self *AuthControllerImpl) Index(w http.ResponseWriter, r *http.Request) {

}
