package controllers

import (
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/krjackso/treatmehealth/api/models"
	"github.com/krjackso/treatmehealth/api/util/authutil"
)

type AuthControllerImpl struct {
	userModel models.UserModel
}

type AuthController interface {
	Me(http.ResponseWriter, http.Request)
	Index(http.ResponseWriter, http.Request)
	Login(http.ResponseWriter, http.Request)
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

func (self *AuthControllerImpl) Login(w http.ResponseWriter, r *http.Request) {
	auth := authutil.NewBasicAuthorization(r.Header)
	if auth == nil {
		w.WriteHeader(400)
		fmt.Fprintf(w, "Invalid Authorization header")
		return
	}

	ctx := r.Context()
	user, err := self.userModel.GetByUsername(ctx, auth.Username)
	if err != nil {
		panic(err)
	}

	if user == nil {
		w.WriteHeader(401)
		return
	}

	if !user.Credential.Verify(auth.Password) {
		w.WriteHeader(408)
		return
	}

	refreshToken := models.NewRefreshToken()

	err = self.userModel.AddRefreshToken(ctx, user.Id, refreshToken)
	if err != nil {
		println("Error adding refresh token: " + err.Error())
	}

	accessToken, expiresAt := models.NewAccessToken(user.Id)

	data := map[string]interface{}{
		"refresh_token": refreshToken.Token,
		"access_token":  accessToken,
		"expires_at":    expiresAt,
	}

	body, err := json.Marshal(data)
	if err != nil {
		panic(err)
	}
	fmt.Fprint(w, string(body[:]))
}
